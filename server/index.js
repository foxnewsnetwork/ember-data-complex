// To use it create some files under `mocks/`
// e.g. `server/mocks/ember-hamsters.js`
//
// module.exports = function(app) {
//   app.get('/ember-hamsters', function(req, res) {
//     res.send('hello');
//   });
// };

module.exports = function(app) {
  var globSync   = require('glob').sync;
  require('coffee-script').register();
  var mocks      = globSync('./mocks/**/*.js', { cwd: __dirname }).map(require);
  var cocks      = globSync('./mocks/**/*.coffee', { cwd: __dirname }).map(require);
  var proxies    = globSync('./proxies/**/*.coffee', { cwd: __dirname }).map(require);

  // Log proxy requests
  var morgan  = require('morgan');
  app.use(morgan('dev'));

  mocks.forEach(function(route) { route(app); });
  cocks.forEach(function(route) { route(app); });
  proxies.forEach(function(route) { route(app); });
};

