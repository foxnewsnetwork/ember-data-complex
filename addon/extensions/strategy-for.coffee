strategyFor = (key) ->
  if typeof key is "string"
    # Ember resolver defaults to just adding an "s"
    # and the only way to get proper pluralization
    # is extending the resolver which is we can't
    # do from an addon.
    strategy = @container.lookupFactory "strategie:#{key}"
  else
    strategy = key

  if strategy?
    strategy.store ?= @
    strategy.container ?= @container
  strategy

`export default strategyFor`