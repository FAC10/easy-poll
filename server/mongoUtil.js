// credit: https://stackoverflow.com/questions/24621940/how-to-properly-reuse-connection-to-mongodb-across-nodejs-application-and-module

const MongoClient = require('mongodb').MongoClient

var _db

module.exports = {

  connect: function(callback) {
    MongoClient.connect("mongodb://localhost/easypoll", function(err, db) {
      _db = db
      return callback(err)
    })
  },

  getDb: function() {
    return _db
  }
}