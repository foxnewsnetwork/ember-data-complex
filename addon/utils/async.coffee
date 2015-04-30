`import Ember from 'ember'`
`import { polarize, promiseLift, Either, isfun } from './arrows'`

errormsg = """
async expects a generator function, but you passed in something that wasn't a generator.
This could be because you're using CoffeeScript and you forgot to include a yield.
Or it could be you just neglected to include a * in your vanilla pleb-tier javascript.
Or you just passed an object or something weird like that.
"""

assertIterator = (maybeGen) ->
  unless maybeGen? and isfun(maybeGen.next) and isfun(maybeGen.return)
    throw new Error errormsg

makeError = (reason) ->
  e = new Error "Your promise has been rejected because #{JSON.stringify reason}"
  e.reason = reason
  e

asyncCore = (iterator, fulfillment) ->
  assertIterator iterator
  {value: promise, done: done} = iterator.next fulfillment
  return promiseLift promise if done is true
  promiseLift promise
  .then (value) ->
    asyncCore iterator, value
  .catch (reason) ->
    asyncCore iterator, makeError reason

async = (generator) ->
  asyncCore generator()

syncReduce = (init, xs, iterator) ->
  return init if Ember.isBlank xs
  [x, rest...] = xs
  promiseLift init
  .then (init) ->
    iterator(init, x)
  .then (next) ->
    syncReduce next, rest, iterator

asyncMapWimpy = (ctx, xs, cb) ->
  Ember.RSVP.all Ember.EnumerableUtils.map xs, cb, ctx
asyncMap = (ctx, xs, cb) ->
  Ember.RSVP.allSettled Ember.EnumerableUtils.map xs, cb, ctx

`export default async`
`export {
  async,
  syncReduce,
  asyncMap,
  asyncMapWimpy
}`