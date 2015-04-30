`import Ember from 'ember'`
`import DSC from 'ember-data-complex'`
`import { debugLog, lift, polarize } from 'ember-data-complex/utils/arrows'`

TruckStrategy = DSC.Strategy.extend DSC.FallbackCacheTactic, DSC.CreativeDelegationTactic,
  order: Ember.A(['bravo', 'charlie'])

`export default TruckStrategy`