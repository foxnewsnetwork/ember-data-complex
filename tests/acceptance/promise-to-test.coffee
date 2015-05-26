`import Ember from 'ember'`
`import DS from 'ember-data'`
`import { module, test } from 'qunit'`
`import startApp from '../helpers/start-app'`

application = null
container = null
store = null
module 'Acceptance: PromiseTo',
  beforeEach: ->
    Ember.run ->
      application = startApp()
      container = application.__container__
    ###
    Don't return as Ember.Application.then is deprecated.
    Newer version of QUnit uses the return value's .then
    function to wait for promises if it exists.
    ###
    return

  afterEach: ->
    Ember.run application, 'destroy'

test "the gamma truck", (assert) ->
  Ember.run ->
    master = null
    store = container.lookup "store:main"
    store.find "truck", "master-1"
    .then (truck) ->
      assert.equal truck.get("gammaId"), "gamma-1", "there should be a gammaId"
      gp = truck.get "gammaPromise"
      assert.ok gp, "there should be a gamma promise"
      assert.equal typeof gp.then, 'function', 'it should be a promise'
      gp
      .then (gamma) ->
        assert.ok gamma, "we should find the gamma"
        assert.equal gamma.get("id"), "gamma-1"
        assert.equal gamma, truck.get "gamma"

test "ember observing", (assert) ->
  visit "/"
  assert.equal find("#last-night-good-night").text(), "", "it should start out blank"
  andThen ->
    assert.equal find("#last-night-good-night").text().trim(), "Just Be Friends", "it should have rendered"