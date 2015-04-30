`import Ember from 'ember'`

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
notDataComplex = (model) -> """
You tried to use a DSC.belongsTo on #{model}, but #{model} doesn't act like a DSC.ModelComplex.
Insofar as it doesn't have a '-dsc-tempstorage' key (among other things). If you're to use DSC.belongsTo,
consider using a DSC.ModelComplex instead of a vanilla DS.Model.
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
  

class Macros
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