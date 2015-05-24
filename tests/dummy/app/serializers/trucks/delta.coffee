`import DS from 'ember-data'`

DeltaSerializer = DS.ActiveModelSerializer.extend
  serializeIntoHash: (data, type, snapshot, options) ->
    data["truck"] = @serialize snapshot, options
  normalizePayload: (payload) ->
    for key, value of payload
      payload["trucks/delta"] = value
      delete payload[key]
    payload

`export default DeltaSerializer`
