`import DS from 'ember-data'`

TruckAdapter = DS.ActiveModelAdapter.extend
  namespace: 'master'

  createRecord: (store, type, snapshot) ->
    @_super arguments...
    
`export default TruckAdapter`