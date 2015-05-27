push = (typeObj, data, _partial) ->
  record = @_super arguments...
  if strategy = @strategyFor typeObj.typeKey, "onPush"
    return strategy.runEval record
  record

`export default push`