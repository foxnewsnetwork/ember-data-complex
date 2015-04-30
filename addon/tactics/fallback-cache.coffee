`import Ember from 'ember'`
`import { async, syncReduce, asyncMap } from '../utils/async'`
`import { lift, promiseLift } from '../utils/arrows'`
`import getAttributes from '../utils/get-attributes'`

errorMsg = """
You tried to use the fallback cache strategy but you didn't tell me the order
I should fallback on finding different models. This is an oversight on your
part and you can correct it by adding something like the following on create:

FallbackCacheStrategy.create
  order: ["fire", "rail", ...]

where "fire", "rail", etc. are computed properties on your master model.
"""

propMsg = (name) -> """
You declared an ordering on the FallbackCacheStratey with '#{name}',
but '#{name}' isn't a computed property on your master model.
This is an oversight on your part; consider the following example to help you fix it:

  MasterDog = DS.Model.extend
    #{name}Id: DS.attr 'string'
    railsId: DS.attr 'string'
    #{name}: DSC.Macros.through "#{name}/dog", "#{name}Id"
    rail: DSC.Macros.through "rails/dog", "railsId"
  DogStrategy = DSC.FallbackCacheStrategy.extend
    order: ['#{name}', 'rails']
"""

noCacheMsg = (model) -> """
Attempted to use a fallback cache tactic on the model complex #{model}@#{model.get 'id'},
however, all the caches you specified in your strategy returned null.
This is likely because your upstream data source contains inconsistencies,
as you know, a ModelComplex is something of a meta-model (it stores info about other models),
and therefore, you should never have a meta-model without referencing models.
"""
class Tier
  @from = (model, property) ->
    cprop = model[property]
    Ember.assert propMsg(property), cprop? and cprop._dependentKeys? and cprop._dependentKeys[0]?
    new Tier property, cprop._dependentKeys[0]
  constructor: (@propertyName, @modelName) ->
lll = (x) ->
  console.log x
  x

isCacheHit = (model, property) ->
  cprop = model[property]
  Ember.assert propMsg(property), cprop? and cprop._dependentKeys? and cprop._dependentKeys[0]?
  idField = cprop._dependentKeys[1]
  Ember.isPresent Ember.get(model, idField)

FallbackCacheTactic = Ember.Mixin.create
  init: ->
    @_super arguments...
    throw new Error errorMsg if Ember.isBlank @get "order"

  firstWorkingSlave: (master) ->
    return promiseLift [[], {}] if isCacheHit master, @get("order.firstObject")
    tiers = Ember.A []
    syncReduce null, @get("order"), (model, property) ->
      return model if model?
      tiers.pushObject Tier.from master, property
      master.get property
    .then (model) ->
      [tiers.slice(0, -1), model]

  fillPositionsWithSlave: (master, missingPositions, slave) ->
    return promiseLift master unless Ember.isPresent(missingPositions) and Ember.isPresent(slave)
    attributes = getAttributes slave
    asyncMap @, missingPositions, (propertyName: propertyName, modelName: modelName) ->
      @store
      .createRecord(modelName, attributes)
      .save()
      .then (newSlave) ->
        master.set propertyName, newSlave

  onFindById: (masterPromise) ->
    promiseLift masterPromise
    .then (master) =>
      @firstWorkingSlave master
      .then ([missingPositions, slave]) ->
        [master, missingPositions, slave]
    .then ([master, missingPositions, slave]) =>
      Ember.assert noCacheMsg(master), Ember.isPresent slave
      @fillPositionsWithSlave masterPromise, missingPositions, slave
      .then -> master.save()

  onFindAll: (mastersPromise) ->
    promiseLift mastersPromise
    .then (masters) =>
      asyncMap @, masters, @onFindById
    

`export default FallbackCacheTactic`