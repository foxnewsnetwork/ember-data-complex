`import Ember from 'ember'`

getAttributes = (model) ->
  return model unless model? and typeof model.eachAttribute is 'function'
  output = {}
  model.eachAttribute (name, meta) ->
    return if name is "id"
    output[name] = Ember.get model, name
  output
  
`export default getAttributes`