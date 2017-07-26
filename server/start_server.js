require('dotenv').config()
const app = require('./server.js')
const MongoClient = require('mongodb').MongoClient
const MongoUtil = require('./mongoUtil.js')

const port = process.env.PORT || 4000

MongoUtil.connect(err => {
  if (err) {
    throw err
  }
  app.listen(port, () => {
  	console.log(`listening on port ${port}`)
  })
})