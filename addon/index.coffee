`import Strategy from './models/strategy'`
`import FallbackCacheTactic from './tactics/fallback-cache'`
`import CreativeDelegationTactic from './tactics/creative-delegation'`
`import Macros from './utils/macros'`
`import getAttributes from './utils/get-attributes'`
`import Arrows from './utils/arrows'`
`import Base from './models/base'`
`import async from './utils/async'`

class DSC
  @ModelComplex = Base
  @Strategy = Strategy
  @FallbackCacheTactic = FallbackCacheTactic
  @CreativeDelegationTactic = CreativeDelegationTactic
  @Macros = Macros
  @Arrows = Arrows
  @truthy = Arrows.truthy
  @getAttributes = getAttributes
  @async = async
  @ifA = Arrows.ifA
  @belongsTo = Macros.through
  @belongsTo2 = Macros.asyncBelongsTo
  @promiseTo = Macros.promiseTo
  @foreignModel = Macros.asyncBelongsTo
  @foreignPromise = Macros.promiseTo
`export default DSC`