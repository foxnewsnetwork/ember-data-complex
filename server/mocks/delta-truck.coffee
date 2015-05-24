express = require 'express'
bodyParser = require 'body-parser'
router = express.Router()

router.use bodyParser.json()
router.use bodyParser.urlencoded extended: true
Core = 
  id: "delta-1"
  songName: 'yoshiwara lament'
  artist: 'asa'
class Truck
  _count = 1
  @trucks = [Core]
  @create = (params) ->
    _count += 1
    params["id"] = "delta-#{_count}"
    truck = new Truck params
    Truck.trucks.push truck
    truck
  constructor: (id: @id, songName: @songName, artist: @artist) ->

first = ([out, ...]) -> out

findById = (xs, id) ->
  first xs.filter (x) -> x.id.toString() is id

router.get '/', (req, res) ->
  res.send trucks: Truck.trucks

router.post '/', (req, res) ->
  if req.body.truck['song_name'] is 'clusterfuck'
    res.status(400).end()
  else
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
  app.use '/delta/trucks', router