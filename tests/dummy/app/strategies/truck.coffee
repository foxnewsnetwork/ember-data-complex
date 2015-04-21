`import DSC from 'ember-data-complex'`
`import { debugLog, lift, polarize } from 'ember-data-complex/utils/arrows'`

TruckStrategy = DSC.Strategy.create
  attemptBravoTruck: ->
    (masterTruck) => 
      @store.find("trucks/bravo", masterTruck.get("bravoId"))

  attemptCharlieTruck: ->
    (masterTruck) =>
      @store.find "trucks/charlie", masterTruck.get("charlieId")

  createBravoFromCharlie: ->
    (charlie) => 
      @store
      .createRecord "trucks/bravo", DSC.getAttributes charlie
      .save()

  fallbackToCharlieTruck: ->
    polarize(@attemptCharlieTruck()).composeResolve @createBravoFromCharlie()

  evalProc: ->
    polarize(@attemptBravoTruck()).dobindReject @fallbackToCharlieTruck()

  onFind: (truck) ->
    lift(truck)
    .dobind @evalProc()
    .run()

`export default TruckStrategy`