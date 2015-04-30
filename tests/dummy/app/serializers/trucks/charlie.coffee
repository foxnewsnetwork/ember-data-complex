`import DS from 'ember-data'`

CharlieSerializer = DS.ActiveModelSerializer.extend
  serializeIntoHash: (data, type, snapshot, options) ->
    data["truck"] = @serialize snapshot, options
  normalizePayload: (payload) ->
    for key, value of payload
      payload["trucks/charlie"] = value
      delete payload[key]
    payload

`export default CharlieSerializer`
