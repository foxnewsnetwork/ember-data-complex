`import Ember from 'ember'`
`import DS from 'ember-data'`
Core = 
  id: 2
  bravoId: "bravo-666"
  charlieId: "charlie-420"

Fixture =
  truck: Core

Fixtures = 
  trucks: [Core]

TruckAdapter = DS.RESTAdapter.extend
  find: ->
    new Ember.RSVP.Promise (resolve) -> resolve Fixture

  findAll: ->
    new Ember.RSVP.Promise (resolve) -> resolve Fixtures

`export default TruckAdapter`