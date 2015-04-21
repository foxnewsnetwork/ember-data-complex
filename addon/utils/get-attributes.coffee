`import Ember from 'ember'`

getAttributes = (model) ->
  output = {}
  model.eachAttribute (name, meta) ->
    return if name is "id"
    output[name] = Ember.get model, name
  output
  
`export default getAttributes`