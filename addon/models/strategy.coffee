`import Ember from 'ember'`
`import { promiseLift } from '../utils/arrows'`

Strategy = Ember.Object.extend
  runEval: (promise) ->
    if @[@tactic]? and typeof @[@tactic] is 'function'
      promiseLift @[@tactic] promise
      .then -> promise
    else
      promise
  onFindAll: null
  onFindById: null
  onFindByQuery: null
  onPush: null
  beforeCreate: null
  beforeDestroy: null
  beforeUpdate: null

`export default Strategy`