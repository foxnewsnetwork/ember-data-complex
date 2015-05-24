`import DS from 'ember-data'`

TrucksGammaAdapter = DS.ActiveModelAdapter.extend
  namespace: 'gamma'
  pathForType: (type) ->
    @_super "truck"

`export default TrucksGammaAdapter`