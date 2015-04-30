`import DS from 'ember-data'`

BravoSerializer = DS.ActiveModelSerializer.extend
  serializeIntoHash: (data, type, snapshot, options) ->
    data["truck"] = @serialize snapshot, options

  normalizePayload: (payload) ->
    for key, value of payload
      payload["trucks/bravo"] = value
      delete payload[key]
    payload


`export default BravoSerializer`
