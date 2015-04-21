find = (type, id, preload) ->
  output = @_super arguments...
  if strategy = @strategyFor type
    return strategy.onFind output
  output
    
`export default find`