import resolver from './helpers/resolver';
import {
  setResolver
} from 'ember-qunit';
Error.stackTraceLimit = Infinity;
setResolver(resolver);
