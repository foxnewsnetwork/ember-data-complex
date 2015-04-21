`import DS from 'ember-data'`

TrucksCharlie = DS.Model.extend
  licensePlate: DS.attr "string" # charlie
  createdAt: DS.attr "date" # charlie

`export default TrucksCharlie`