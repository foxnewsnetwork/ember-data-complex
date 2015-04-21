`import Ember from 'ember'`

noStoreMsg = """
You tried to declare a model-through computed macro on an object that didn't have a 'store' property.
The intended usage of the DSC.Macros.through macro is to provide a non-relational alternative to DS.belongsTo.
As such, I expect to use it in a DS.Model-like class as in the following example:

  Dog = DS.Model.extend
    ownerId: DS.attr 'string'
    owner: DSC.Macros.through 'user', 'ownerId'
"""
class Macros
  @through = (modelName, idField) ->
    f = (_, model) ->
      if arguments.length > 1
        @set idField, Ember.get model, "id"
      id = @get idField
      return if Ember.isBlank id
      Ember.assert noStoreMsg, @store?
      @store.find modelName, id
    Ember.computed idField, f


`export default Macros`