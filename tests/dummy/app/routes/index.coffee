`import Ember from 'ember'`
IndexRoute = Ember.Route.extend
  model: ->
    @store.find "truck", "master-1"
`export default IndexRoute`