filterComputedProperties = (model, polarize) ->
  props = []
  model.constructor.eachComputedProperty (ctx, propName, meta) ->
    if polarize ctx, propName, meta
      props.push propName: propName, meta: meta
  props

class CPF
  @filter = filterComputedProperties
`export default CPF`
`export { filterComputedProperties }`