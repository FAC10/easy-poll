// credit: https://stackoverflow.com/questions/24621940/how-to-properly-reuse-connection-to-mongodb-across-nodejs-application-and-module

const MongoClient = require('mongodb').MongoClient

const dbUrl = process.env.DB_URL

if (!dbUrl) throw new Error('DB_URL must be set in a .env file')

var _db

module.exports = {

  connect: function(callback) {
    MongoClient.connect(dbUrl, (err, db) => {
      _db = db
      // _db.createCollection("polls", { autoIndexId: false })
      return callback(err)
    })
  },

  getDb: function() {
    return _db
  }
}