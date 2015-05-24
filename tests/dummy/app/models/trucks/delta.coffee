`import DS from 'ember-data'`

TrucksDelta = DS.Model.extend
  songName: DS.attr "string" # delta
  artist: DS.attr "string" # delta

`export default TrucksDelta`