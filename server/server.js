const path = require('path')
const express = require('express')
const bodyParser = require('body-parser')

const handlers = require('./handlers.js')

const app = express()

app.use(express.static(path.join(__dirname, '../public')))
app.use(bodyParser.json())
app.use(express.static('public'))

// ROUTES
// create a new poll
app.post('/questions', handlers.createPoll)

// get poll for voting page
app.get('/questions/:id', handlers.getPoll)

// handle vote and send back results
app.post('/questions/:id/vote', handlers.vote)

module.exports = app
