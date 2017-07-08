const tape = require('tape')
const request = require('supertest')

const app = require('../server/server.js')

tape('GET request to /', t => {
  request(app)
    .get('/')
    .end((err, res) => {
      if (err) throw err
      t.equal(res.status, 200, 'should return status code 200')
      t.ok(res.text.includes(
        '<script type="text/javascript" src="./poll.js"></script>'),
        'should return html page containing script for poll app'
        )
      t.end()
    })
})

