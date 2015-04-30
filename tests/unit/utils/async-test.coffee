`import { async, syncReduce, asyncMap, asyncMapWimpy } from 'ember-data-complex/utils/async'`
`import { lift, ifA, Either, id, Arrows } from 'ember-data-complex/utils/arrows'`
`import Ember from 'ember'`
`import { module, test } from 'qunit'`

module 'async'

delay = (t, f) ->
  new Ember.RSVP.Promise (resolve) ->
    Ember.run.later null, (-> resolve f()), t

explode = (t, f=->) ->
  new Ember.RSVP.Promise (_, reject) ->
    Ember.run.later null, (-> reject f()), t

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

test 'composition long', (assert) ->
  saya = (x) -> x + "a"
  saye = (x) -> delay 5, -> x + "e"
  sayi = (x) -> x + "i"
  transform = lift(saya).compose(saye).compose(sayi)
  transform.run("o").then (x) ->
    assert.equal x, "oaei"

test 'resolve-reject unification', (assert) ->
  truth = lift (x) -> delay 4, -> x + "truth"
  lies = lift (x) -> delay 5, -> x + "lies"
  good = lift (x) -> 
    assert.equal x, "ember=truth"
    x
  bad = lift (x) -> assert.ok false, "expected not to get here, but did #{x}"
  decider = Arrows.polarize (x) -> x is "ember="
  transform = decider
  .compose truth.split lies
  .compose good.fanin bad

  transform.run("ember=").then (actual) ->
    assert.equal actual, "ember=truth"
  
test 'composeReject', (assert) ->
  failure = -> delay 15, -> new Error "death to the enemies of the horde"
  ifA failure
  .elseA (error) ->
    assert.ok error, "elseA should properly unlift the error out of the promise"
    assert.ok error.message, "the error should be a proper error"
    assert.equal error.message, "death to the enemies of the horde", "the message should be the right one"
  .end()

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

test 'if-else expression nature', (assert) ->
  assert.expect 2
  rover = find "dog", "rover"
  ifA rover
  .thenA ->
    "apples"
  .elseA ->
    "oranges"
  .end()
  .then (actual) ->
    assert.equal actual, "apples"

  spot = find "dog", "spot"
  ifA spot
  .thenA ->
    "apples"
  .elseA ->
    "oranges"
  .end()
  .then (actual) ->
    assert.equal actual, "oranges"

test 'syncReduce', (assert) ->
  assert.expect 1
  syncReduce "d", [10,20,30,40], (sum, n) -> delay 50 - n, -> "#{sum}-#{n}"
  .then (str) ->
    assert.equal str, "d-10-20-30-40"

test 'async finally value', (assert) ->
  promise = async ->
    yield delay 15, -> "death to EA"
  assert.ok promise, "async should return something"
  assert.equal typeof promise.then, 'function', "that something should be a promise"
  promise.then (actual) ->
    assert.equal actual, "death to EA", "and that promise should resolve to the return value of async"

test 'asyncMap', (assert) ->
  asyncMap null, [1,2,3,4], (x) -> delay 10, -> x * 2
  .then (results) ->
    actual = results.map (value: value) -> value
    assert.deepEqual actual, [2,4,6,8], 'it should map and resolve'
  .catch ->
    assert.ok false, 'it should not get here'

test 'asyncMapWimpy same as regular', (assert) ->
  asyncMapWimpy null, [1,2,3,4], (x) -> delay 10, -> x * 2
  .then (actual) ->
    assert.deepEqual actual, [2,4,6,8], 'it should map and resolve'
  .catch ->
    assert.ok false, 'it should not get here'

test 'asyncMapWimpy same as regular', (assert) ->
  asyncMapWimpy null, [1,2,3,4], (x) -> 
    return x * 2 if x < 3
    return explode 5 if x is 3
  .then (results) ->
    assert.ok false, 'it should not get here'
  .catch ->
    assert.ok true, 'it should render an error because of the 3'
