const path = require('path')
const express = require('express')
const bodyParser = require('body-parser')

const app = express()

app.use(express.static(path.join(__dirname, '../public')))
app.use(bodyParser.json())
app.use(express.static('public'))

// create a new poll
app.post('/questions', (req, res) => {
  // create id
  console.log(req.body)
  // add to db
  // return id!!!
  res.send('m0ckQu3st1OnId')
})

// get poll for voting page
app.get('/questions/:id', (req, res) => {
  console.log(req.params.id)
  // get question by id
  // send back question
  res.send('test')
})

// handle vote and send back results
app.post('/questions/:id/vote', (req, res) => {
  // get question by id
  console.log(req.params.id)
  // get answer index from req body
  console.log(req.body)
  // update question
  // send back question
})

module.exports = app
