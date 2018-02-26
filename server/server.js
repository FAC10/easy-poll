const path = require('path')
const express = require('express')
const bodyParser = require('body-parser')

const handlers = require('./handlers.js')

const baseUrl = process.env.NODE_ENV === 'production'
	? 'https://elm-easy-poll.herokuapp.com'
	: 'http://localhost:4000'

const app = express()

// START OF MESS
// basic templating
const fs = require('fs')
app.get('/', (req, res) => {
	const rawHtml = fs.readFileSync(
		path.join(__dirname, '../public/index.html'),
		{ encoding: 'utf-8' }
	)
	const rendered = rawHtml.replace('{{baseUrl}}', baseUrl)
	res.set('Content-Type', 'text/html')
	res.send(rendered)
})

app.get('/vote', (req, res) => {
	const rawHtml = fs.readFileSync(
		path.join(__dirname, '../public/vote.html'),
		{ encoding: 'utf-8' }
	)
	const rendered = rawHtml.replace('{{baseUrl}}', baseUrl)
	res.set('Content-Type', 'text/html')
	res.send(rendered)
})
// END OF MESS

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
