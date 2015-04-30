strategyFor = (key, tactic) ->
  if typeof key is "string"
    # Ember resolver defaults to just adding an "s"
    # and the only way to get proper pluralization
    # is extending the resolver which is we can't
    # do from an addon.
    strategy = @container.lookupFactory "strategie:#{key}"
  else
    strategy = key
  return unless strategy? and typeof strategy.create is 'function'
  strategy.create
    tactic: tactic
    store: @
    container: @container

`export default strategyFor`