`import Strategy from './models/strategy'`
`import Macros from './utils/macros'`
`import getAttributes from './utils/get-attributes'`
`import Arrows from './utils/arrows'`
`import Base from './models/base'`

class DSC
  @ModelComplex = Base
  @Strategy = Strategy
  @Macros = Macros
  @Arrows = Arrows
  @getAttributes = getAttributes
  
`export default DSC`