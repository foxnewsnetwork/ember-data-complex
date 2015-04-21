`import DS from 'ember-data'`

BravoSerializer = DS.ActiveModelSerializer.extend
  normalizePayload: (payload) ->
    for key, value of payload
      payload["trucks/bravo"] = value
      delete payload[key]
    payload

`export default BravoSerializer`
