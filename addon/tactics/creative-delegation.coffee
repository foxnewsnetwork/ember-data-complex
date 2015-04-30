`import Ember from 'ember'`
`import { asyncMap } from '../utils/async'`
`import { ifA, promiseLift, debugLog } from '../utils/arrows'`

noAttrMsg = """
You passed in blank attributes hash. This was likely because of an internal error with the DSC
framework and DSC.belongsTo not properly storing things correctly.
"""
noMetaMsg = """
Your attribute hash doesn't contain the -dsc-metadata field, this is weird because this means
either the DSC.belongsTo macro messed up, or you, or whatever reason, decided to set and or
clear-out the -dsc-metadata field on attributes.
"""
noSlaveMsg = """
The -dsc-metadata field did not contain 'slaveName' as it should have. This was very likely because
you somehow used DSC.belongsTo incorrectly. Cheers, Einstein. Pls figure out what you did wrong and fix it.
"""
persistMsg = """
Attempted to persist the child model, but your upstream server refused to do so.
This has left things in a terrible state because, due to this failure,
the master model will NOT be persisted upstream... but, at the same time,
certain children models have already been persisted so you'll need to clean them up,
or try again with the master model, or something.

Whatever you decide, I've made this easy for you by attaching relevant things to the error object:

1. error.deadChildren[]reason = the reason object given by the adapter
1. error.deadChildren[]params = the param object that lead to death
3. error.orphans = array of successfully persisted, but now orphaned, models
"""

encounteredDisaster = (results) ->
  Ember.A(results).isAny "state", "rejected"
formatSuccess = (results) ->
  Ember.A(results).map ({value}) -> value
arrangeDeadKids = (results) ->
  Ember.A results
  .filter ({state}) -> state is "rejected"
  .map (reason:{reason, params}) ->
    reason: reason
    params: params
collectOrphans = (results) ->
  Ember.A results
  .filter ({state}) -> state is "fulfilled"
  .map ({value}) -> value
formatFailure = (results) ->
  e = new Error persistMsg
  e.deadChildren = arrangeDeadKids results
  e.orphans = collectOrphans results
  e

CreativeDelegationTactic = Ember.Mixin.create
  saveChild: (attributes: attributes, metadata: metadata) ->
    { modelName: modelName, slaveName: slaveName } = metadata
    model = @store.createRecord modelName, attributes
    model.mastersNameForMe = slaveName
    model.save()

  tempStoragePersistenceProcess: (master) ->
    (modelParams) =>
      @saveChild modelParams
      .then (model) ->
        master.set model.mastersNameForMe, model
        model
      .catch (reason) ->
        e = new Error "failed to save child"
        e.reason = reason 
        e.params = modelParams
        throw e
  beforeCreate: (master) ->
    newthings = master.tempStorage()
    transform = @tempStoragePersistenceProcess master
    asyncMap @, newthings, transform
    .then (results) ->
      if encounteredDisaster results
        throw formatFailure results
      else
        formatSuccess results
    
`export default CreativeDelegationTactic`