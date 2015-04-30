`import DS from 'ember-data'`

TrucksCharlieAdapter = DS.ActiveModelAdapter.extend
  namespace: 'charlie'
  pathForType: (type) ->
    @_super "truck"

`export default TrucksCharlieAdapter`