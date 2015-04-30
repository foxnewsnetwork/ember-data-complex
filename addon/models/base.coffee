`import Ember from 'ember'`
`import DS from 'ember-data'`
`import { promiseLift } from '../utils/arrows'`
get = Ember.get

calculateOperation = (record) ->
  switch
    when get(record, "currentState.stateName") is "root.deleted.saved" then null
    when get(record, "isNew") then "beforeCreate"
    when get(record, "isDeleted") then "beforeDestroy"
    else "beforeUpdate"

# TODO: implement advanced features for:
# #save, #update, and #destroy
Base = DS.Model.extend
  init: ->
    @['-dsc-tempstorage'] =
      data: {}
      meta: {}
    @_super arguments...

  tempStorage: (key) ->
    if Ember.isPresent key
      attributes: @['-dsc-tempstorage']["data"][key]
      metadata: @['-dsc-tempstorage']["meta"][key]
    else
      output = Ember.A []
      for key, value of @['-dsc-tempstorage']["data"]
        output.pushObject
          attributes: value
          metadata: @['-dsc-tempstorage']["meta"][key]
      output

  save: (opts={}) ->
    { disableStrategy: nostrat } = opts
    if nostrat
      @_super()
    else
      operation = calculateOperation @
      strategy = @store.strategyFor @constructor.typeKey, operation
      evaluation = strategy.runEval @ if strategy?
      promiseLift evaluation
      .then => @save disableStrategy: true


`export default Base`