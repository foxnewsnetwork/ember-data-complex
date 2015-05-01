`import Ember from 'ember'`
`import DS from 'ember-data'`
`import DSC from 'ember-data-complex'`
`import { module, test } from 'qunit'`
`import startApp from '../helpers/start-app'`

application = null
container = null
store = null
module 'Acceptance: FallbackCacheTactic',
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

test 'onFindById cache hit', (assert) ->
  Ember.run ->
    Truck = container.lookupFactory "model:truck"
    assert.equal typeof Truck.prototype.save, 'function', 'should be able to modify the truck"s save'
    oldSave = Truck.prototype.save
    Truck.reopen
      save: ->
        assert.ok false, "as no changes occur on a cache hit, master should not require saving"
        oldSave.apply @. arguments
    store.find 'truck', 'master-1'
    .then (master) ->
      assert.ok master, "should be ok"
      assert.ok master instanceof DS.Model, "should be a ds model"
      assert.equal master.get("id"), 'master-1'
      assert.equal master.get("bravoId"), 'bravo-1'
      assert.equal master.get("charlieId"), 'charlie-1'
    .finally ->
      Truck.reopen
        save: oldSave

test 'onFindById missing bravo', (assert) ->
  Ember.run ->
    cid = null
    id = null
    charlie =
      licensePlate: "Baltimore-420"
      createdAt: new Date "april 28, 2015"
    store.createRecord 'truck', charlie: charlie
    .save()
    .then (master) ->
      assert.ok master instanceof DSC.ModelComplex , 'should have created a truck'
      assert.ok master.get("id"), 'should have proper id'
      id = master.get("id")
      assert.ok master.get("charlieId"), 'should have proper charlieId'
      cid = master.get "charlieId"
      assert.ok not master.get("bravoId"), 'should not a bravoId'
      master
    .then (master) ->
      store.find "truck", master.get("id")
    .then (master) ->
      assert.equal master.get("id"), id, "caching should not change id"
      assert.equal master.get("charlieId"), cid, "caching should not change charlieId"
      assert.ok master.get("bravoId"), "caching should have created a bravo"
      master.get("bravo")
    .then (bravo) ->
      assert.ok bravo.get("id"), "bravo should have proper id"

test 'onFindById missing everything', (assert) ->
  assert.expect 3
  Ember.run ->
    store.createRecord 'truck'
    .save()
    .then (master) ->
      assert.ok master instanceof DSC.ModelComplex , 'should have created a truck'
      assert.ok master.get("id"), 'should have proper id'
      store.find "truck", master.get 'id'
    .then (master) ->
      assert.ok false, 'it should not get here and should throw an error instead'
    .catch (error) ->
      assert.ok error, 'it should error out'

test 'onFindAll', (assert) ->
  Ember.run ->
    store.find "truck"
    .then (trucks) ->
      assert.ok trucks, "there should be a bunch of trucks"
      assert.ok trucks.get("length") > 1, "there should be a bunch of trucks"

test 'promises', (assert) ->
  new Ember.RSVP.Promise (resolve) -> 
    resolve 4
  .then (num) ->
    assert.equal num, 4
    num
  .catch (error) ->
    assert.ok false, "it should never get here"
  .then (num) ->
    assert.equal num, 4
    throw new Error "this error should not be caught"
  .catch (error) ->
    assert.ok true, "it should get here"
    "dogs"
  .then (dogs) ->
    assert.equal dogs, "dogs"

  new Ember.RSVP.Promise (resolve) -> 
    resolve 4
  .then (num) ->
    assert.equal num, 4
    throw new Error "this error should not be caught"
  .catch (error) ->
    assert.ok true, "it should get here"
    4
  .catch (error) ->
    assert.ok false, "it should never get here"
  .then (num) ->
    assert.equal num, 4
    "dogs"
  .catch (error) ->
    assert.ok false, "it should never get here"
    "dogs"
  .then (dogs) ->
    assert.equal dogs, "dogs"