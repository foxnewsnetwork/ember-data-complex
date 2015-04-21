`import Ember from 'ember'`
`import DS from 'ember-data'`
`import DSC from 'ember-data-complex'`

Truck = DS.Model.extend
  bravoId: DS.attr "string"
  charlieId: DS.attr "string"

  bravo: DSC.Macros.through "trucks/bravo", "bravoId"

  charlie: DSC.Macros.through "trucks/charlie", "charlieId"

`export default Truck`