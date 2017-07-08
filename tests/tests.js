const tape = require('tape')

const app = require('../server/server.js')

tape('basic passing test', t => {
  t.ok(true, 'true should be truthy.')
  t.end()
})