`import Ember from 'ember'`
# No TypeClass concept in JS, so here is just a brute-force
# implementation of instance Arrow Promise

# Strictly speaking, this is also an instance of ArrowChoice

promiseLift = (x) ->
  return x if promiseLike x
  new Ember.RSVP.Promise (resolve) -> resolve x

promiseLike = (x) ->
  x? and isfun x.then

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

# >>= (or >>>) in haskell
compose = (f, g) ->
  new Arrows (x) ->
    lift(f).run(x).then (x) -> lift(g).run x

composeResolve = (f, g) ->
  compose f, lift(g).fork id 

composeReject = (f, g) ->
  compose f, id.fork g

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

# +++ aka split in haskell
fork = (f, g) ->
  new Arrows (either) ->
    if either.isGood
      lift(f).run either.payload
    else
      lift(g).run either.payload

truthy = (x) ->
  return false if Ember.isBlank x
  return false if x is false
  true

# A macro for writing either forks
# polarize takes a yes/no function
# then wraps the parameter to the 
# yes/no in an either
ifA = polarize = (f) ->
  new Arrows (x) ->
    lift(f).run x
    .then (successful) -> if truthy(successful) then Either.resolve(x) else Either.reject(x)
    .catch -> Either.reject x

debugLog = (x) ->
  console.log x
  x

class Either
  @resolve = (x) ->
    return x if x.payload? and x.isGood?
    new Either true, x
  @reject = (x) ->
    return x if x.payload? and x.isGood?
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
  @lift = lift
  @liftA = lift
  @promiseLift = promiseLift
  @polarize = polarize
  constructor: (x) ->
    if isfun x
      @core = x
    else
      @core = -> x
  run: ->
    promiseLift @core arguments...
  compose: (f) ->
    compose @, f
  composeResolve: (f) ->
    composeResolve @, f
  composeReject: (f) ->
    composeReject @, f
  fork: (f) ->
    fork @, f
  elseA: (f) ->
    fork @, f
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

`export default Arrows`
`export { 
  lift,
  liftA,
  polarize,
  ifA,
  id,
  Either,
  debugLog,
  arrowLike,
  promiseLike
}`