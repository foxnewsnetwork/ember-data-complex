`import Arrows from 'ember-data-complex/utils/arrows'`
`import Ember from 'ember'`
`import { module, test } from 'qunit'`

module 'Arrows'

delay = (t, f) ->
  new Ember.RSVP.Promise (resolve) ->
    Ember.run.later null, (-> resolve f()), t

# Replace this with your real tests.
test 'it exists', (assert) ->
  result = Arrows
  assert.ok result

test 'vanilla lift', (assert) ->
  five = Arrows.lift 5
  assert.ok five
  assert.ok five.run
  assert.ok Arrows.arrowLike five
  assert.equal typeof five.run, "function"
  five.run().then (result) ->
    assert.equal result, 5

test 'function lift', (assert) ->
  five = Arrows.lift -> 5
  assert.ok Arrows.arrowLike five
  five.run().then (result) ->
    assert.equal result, 5

test 'function promise lift', (assert) ->
  five = Arrows.lift -> new Ember.RSVP.Promise (resolve) -> resolve 5
  assert.ok Arrows.arrowLike five
  five.run().then (result) ->
    assert.equal result, 5

test 'promise lift', (assert) ->
  five = Arrows.lift new Ember.RSVP.Promise (resolve) -> resolve 5
  assert.ok Arrows.arrowLike five
  five.run().then (result) ->
    assert.equal result, 5

test 'arity 2 lift', (assert) ->
  plus3 = Arrows.lift (x) -> x + 3
  assert.ok Arrows.arrowLike plus3
  plus3.run 3
  .then (actual) ->
    assert.equal actual, 6

test 'compose', (assert) ->
  five = Arrows.lift 5
  plus3 = Arrows.lift (x) -> x + 3
  fiveplus3 = five.compose plus3
  fiveplus3.run().then (actual) ->
    assert.equal actual, 8

test 'lengthy composition', (assert) ->
  plus3 = Arrows.lift (x) -> x + 3
  minus2 = Arrows.lift (x) -> x - 2
  times4 = Arrows.lift (x) -> x * 4
  transform = plus3.compose(minus2).compose(times4)
  transform.run(10).then (actual) ->
    assert.equal actual, 44

test 'dobind', (assert) ->
  five = Arrows.lift 5
  times2 = Arrows.lift (x) -> x * 2
  plusInfinity = Arrows.lift (x) -> x + Infinity
  transform = five.dobind(times2).dobind(plusInfinity)
  transform.run().then (actual) ->
    assert.equal actual, 5

test 'promise composition', (assert) ->
  plus3 = Arrows.lift (x) -> delay 15, -> x + 3
  minus2 = Arrows.lift (x) -> delay 25, -> x - 2
  times4 = Arrows.lift (x) -> delay 15, -> x * 4
  transform = plus3.compose(minus2).compose(times4)
  transform.run(10).then (actual) ->
    assert.equal actual, 44

test 'promise composition sequence', (assert) ->
  saydaddy = Arrows.lift (x) -> delay 15, -> x + " daddy"
  sayno = Arrows.lift (x) -> delay 45, -> x + " no"
  saypls = Arrows.lift (x) -> delay 15, -> x + " please"
  transform = saydaddy.compose(sayno).compose(saypls)
  transform.run("it's grape time!").then (actual) ->
    assert.equal actual, "it's grape time! daddy no please"

test 'fork', (assert) ->
  decider = Arrows.lift (x) -> if x < 5 then Arrows.resolve(x) else Arrows.reject(x)
  times2 = Arrows.lift (x) -> x * 2
  plus4 = Arrows.lift (x) -> x + 4
  transform = decider.compose times2.fork plus4
  transform.run(1).then (actual) ->
    assert.equal actual, 2
  transform.run(2).then (actual) ->
    assert.equal actual, 4
  transform.run(3).then (actual) ->
    assert.equal actual, 6
  transform.run(4).then (actual) ->
    assert.equal actual, 8
  transform.run(5).then (actual) ->
    assert.equal actual, 9
  transform.run(6).then (actual) ->
    assert.equal actual, 10
  transform.run(7).then (actual) ->
    assert.equal actual, 11

test 'delayed fork', (assert) ->
  decider = Arrows.lift (x) -> delay 44, -> if x < 5 then Arrows.resolve(x) else Arrows.reject(x)
  times2 = Arrows.lift (x) -> x * 2
  plus4 = Arrows.lift (x) -> delay 10, -> x + 4
  transform = decider.compose times2.fork plus4
  transform.run(1).then (actual) ->
    assert.equal actual, 2
  transform.run(2).then (actual) ->
    assert.equal actual, 4
  transform.run(3).then (actual) ->
    assert.equal actual, 6
  transform.run(4).then (actual) ->
    assert.equal actual, 8
  transform.run(5).then (actual) ->
    assert.equal actual, 9
  transform.run(6).then (actual) ->
    assert.equal actual, 10
  transform.run(7).then (actual) ->
    assert.equal actual, 11

test 'polarize', (assert) ->
  decider = Arrows.polarize (x) -> x is 'Jimmy Fallon'
  boring = Arrows.lift (x) -> delay 10, -> x + ': only popular because women like him'
  funny = Arrows.lift (x) -> x + ": is actually funny"
  transform = decider.compose boring.fork funny
  transform.run("Conan O'brien").then (actual) ->
    assert.equal actual, "Conan O'brien: is actually funny"
  transform.run("Jimmy Fallon").then (actual) ->
    assert.equal actual, "Jimmy Fallon: only popular because women like him"

test 'delayed polarize', (assert) ->
  decider = Arrows.polarize (x) -> delay 76, -> x is 'Jimmy Fallon'
  boring = Arrows.lift (x) -> delay 10, -> x + ': only popular because women like him'
  funny = Arrows.lift (x) -> x + ": is actually funny"
  transform = decider.compose boring.fork funny
  transform.run("Conan O'brien").then (actual) ->
    assert.equal actual, "Conan O'brien: is actually funny"
  transform.run("Jimmy Fallon").then (actual) ->
    assert.equal actual, "Jimmy Fallon: only popular because women like him"

test 'id arrow', (assert) ->
  Arrows.id.run("dogs").then (dogs) ->
    assert.equal dogs, "dogs"

test 'dobind fork', (assert) ->
  decider = Arrows.polarize (x) -> x is "success"
  success = Arrows.lift (x) -> assert.equal x, "success"
  failure = Arrows.lift (x) -> assert.equal x, "failure"
  transform = decider.dobind success.fork failure
  Arrows.lift("success").dobind(transform).run().then (actual) ->
    assert.equal actual, "success"
  Arrows.lift("failure").dobind(transform).run().then (actual) ->
    assert.equal actual, "failure"

test 'dobindReject', (assert) ->
  kimmel = Arrows.lift "Jimmy Kimmel"
  fallon = Arrows.lift "Jimmy Fallon"
  decider = Arrows.polarize (x) -> delay 76, -> x is 'Jimmy Fallon'
  funny = Arrows.lift (x) -> assert.equal x, "Jimmy Kimmel"
  transform = decider.dobindReject funny
  kimmel.dobind(transform).run().then (actual) ->
    assert.equal actual, "Jimmy Kimmel"
  fallon.dobind(transform).run().then (actual) ->
    assert.equal actual, "Jimmy Fallon"

test 'dobindResolve', (assert) ->
  gold = Arrows.lift "au"
  silver = Arrows.lift "ag"
  decider = Arrows.polarize (el) -> el is "au"
  dostuff = Arrows.lift (x) -> assert.equal x, "au"
  transmute = Arrows.lift (x) -> x + "cl2"
  alchemy = gold.dobind(decider).dobindResolve(dostuff).dobind(transmute).dobind(dostuff)
  agchemy = silver.dobind(decider).dobindResolve dostuff.dobind(transmute).dobind(dostuff)
  alchemy.run().then (actual) ->
    assert.equal actual, "au"
  agchemy.run().then (actual) ->
    assert.equal actual, "ag"
