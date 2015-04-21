`import Ember from 'ember'`
`import { module, test } from 'qunit'`
`import startApp from '../helpers/start-app'`
`import { initialize } from 'ember-data-complex/initializers/data-complex'`

application = null
container = null
module 'Acceptance: ModelComplex',
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

test 'it should be able to find a truck', (assert) ->
  Ember.run ->
    assert.ok container, "the container should be present"
    assert.ok container.lookup, "the container should be properly initialized"
    store = container.lookup "store:main"
    assert.ok store, "the store should be there"
    assert.ok store.find, "the store should support finding"
    truckPromise = store.find "truck", 2
    assert.ok truckPromise, "the store should find a truck"
    assert.ok truckPromise.then, "the found truck should properly be a promise"
    truckPromise.then (truck) ->
      assert.ok truck, "the promise should resolve to a truck"
      assert.equal truck.get("id"), 2, "the truck should have a proper master id"
      assert.equal truck.get("bravoId"), "bravo-666", "the truck should have a bravo id"
      assert.equal truck.get("charlieId"), "charlie-420", "the truck should have a charlie id"
      assert.ok truck.get("bravo"), "the truck should be able to get bravo"
      assert.ok truck.get("charlie"), "the truck should be able to get charlie"
      truck.get("bravo").then ->
        assert.equal truck.get("bravo.location"), "applebees", "bravo should store location"
      truck.get("charlie").then ->
        assert.equal truck.get("charlie.licensePlate"), "hype-4231", "charlie should store license plate"

test 'it should support a strategyFor feature which follows a model strategy', (assert) ->
  Ember.run ->
    store = container.lookup "store:main"
    assert.ok store.strategyFor, "should have a strategyFor method"
    assert.equal typeof store.strategyFor, 'function', "strategyFor should be a proper function"
    strategy = store.strategyFor "truck"
    assert.ok strategy, 'a strategy should be found for truck'
    assert.ok strategy.onFind, 'a strategy should have a onFind property'
    assert.equal typeof strategy.onFind, 'function', 'onFind should be a proper function'
