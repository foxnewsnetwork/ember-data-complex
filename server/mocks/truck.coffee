express = require 'express'
bodyParser = require 'body-parser'
router = express.Router()

router.use bodyParser.json()
router.use bodyParser.urlencoded extended: true
Core = 
  id: "master-1"
  bravoId: "bravo-1"
  charlieId: "charlie-1"
  deltaId: "delta-1"
  gammaId: "gamma-1"

class Truck
  _count = 1
  @trucks = [Core]
  @create = (params) ->
    _count += 1
    params["id"] = "master-#{_count}"
    truck = new Truck params
    Truck.trucks.push truck
    truck
  constructor: (id: @id, bravoId: @bravoId, charlieId: @charlieId) ->

first = ([out, ...]) -> out

findById = (xs, id) ->
  first xs.filter (x) -> x.id.toString() is id

router.get '/', (req, res) ->
  res.send trucks: Truck.trucks

router.post '/', (req, res) ->
  res.send truck: Truck.create req.body.truck

router.get '/:id', (req, res) ->
  truck = findById(Truck.trucks, req.params.id.trim())
  if truck?
    res.send truck: truck
  else
    res.status(404).end()

router.put '/:id', (req, res) ->
  truck = findById(Truck.trucks, req.params.id.trim())
  if truck?
    res.send truck: truck
  else
    res.status(404).end()

router.delete '/:id', (req, res) ->
  res.status(204).end()

module.exports = (app) ->
  app.use '/master/trucks', router