`import Ember from 'ember'`
`import { promiseLift } from '../utils/arrows'`
`import { asyncMap } from '../utils/async'`
`import { filterComputedProperties } from '../utils/cpf'`

fetchPromiseToRelationships = (model) ->
  filterComputedProperties model, (ctx, propName, meta) -> meta.relationType is "complex-promise-to"
  .map ({propName}) -> propName

ForceWaitTactic = Ember.Mixin.create
  onPush: (masterPromise) ->
    promiseLift masterPromise
    .then (master) =>
      promiseFields = @get "waitFor"
      promiseFields ?= fetchPromiseToRelationships master
      asyncMap @, promiseFields, (field) -> master.get field

`export default ForceWaitTactic`