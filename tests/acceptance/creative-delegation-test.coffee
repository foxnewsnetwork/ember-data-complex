`import Ember from 'ember'`
`import DS from 'ember-data'`
`import DSC from 'ember-data-complex'`
`import { module, test } from 'qunit'`
`import startApp from '../helpers/start-app'`
`import { expect } from 'chai'`

window.expect = expect
application = null
container = null
store = null
module 'Acceptance: CreativeDelegationTactic',
  beforeEach: ->
    Ember.run ->
      application = startApp()
      container = application.__container__
      store = container.lookup "store:main"
    ###
    Don't return as Ember.Application.then is deprecated.
    Newer version of QUnit uses the return value's .then
    function to wait for promises if it exists.
    ###
    return

  afterEach: ->
    Ember.run application, 'destroy'

test "sanity", (assert) ->
  assert.ok store, "store should be ok"
  assert.equal typeof store.find, 'function', "store should have find"

test "creation should work fine", (assert) ->
  attributes =
    charlie:
      licensePlate: "Forrest Gump"
      createdAt: new Date "May 1, 1999"
    bravo:
      location: "Alabama"
  Ember.run ->
    store.createRecord "truck", attributes
    .save()
    .then (master) ->
      assert.ok master, "the master truck should be ok"
      assert.ok master instanceof DSC.ModelComplex, "the master should be an instance of the model complex"
      assert.ok master.get("bravoId"), "it should have assigned a bravoId"
      assert.ok master.get("charlieId"), "it should assign a charlieId"
      master.get "bravo"
      .then (bravo) ->
        assert.equal bravo.get("location"), "Alabama", "bravo should be in alabama"
      master.get "charlie"
      .then (charlie) ->
        assert.equal charlie.get("licensePlate"), "Forrest Gump", "the license plate should be defined"

test "creation when charlie fucks up", (assert) ->
  attributes =
    charlie:
      licensePlate: "clusterfuck"
      createdAt: new Date "May 1, 1999"
    bravo:
      location: "Alabama"
  Ember.run ->
    truck = store.createRecord "truck", attributes
    timesCalled = 0
    oldSave = truck.save.bind(truck)
    truck.save = ->
      assert.ok timesCalled < 1, "because persistence should fail, the truck's save method should only be called once"
      timesCalled += 1
      oldSave arguments...
    truck
    .save()
    .then (master) ->
      assert.ok false, "it should not get here"
    .catch (error) ->
      assert.ok expect(error.message).to.match /your upstream server refused to do so/
      assert.equal error.deadChildren.length, 1
      assert.equal error.orphans.length, 1
      assert.ok error, "we should encounter an error because charlie fucked up"

test "creative delegation should work with belongsTo2", (assert) ->
  attributes =
    delta:
      songName: "No Title"
      artist: "Reol"

  Ember.run ->
    truck = store.createRecord "truck", attributes
    delta = truck.get "delta"
    assert.equal delta["songName"], "No Title", "it should have the correct name"
    assert.equal delta["artist"], "Reol", "it should transfer the attributes correctly"

    truck.save()
    .then (master) ->
      assert.ok master, "the master should be ok"
      assert.ok master.get("id"), "the master should have been saved correctly"
      master.get "deltaPromise"
    .then (delta) ->
      assert.ok delta, "should be saved correctly"
      assert.ok delta.get("id"), "should have a proper id"
      assert.equal delta.get("songName"), "No Title"
      assert.equal delta.get("artist"), "Reol"

test "creative delegation should also work promiseTo", (assert) ->
  attributes =
    gamma:
      songName: "Hibikaze"
      artist: "Reol"

  Ember.run ->
    truck = store.createRecord "truck", attributes
    gamma = truck.get "gamma"
    assert.equal gamma["songName"], "Hibikaze", "it should have the correct name"
    assert.equal gamma["artist"], "Reol", "it should transfer the attributes correctly"

    truck.save()
    .then (master) ->
      assert.ok master, "the master should be ok"
      assert.ok master.get("id"), "the master should have been saved correctly"
      master.get "gammaPromise"
    .then (gamma) ->
      assert.ok gamma, "should be saved correctly"
      assert.ok gamma.get("id"), "should have a proper id"
      assert.equal gamma.get("songName"), "Hibikaze"
      assert.equal gamma.get("artist"), "Reol"