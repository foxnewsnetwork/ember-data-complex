`import Ember from 'ember'`
`import DS from 'ember-data'`
`import { module, test } from 'qunit'`
`import startApp from '../helpers/start-app'`

application = null
container = null
store = null
module 'Acceptance: BelongsTo2',
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

test "the charlie truck", (assert) ->
  Ember.run ->
    store = container.lookup "store:main"
    adp = store.adapterFor "trucks/charlie"
    assert.ok /adapter:trucks\/charlie/.exec(adp.toString()), "the adapter name should match adapter:trucks/charlie"
    store.find "trucks/charlie", "charlie-1"
    .then (charlie) ->
      assert.ok charlie
      assert.equal charlie.get("id"), "charlie-1"

test "the delta truck", (assert) ->
  Ember.run ->
    adapter = container.lookup "adapter:trucks/delta"
    assert.ok adapter
    store = container.lookup "store:main"
    adp = store.adapterFor "trucks/delta"
    type = store.modelFor "trucks/delta"
    assert.equal type.typeKey, "trucks/delta"
    assert.equal adapter._debugContainerKey, adp._debugContainerKey, "we should have the right adapter"
    store.find "trucks/delta", "delta-1"
    .then (delta) ->
      assert.ok delta
      assert.equal delta.get("id"), "delta-1"

test 'the gamma adapter', (assert) ->
  Ember.run ->
    store = container.lookup "store:main"
    adp = store.adapterFor "trucks/gamma"
    assert.ok /adapter:trucks\/gamma/.exec(adp.toString()), "the adapter name should match adapter:trucks/gamma"

test "basic usage", (assert) ->
  Ember.run ->
    otruck = null
    store = container.lookup "store:main"
    store.find "truck", "master-1"
    .then (truck) ->
      assert.equal truck.get("deltaId"), "delta-1", "it should have a deltaId"
      assert.ok not truck.get('delta'), "the delta should be blank for now"
      promise = truck.get "deltaPromise"
      assert.equal typeof promise?.then, 'function', 'the promise should be a promise'
      otruck = truck
      promise
    .then (delta) ->
      assert.ok delta
      assert.equal delta.constructor.typeKey, "trucks/delta"
      assert.equal delta.get("id"), otruck.get("deltaId")
      assert.equal delta.get("songName"), "yoshiwara lament"
      assert.equal delta.get("artist"), "asa"

      assert.ok otruck
      assert.ok otruck.get "delta"
      assert.equal otruck.constructor.typeKey, "truck"
      assert.equal otruck.get("delta"), delta
