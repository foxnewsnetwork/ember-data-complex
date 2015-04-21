`import Ember from 'ember'`

Strategy = Ember.Object.extend
  evalProc: -> ->
  onFind: (model) ->
    lift model
    .dobind @evalProc()
    .run()

`export default Strategy`