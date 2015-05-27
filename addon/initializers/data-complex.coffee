`import Ember from 'ember'`
`import DS from 'ember-data'`
`import { findAll, findById, findByQuery } from '../extensions/finders'`
`import strategyFor from '../extensions/strategy-for'`
`import push from '../extensions/push'`

initialize = (ctn, app) ->
  unless DS.Store::_emberDataComplexPatched is true
    DS.Store.reopen
      _emberDataComplexPatched: true
      push: push
      findAll: findAll
      findById: findById
      findByQuery: findByQuery
      strategyFor: strategyFor

DataComplexInitializer =
  name: 'data-complex'
  before: 'store'
  initialize: initialize

`export {initialize}`
`export default DataComplexInitializer`
