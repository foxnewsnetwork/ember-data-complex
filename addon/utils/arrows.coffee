`import Ember from 'ember'`
# No TypeClass concept in JS, so here is just a brute-force
# implementation of instance Arrow Promise

# Strictly speaking, this is also an instance of ArrowChoice

promiseLift = (x) ->
  return x if promiseLike x
  new Ember.RSVP.Promise (resolve) -> resolve x

promiseLike = (x) ->
  x? and isfun x.then

# so xs can be a promise to an array or
# an array of promises and values
# and it ALWAYS returns a promise to an array of values
promiseMap = (xs, predicate) ->
  promiseLift xs
  .then (xs) ->
    xs.map (x) -> promiseLift predicate x
  .then (promises) ->
    Ember.RSVP.all promises

lift = liftA = (x) ->
  return x if arrowLike x
  new Arrows x

arrowLike = (x) ->
  x? and
  isfun(x.compose) and
  isfun(x.dobind) and
  isfun(x.fork)

isfun = (f) ->
  f? and typeof f is 'function'

fmap = (f, g) ->
  new Arrows (x) ->
    lift(f).run(x).then (xs) ->
      promiseMap xs, (x) -> lift(g).run x

# >>= (or >>>) in haskell
compose = (f, g) ->
  new Arrows (x) ->
    lift(f).run(x).then (x) -> lift(g).run x

composeResolve = (f, g) ->
  compose f, lift(g).split id 

composeReject = (f, g) ->
  compose f, id.split g

# >> in haskell, it's called bind in haskell
# but bind in js means something else, so it's
# dobind here
dobind = (f, g) ->
  new Arrows (x) ->
    lift(f).run(x)
    .then (x1) -> 
      lift(g).run(x1)
      .then (_) ->
        promiseLift x1


dobindResolve = (f, g) ->
  dobind f, lift(g).fork(id)

dobindReject = (f, g) ->
  dobind f, id.fork g

fanin = fork = (f, g) ->
  new Arrows (either) ->
    if either.isGood
      lift(f).run either.payload
    else
      lift(g).run either.payload

# fork, but retains the either
split = (f, g) ->
  new Arrows (either) ->
    if either.isGood
      lift(f).run(either.payload).then Either.resolve
    else
      lift(g).run(either.payload).then Either.reject

truthy = (x) ->
  return false if Ember.isBlank x
  return false if x is false
  return false if x instanceof Error
  true

ifA = (f) ->
  new Arrows (x) ->
    promiseLift(x)
    .then (x2) -> lift(f).run x2
    .then (success) -> if truthy(success) then Either.resolve(success) else Either.reject(success)
    .catch (failure) -> Either.reject failure
  
polarize = (f) ->
  new Arrows (x) ->
    promiseLift(x)
    .then (x) -> lift(f).run x
    .then (successful) -> if truthy(successful) then Either.resolve(x) else Either.reject(x)
    .catch -> Either.reject x

debugLog = (x) ->
  console.log x
  x

class Either
  @resolve = (x) ->
    return x if x? and x.payload? and x.isGood?
    new Either true, x
  @reject = (x) ->
    return x if x? and x.payload? and x.isGood?
    new Either false, x
  constructor: (@isGood, @payload) ->
  isResolved: -> @isGood
  isRejected: -> not @isGood

class Arrows
  @resolve = Either.resolve
  @reject = Either.reject
  @isfun = isfun
  @arrowLike = arrowLike
  @promiseLike = promiseLike
  @ifA = ifA
  @lift = lift
  @liftA = lift
  @promiseLift = promiseLift
  @polarize = polarize
  @truthy = truthy
  constructor: (x) ->
    if isfun x
      @core = x
    else
      @core = -> x
  run: ->
    promiseLift @core arguments...
  end: ->
    @compose(Arrows.uneither).run arguments
  compose: (f) ->
    compose @, f
  composeResolve: (f) ->
    composeResolve @, f
  composeReject: (f) ->
    composeReject @, f
  fmap: (f) ->
    fmap @, f
  fork: (f) ->
    fork @, f
  fanin: ->
    @fork arguments...
  split: (f) ->
    split @, f
  thenA: (f) ->
    composeResolve @, f
  elseA: (f) ->
    composeReject @, f
  dobind: (f) ->
    dobind @, f
  await: (f) ->
    dobind @, f
  dobindResolve: (f) ->
    dobindResolve @, f
  dobindReject: (f) ->
    dobindReject @, f

id = lift (x) -> x
Arrows.id = id
Arrows.uneither = id.fanin id

`export default Arrows`
`export {
  Arrows,
  lift,
  liftA,
  polarize,
  ifA,
  id,
  Either,
  debugLog,
  arrowLike,
  promiseLike,
  promiseLift,
  isfun,
  truthy
}`