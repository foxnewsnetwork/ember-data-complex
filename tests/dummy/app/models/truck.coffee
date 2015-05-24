`import Ember from 'ember'`
`import DS from 'ember-data'`
`import DSC from 'ember-data-complex'`

Truck = DSC.ModelComplex.extend
  # bravo: DSC.Macros.through "trucks/bravo", "bravoId"
  # charlie: DSC.Macros.through "trucks/charlie", "charlieId"
  bravoId: DS.attr "string"
  charlieId: DS.attr "string"
  deltaId: DS.attr "string"
  bravo: DSC.belongsTo "trucks/bravo", foreignKey: "bravoId"
  charlie: DSC.belongsTo "trucks/charlie", foreignKey: "charlieId"
  delta: DSC.belongsTo2 "trucks/delta", foreignKey: "deltaId", promiseField: "deltaPromise"
  gamma: DSC.belongsTo2 "trucks/gamma", foreignKey: "gammaId", promiseField: "gammaPromise"

`export default Truck`