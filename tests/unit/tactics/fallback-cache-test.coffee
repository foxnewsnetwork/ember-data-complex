`import { test, moduleFor } from 'ember-qunit'`

moduleFor 'strategie:truck', 'FallbackCacheTactic'

test 'it exists', (assert) ->
  strat = @subject()
  # store = @store()
  assert.ok strat?
