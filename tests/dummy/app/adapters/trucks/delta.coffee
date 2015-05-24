`import DS from 'ember-data'`

TrucksDeltaAdapter = DS.ActiveModelAdapter.extend
  namespace: 'delta'
  pathForType: (type) ->
    @_super "truck"

`export default TrucksDeltaAdapter`