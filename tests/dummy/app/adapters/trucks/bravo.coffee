`import Ember from 'ember'`
`import DS from 'ember-data'`
Core = 
  id: "bravo-666"
  location: "applebees"

Fixture =
  truck: Core

Fixtures = 
  trucks: [Core]

TrucksBravoAdapter = DS.RESTAdapter.extend
  find: ->
    new Ember.RSVP.Promise (resolve) -> resolve Fixture

  findAll: ->
    new Ember.RSVP.Promise (resolve) -> resolve Fixtures

`export default TrucksBravoAdapter`