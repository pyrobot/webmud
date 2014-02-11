// javascript entry point
require('coffee-script');
if (process.env.NODE_ENV !== 'production') {
	require('coffee-trace');
}
require('./mud/server.coffee');