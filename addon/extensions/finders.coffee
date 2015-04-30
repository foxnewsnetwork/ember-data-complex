findAll = (type) ->
  output = @_super arguments...
  if strategy = @strategyFor type, "onFindAll"
    return strategy.runEval output
  output

findById = (type) ->
  output = @_super arguments...
  if strategy = @strategyFor type, "onFindById"
    return strategy.runEval output
  output

findByQuery = (type) ->
  output = @_super arguments...
  if strategy = @strategyFor type, "onFindByQuery"
    return strategy.runEval output
  output

class Finders
  @findAll = findAll
  @findById = findById
  @findByQuery = findByQuery

`export default Finders`
`export { 
  findAll,
  findByQuery,
  findById
}`