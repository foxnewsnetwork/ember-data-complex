`import Ember from 'ember'`
`import DS from 'ember-data'`
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
    truckPromise = store.find "truck", "master-1"
    assert.ok truckPromise, "the store should find a truck"
    assert.equal typeof truckPromise.then, 'function', "the found truck should properly be a promise"
    truckPromise.then (truck) ->
      assert.ok truck, "the promise should resolve to a truck"
      assert.equal truck.get("id"), "master-1", "the truck should have a proper master id"
      assert.equal truck.get("bravoId"), "bravo-1", "the truck should have a bravo id"
      assert.equal truck.get("charlieId"), "charlie-1", "the truck should have a charlie id"
      assert.ok truck.get("bravo"), "the truck should be able to get bravo"
      assert.ok truck.get("charlie"), "the truck should be able to get charlie"
      truck.get("bravo").then ->
        assert.equal truck.get("bravo.location"), "applebees", "bravo should store location"
      truck.get("charlie").then ->
        assert.equal truck.get("charlie.licensePlate"), "dogs402", "charlie should store license plate"

test 'createRecord', (assert) ->
  Ember.run ->
    store = container.lookup "store:main"
    charlie = 
      licensePlate: "harold-443"
      createdAt: new Date "April 25, 2015"
    bravo =
      location: "Chile's"
    attributes =
      charlie: charlie
      bravo: bravo
    truck = store.createRecord("truck", attributes)
    assert.equal truck.get("charlie"), charlie
    assert.equal truck.get("bravo"), bravo

test 'creative delegation', (assert) ->
  Ember.run ->
    store = container.lookup "store:main"
    assert.equal typeof store.adapterFor, 'function'
    adapter = store.adapterFor "trucks/bravo"
    assert.equal typeof adapter.allAoiEirSongsSoundTheSame, 'function'
    attributes =
      charlie:
        licensePlate: "harold-443"
        createdAt: new Date "April 25, 2015"
      bravo:
        location: "Chile's"
    store.createRecord("truck", attributes).save()
    .then (truck) ->
      assert.ok truck, "the truck should resolve to a truck"
      assert.ok truck.get("bravoId"), "creation should made everything"
      assert.ok truck.get("charlieId"), "charlie also"
      assert.ok truck.get("bravo") instanceof DS.PromiseObject, "bravo should resolve a promise"
      assert.ok truck.get("charlie") instanceof DS.PromiseObject, "charlie should resolve a promise"
      truck.get("bravo")
      .then (bravo) ->
        assert.equal bravo.get("location"), "Chile's"
      .catch (error) ->
        console.log error.stack
        assert.ok false, "should not get here: #{error}"
      truck.get("charlie").then (charlie) ->
        assert.equal charlie.get("licensePlate"), "harold-443"
        assert.equal charlie.get("createdAt"), attributes.charlie.createdAt
      .catch (error) -> 
        console.log error.stack
        assert.ok false, "should not get here: #{error}"
      truck

test 'it should support a strategyFor feature which follows a model strategy', (assert) ->
  Ember.run ->
    store = container.lookup "store:main"
    assert.ok store.strategyFor, "should have a strategyFor method"
    assert.equal typeof store.strategyFor, 'function', "strategyFor should be a proper function"
    strategy = store.strategyFor "truck", "onFindAll"
    assert.ok strategy, 'a strategy should be found for truck'
    assert.ok strategy.onFindAll, 'a strategy should have a onFind property'
    assert.equal typeof strategy.onFindAll, 'function', 'onFind should be a proper function'
