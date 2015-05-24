`import DS from 'ember-data'`

GammaSerializer = DS.ActiveModelSerializer.extend
  serializeIntoHash: (data, type, snapshot, options) ->
    data["truck"] = @serialize snapshot, options
  normalizePayload: (payload) ->
    for key, value of payload
      payload["trucks/gamma"] = value
      delete payload[key]
    payload

`export default GammaSerializer`
