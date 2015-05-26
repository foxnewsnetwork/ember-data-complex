`import { test, moduleForModel } from 'ember-qunit'`

moduleForModel 'truck'

test 'it exists', (assert) ->
  model = @subject()
  # store = @store()
  assert.ok model?

test 'store find', (assert) ->
  store = @store()
  assert.ok store
  assert.equal typeof store.find, "function"

test '#tempStorage()', (assert) ->
  model = @subject()
  assert.ok model.tempStorage
  assert.equal typeof model.tempStorage, 'function'
  assert.deepEqual model.tempStorage(), []

test 'tempStorage should store things properly', (assert) ->
  model = @subject()
  bravo =
    location: 'neverland'
  model.set "bravo", bravo
  actual = model.tempStorage()
  assert.equal actual.length, 1, "there should be only 1 thing in the temp storage"
  assert.deepEqual actual[0],
    attributes:
      location: 'neverland'
    metadata:
      idField: "bravoId"
      modelName: "trucks/bravo"
      slaveName: "bravo"

test 'tempStorage should work on creation also', (assert) ->
  charlie =
    createdAt: new Date "April 27, 2015"
    licensePlate: "hikari-are"
  bravo =
    location: 'neverland'

  model = @subject charlie: charlie, bravo: bravo
  actual = model.tempStorage()
  assert.equal actual.length, 2, "there should be 2 things in temporary storage"
  assert.deepEqual actual[1],
    attributes:
      location: 'neverland'
    metadata:
      idField: "bravoId"
      modelName: "trucks/bravo"
      slaveName: "bravo"
  assert.deepEqual actual[0],
    attributes:
      createdAt: new Date "April 27, 2015"
      licensePlate: "hikari-are"
    metadata:
      idField: "charlieId"
      modelName: "trucks/charlie"
      slaveName: "charlie"

test "it should just work with the changed belongsTo", (assert) ->
  charlie =
    createdAt: new Date "April 27, 2015"
    licensePlate: "hikari-are"
  bravo =
    location: 'neverland'
  delta = 
    songName: "netoge haijin sprechchor"
    artist: "wotamin"
  model = @subject charlie: charlie, bravo: bravo, delta: delta
  thing = model.get "delta"
  assert.deepEqual thing, delta

test "it should have 4 related types", (assert) ->
  charlie =
    createdAt: new Date "April 27, 2015"
    licensePlate: "hikari-are"
  bravo =
    location: 'neverland'
  delta = 
    songName: "netoge haijin sprechchor"
    artist: "wotamin"
  model = @subject charlie: charlie, bravo: bravo, delta: delta
  fields = Ember.get model.constructor, "fields"
  assert.equal fields.size, 4
  assert.ok typeof model.constructor.eachComputedProperty is 'function'
  
test "it should work with the promiseTo property", (assert) ->
  charlie =
    createdAt: new Date "April 27, 2015"
    licensePlate: "hikari-are"
  bravo =
    location: 'neverland'
  delta = 
    songName: "netoge haijin sprechchor"
    artist: "wotamin"
  gamma =
    songName: "hibikaze"
    artist: "reol"
  model = @subject charlie: charlie, bravo: bravo, delta: delta, gamma: gamma
  thing = model.get "gamma"
  assert.deepEqual thing, gamma