`import Strategy from './models/strategy'`
`import Macros from './utils/macros'`
`import getAttributes from './utils/get-attributes'`
`import Arrows from './utils/arrows'`
`import Base from './models/base'`
`import async from './utils/async'`

class DSC
  @ModelComplex = Base
  @Strategy = Strategy
  @Macros = Macros
  @Arrows = Arrows
  @truthy = Arrows.truthy
  @getAttributes = getAttributes
  @async = async
  @ifA = Arrows.ifA
  
`export default DSC`