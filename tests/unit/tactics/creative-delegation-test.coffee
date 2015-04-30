`import { test, moduleFor } from 'ember-qunit'`

moduleFor 'strategie:truck', 'CreativeDelegationTactic',
  needs: ['model:truck', 'model:trucks/bravo', 'model:trucks/charlie']

test 'it exists', (assert) ->
  strat = @subject()
  assert.ok strat?
  assert.equal typeof strat.beforeCreate, 'function'  