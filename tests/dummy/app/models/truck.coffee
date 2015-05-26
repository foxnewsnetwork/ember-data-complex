`import Ember from 'ember'`
`import DS from 'ember-data'`
`import DSC from 'ember-data-complex'`

Truck = DSC.ModelComplex.extend
  bravoId: DS.attr "string"
  charlieId: DS.attr "string"
  deltaId: DS.attr "string"
  gammaId: DS.attr "string"
  bravo: DSC.belongsTo "trucks/bravo", foreignKey: "bravoId"
  charlie: DSC.belongsTo "trucks/charlie", foreignKey: "charlieId"
  delta: DSC.belongsTo2 "trucks/delta", foreignKey: "deltaId", promiseField: "deltaPromise"
  gammaPromise: DSC.promiseTo "trucks/gamma", foreignKey: "gammaId", foreignField: "gamma"

  gammaSongName: Ember.computed.alias "gamma.songName"

`export default Truck`