filterComputedProperties = (model, polarize) ->
  props = []
  model.constructor.eachComputedProperty (propName, meta) ->
    if polarize propName, meta
      props.push propName: propName, meta: meta
  props

class CPF
  @filter = filterComputedProperties
`export default CPF`
`export { filterComputedProperties }`