`import Ember from 'ember'`
`import { promiseLike, promiseLift } from './arrows'`

noStoreMsg = """
You tried to declare a model-through computed macro on an object that didn't have a 'store' property.
The intended usage of the DSC.Macros.through macro is to provide a non-relational alternative to DS.belongsTo.
As such, I expect to use it in a DS.Model-like class as in the following example:

  Dog = DS.Model.extend
    ownerId: DS.attr 'string'
    owner: DSC.Macros.through 'user', 'ownerId'
"""
uncreativeMsg = """
You tried to use the createWith macro but the factory class you gave me doesn't support a #create method.
Instead of whatever you're doing, you should use the createWith macro like in the following example:
  
  DogTag = Ember.Object.extend(...)
  Dog = DS.Model.extend
    name: DS.attr "string"
    owner: DS.attr "string"
    dob: DS.attr "date"
    collar: DSC.Macros.createWith DogTag, "name", "owner", "dob"
"""
noModelName = """
You tried to specify a belongsTo relationship, but you didn't specify what the master (owner) model is.
This is an oversight on your part, so consult the following example to have an idea what you should be doing:

  Dog = DSC.ModelComplex.extend
    ownerId: DS.attr "string"
    owner: DSC.belongsTo "owner", foreignKey: "ownerId"

EmberJS is, for better or worse, not rails so you have no choice but to declare a lot more junk up front.
"""
noFKey = """
You tried to specify a belongsTo relationship, yet you didn't specify a foreign key.
This is an act of pure incompetence on your part; this isn't rails, I can't just infer what the key should be!
Consult the following example for an idea how to declare belongsTo relationships:
  
  Dog = DSC.ModelComplex.extend
    ownerId: DS.attr "string"
    owner: DSC.belongsTo "owner", foreignKey: "ownerId"
"""
noPField = """
You tried to specify an asyncBelongsTo relationship, but you neglected to provide a promise field.
The whole point behind asyncBelongsTo as oppose to Ember's native DS.belongsTo is to be explicit,
as in you're explicit about which field contains the foreignKey and which field contains the promise.
Consider the following example:

  Dog = DSC.ModelComplex.extend
    ownerId: DS.attr "string"
    owner: DSC.asyncBelongsTo "owner", foreignKey: "ownerId", promiseField: "ownerPromise"
"""
notDataComplex = (model) -> """
You tried to use a DSC.belongsTo on #{model}, but #{model} doesn't act like a DSC.ModelComplex.
Insofar as it doesn't have a '-dsc-tempstorage' key (among other things). If you're to use DSC.belongsTo,
consider using a DSC.ModelComplex instead of a vanilla DS.Model.
"""
notPromiseMsg = """
You tried to set a pure value to a field which expects a promise. This is undoubtly an oversight on your part.
"""
alreadySetMsg = """
The ONLY way to proper deal with resolving promises correctly is to have them be immutable,
you've already set this promise, so you can't do it again.
"""
lll = (x) ->
  console.log x
  x
belongsToSet = (ctx, modelName, idField, value, key) ->
  Ember.assert notDataComplex(ctx), ctx['-dsc-tempstorage']?
  if (value instanceof DS.Model) and Ember.get(value, "id")?
    delete ctx['-dsc-tempstorage'].data['#{modelName}::#{idField}']
    delete ctx['-dsc-tempstorage'].meta['#{modelName}::#{idField}']
    ctx.set idField, Ember.get(value, "id")
  else
    ctx['-dsc-tempstorage'].meta["#{modelName}::#{idField}"] =
      slaveName: key
      modelName: modelName
      idField: idField
    ctx['-dsc-tempstorage'].data["#{modelName}::#{idField}"] = value

belongsToGet = (ctx, modelName, idField) ->
  Ember.assert notDataComplex(ctx), ctx['-dsc-tempstorage']?
  Ember.assert noStoreMsg, ctx.store?
  if Ember.isPresent(id = ctx.get idField)
    ctx.store.find modelName, id
  else
    ctx['-dsc-tempstorage'].data["#{modelName}::#{idField}"]

idLike = (something) ->
  typeof something is "string" or typeof something is "number"

bareObjectLike = (something) ->
  typeof something is 'object' and 
  something instanceof Ember.Object isnt true

class Macros
  @promiseTo = (modelName, foreignKey, foreignField) ->
    { foreignKey, foreignField } = foreignKey if typeof foreignKey is 'object'
    Ember.assert noModelName, modelName?
    Ember.assert noFKey, foreignKey?
    Ember.assert noPField, foreignField?
    f = (promiseField, modelPromise) ->
      @["-dsc-#{promiseField}-deference"] ?= Ember.RSVP.defer()
      if arguments.length > 1
        throw new Error alreadySetMsg if @["-dsc-#{promiseField}-will-resolve"] is true
        Ember.assert notPromiseMsg, promiseLike modelPromise
        @["-dsc-#{promiseField}-will-resolve"] = true
        modelPromise.then (model) => 
          @set foreignField, model
          @set foreignKey, model.get("id")
          @["-dsc-#{promiseField}-deference"].resolve model
      return @["-dsc-#{promiseField}-deference"].promise if @["-dsc-#{promiseField}-will-resolve"] is true
      if @get(foreignField)?
        model = @get foreignField
        return @["-dsc-#{promiseField}-deference"].promise if bareObjectLike model
        @set foreignKey, model.get("id")
      if @get(foreignKey)?
        promise = @store.find(modelName, @get foreignKey) 
        @set promiseField, promise
      @get promiseField
    prop = Ember.computed modelName, foreignKey, foreignField, f
    prop.meta
      relationType: "complex-promise-to"
      idField: foreignKey
      foreignField: foreignField
      modelName: modelName
    prop

  @asyncBelongsTo = (modelName, idField, promiseField) ->
    {foreignKey: idField, promiseField} = idField if typeof idField is 'object'
    Ember.assert noModelName, modelName?
    Ember.assert noFKey, idField?
    Ember.assert noPField, promiseField?
    f = (modelField, model) ->
      if arguments.length > 1
        switch
          when promiseLike model
            @set promiseField, model
          when idLike model
            @set idField, model
          when bareObjectLike model
            @["-dsc-#{modelField}-model"] = model
          else
            @["-dsc-#{modelField}-has-resolved"] = true
            @["-dsc-#{modelField}-model"] = model
            @set idField, Ember.get(model, "id")
            @set promiseField, promiseLift model
      return @["-dsc-#{modelField}-model"] if @["-dsc-#{modelField}-has-resolved"] is true or @["-dsc-#{modelField}-model"]?
      if promise = @get promiseField
        promise.then (model) => 
          @set modelField, model
        return
      if id = @get idField
        promise = @store.find(modelName, id).then (model) => 
          @set modelField, model
          model
        @set promiseField, promise
        return
    prop = Ember.computed modelName, idField, promiseField, f
    prop.meta
      relationType: "complex-belongs-to"
      idField: idField
      promiseField: promiseField
      modelName: modelName
    prop


  @through = (modelName, idField) ->
    idField = idField.foreignKey if idField.foreignKey?
    Ember.assert noModelName, modelName?
    Ember.assert noFKey, idField?
    f = (key, model) ->
      if arguments.length > 1
        belongsToSet @, modelName, idField, model, key
      belongsToGet @, modelName, idField
    Ember.computed modelName, idField, f

  @createWith = (emberFactory, fields...) ->
    f = (_, emberObject) ->
      if arguments.length > 1
        for field in fields
          @set field, Ember.get(emberObject, field)
      attributes = {}
      for field in fields
        return if Ember.isBlank @get field
        attributes[field] = @get field
      Ember.assert uncreativeMsg, emberFactory? and typeof ember.create is "function"
      emberFactory.create attributes


`export default Macros`