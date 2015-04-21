# Ember-data-complex

An extension of / set of patterns for the very popular Ember Data to help build data models that require complex adapter / serializer strategy. 

For when you need a model with attributes that come from differing adapters.

## Example

Suppose you're building a locally distributed warehouse application that tracks trucks. In addition to storing trucks on your rails database, you're also real-time sharing them across your app's users via firebase, and, on top of that, you're interested in long term archival storage via amazon s3.

In other words, you need a truck database model that has great real-time data-concurrency, long-term query-able storage, and large file bucket storage. Perhaps if you're Google, you can build such a database, but for the rest of us, we'll need to use 3 different storage options and compose them together in a manageable way on the front end.

Ember Data Complex exposes a pattern and some helpers functions to help you manage your complex data model:

First, write whatever serializers and adapters you'll need
```coffee
# serializers/fires/truck.coffee
FireTruckSerializer = DS.FirebaseSerializer.extend
  ...

# adapters/fires/truck.coffee
FireTruckAdapter = DS.FirebaseAdapter.extend
  ...

# serializers/rails/truck.coffee
RailsTruckSerializer = DS.ActiveModelSerializer.extend
  ...

# adapters/rails/truck.coffee
RailsTruckAdapter = DS.ActiveModelAdapter.extend
  ...

# serializers/s3/truck.coffee
S3TruckSerializer = DS.AmazonS3Serializer.extend
  ...

# adapters/s3/truck.coffee
S3TruckAdapter = DS.AmazonS3Adapter.extend
  ...
```

Next, declare your aristocrat master model:
```coffee
# models/truck.coffee
Truck = DSC.ModelComplex.extend
  fireId: DS.attr "string"
  railsId: DS.attr "string"
  s3Id: DS.attr "string"

  fire: DSC.Macros.through "fires/truck", "fireId"
  rails: DSC.Macros.through "rails/truck", "railsId"
  s3: DSC.Macros.through "s3/truck", "s3id"
```
Here, DSC.Macros.through is just a macro over store.find; it works a lot like DS.belongsTo except it returns a computed property instead of a relationship. This is important because rails/truck and s3/truck have different adapters than truck, so a regular DS relationship won't work.

Next, you'll need to declare your peasant slave models:
```coffee
# models/fires/truck.coffee
Truck = DS.Model.extend
  latitude: DS.attr "number"
  longitude: DS.attr "number"
  licensePlate: DS.attr "string"
  driver: DS.attr "string"

# models/rails/truck.coffee
Truck = DS.Model.extend
  licensePlate: DS.attr "string"
  driver: DS.attr "string"

# models/s3/truck.coffee
Truck = DS.Model.extend
  shippingDocs: DS.attr "file"
  weightPass: DS.attr "file"
```
At this point, you're ready to go and the models you declared will work exactly as you expected

```coffee
truck = @store.find "truck", 33
truck.get("rails").set "driver", "bob"
truck.get("rails").save()
truck.save()
truck.destroy()
```
However, DataComplex allows you to declare strategies regarding how your group of models should be found, saved, updated and destroyed:

```coffee
# strategies/truck.coffee
TruckStrategy = DSC.Strategy.create
  onFind: (masterTruck) ->
    masterTruck.then (truck) ->
      truck.get("fire").then -> truck
    .then (truck) ->
      truck.get("rails").then -> truck
    .then whatever
```
Note that, you should always return a promise from onFind. When that promise resolves (or rejects), DataComplex will automatically resolve out to the original truck you tried to @store.find on.

In this way, you can think of your master truck as a purely lazy data structure and the strategy object as a way of evaluating (aka normal-forming) that lazy structure. If you've done parallel haskell, this is the Eval Monad applied here to front-end models.

## Regarding promises and strategies
For those interested in writing elegant (although newbie-unfriendly) code with promises, it should be noted promises are more than monadic (read about them here: http://en.wikipedia.org/wiki/Monad_(functional_programming) ) they are also an arrow (read about them here: https://www.haskell.org/arrows/ ).

Completely incomprehensible academic horseshit aside, the arrow idea is actually extremely helpful to writing non-cancerous code with promises. DataComplex ships with a small Arrow library to faciliate this.

In continuing with the truck example, you can take advantage of arrows in your strategies:

```coffee
`import { lift, ifA } from 'ember-data-complex/utils/arrows'`

# strategies/truck.coffee
TruckStrategy = DSC.Strategy.create
  attemptFirstTruck: (masterTruck) ->
    @store.find "fires/truck", masterTruck.get "id"
  attemptRailsTruck: (masterTruck) ->
    @store.find "rails/truck", masterTruck.get "id"
  onFind: (masterTruck) ->
    lift masterTruck
    .await ifA @attemptFireTruck.bind(@)
    .await doNothing.elseA @attemptRailsTruck.bind(@)
```
I will probably write up a more involved / explanatory example later, but the idea behind lifting (wrapping into a context) something to an arrow is to be able to employ a bastardized semi-es7-await-syntax control flow to async computations.

## Installation

* `git clone` this repository
* `npm install`
* `bower install`

## Running

* `ember server`
* Visit your app at http://localhost:4200.

## Running Tests

* `ember test`
* `ember test --server`

## Building

* `ember build`

For more information on using ember-cli, visit [http://www.ember-cli.com/](http://www.ember-cli.com/).
