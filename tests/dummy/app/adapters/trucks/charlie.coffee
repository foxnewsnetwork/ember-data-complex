`import Ember from 'ember'`
`import DS from 'ember-data'`
Core = 
  id: "charlie-420"
  licensePlate: "hype-4231"
  createdAt: new Date "Feb 23, 2044"

Fixture =
  truck: Core

Fixtures = 
  trucks: [Core]

TrucksCharlieAdapter = DS.RESTAdapter.extend
  pathForType: (type) ->
    [types..., _] = type.split("/")
    @_super types.join "/"
  find: ->
    new Ember.RSVP.Promise (resolve) -> resolve Fixture

  findAll: ->
    new Ember.RSVP.Promise (resolve) -> resolve Fixtures

`export default TrucksCharlieAdapter`