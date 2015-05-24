`import Ember from 'ember'`

initialize = ->
  i = Ember.Inflector.inflector 
  i.irregular 'delta', 'deltas'
  i.singular /delta/, 'delta'
  

InflectorInitializer =
  name: 'inflector'
  initialize: initialize

`export {initialize}`
`export default InflectorInitializer`
