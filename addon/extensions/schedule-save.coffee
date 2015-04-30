`import Ember from 'ember'`
`import { promiseLift } from '../utils/arrows'`

get = Ember.get

calculateOperation = (record) ->
  switch
    when get(record, "currentState.stateName") is "root.deleted.saved" then null
    when get(record, "isNew") then "beforeCreate"
    when get(record, "isDeleted") then "beforeDestroy"
    else "beforeUpdate"

scheduleSave = (record, resolver) ->
  operation = calculateOperation record
  strategy = @strategyFor record.constructor.typeKey, operation
  evaluation = strategy.runEval record if strategy?
  promiseLift evaluation
  .then =>
    @_super arguments...

`export default scheduleSave`