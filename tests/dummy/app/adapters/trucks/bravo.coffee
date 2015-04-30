`import DS from 'ember-data'`

TrucksBravoAdapter = DS.ActiveModelAdapter.extend
  namespace: 'bravo'
  pathForType: (type) ->
    @_super "truck"

  allAoiEirSongsSoundTheSame: ->

`export default TrucksBravoAdapter`