`import Ember from 'ember'`
`import DS from 'ember-data'`
`import find from '../extensions/find'`
`import strategyFor from '../extensions/strategy-for'`

initialize = (ctn, app) ->
  unless DS.Store::_emberDataComplexPatched is true
    DS.Store.reopen
      _emberDataComplexPatched: true
      find: find
      strategyFor: strategyFor

DataComplexInitializer =
  name: 'data-complex'
  before: 'store'
  initialize: initialize

`export {initialize}`
`export default DataComplexInitializer`
