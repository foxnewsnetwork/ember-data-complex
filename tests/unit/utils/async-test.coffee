`import async from 'ember-data-complex/utils/async'`
`import { ifA, Either } from 'ember-data-complex/utils/arrows'`
`import Ember from 'ember'`
`import { module, test } from 'qunit'`

module 'async'

delay = (t, f) ->
  new Ember.RSVP.Promise (resolve) ->
    Ember.run.later null, (-> resolve f()), t

find = (model, name) ->
  delay 15, ->
    if name is "rover"
      Ember.Object.create name: name
    else
      new Error "Unable to find #{name}"

test 'ifA', (assert) ->
  decider = -> true
  ifA decider
  .thenA ->
    assert.ok true, "if should get here"
  .end()

test 'ifA promises', (assert) ->
  decider = -> delay 3, -> true
  ifA decider
  .thenA ->
    assert.ok true, "if should get here"
  .end() # yeah, you need this, sorry

test 'if-else equivalence', (assert) ->
  assert.expect 2
  truth = -> true
  lies = -> false

  ifA truth
  .thenA ->
    assert.ok true, "the truth should give one resolution"
  .elseA ->
    assert.ok false, "the truth should not lead one to rejection"
  .end()

  ifA lies
  .thenA ->
    assert.ok false, "lies should not lead one to resolution"
  .elseA ->
    assert.ok true, "lies should lead one to rejection"
  .end() # yeah, you need this, sorry

test 'if else on error', (assert) ->
  assert.expect 7
  failure = -> delay 15, -> new Error "death to the enemies of the horde"
  success = -> delay 20, -> Ember.Object.create name: "wc3"

  ifA success
  .thenA (thing) ->
    assert.ok thing, "thenA should unlift the object out of the promise"
    assert.ok thing instanceof Ember.Object, "the object should be an instance of Ember Object"
    assert.ok thing.get, "the thing should have a get function"
    assert.equal thing.get("name"), "wc3", "the thing should properly have a name"
  .elseA ->
    assert.ok false, "it should never get here"
  .end()

  ifA failure
  .thenA ->
    assert.ok false, "it should never get here"
  .elseA (error) ->
    assert.ok error, "elseA should properly unlift the error out of the promise"
    assert.ok error.message, "the error should be a proper error"
    assert.equal error.message, "death to the enemies of the horde", "the message should be the right one"
  .end()

test 'generator async yield', (assert) ->
  async ->
    rover = yield find "dog", "rover"
    assert.ok rover.get
    assert.equal rover.get("name"), "rover"

test 'async yield usage', (assert) ->
  async ->
    rover = yield find "dog", "rover"
    ifA rover
    .thenA (doge) ->
      assert.equal rover, doge, "all bullshit aside, if and then should handle error cases"
    .elseA ->
      assert.ok false, "should not get here"
    .end()

    bad = yield find "dog", "spot"
    ifA bad
    .thenA (doge) ->
      assert.ok false, "should not get here"
    .elseA (error) ->
      assert.equal error.message, "Unable to find spot"
    .end()