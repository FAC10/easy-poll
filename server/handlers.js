const MongoUtil = require('./mongoUtil.js')

module.exports = handlers = {}

handlers.createPoll = (req, res) => {
  // receives json data for new poll
  // adds to db
  // returns poll
  const db = MongoUtil.getDb()
  const polls = db.collection('polls')
  // create id
  const poll = req.body
  // add to db
  polls.insert(poll, (err, result) => {
    if (err) {
      return res.send(err)
    }
    res.send(poll)
  })
}

handlers.getPoll = (req, res) => {
  // receives id in url params
  // returns poll data
  const db = MongoUtil.getDb()
  const polls = db.collection('polls')
  const id = req.params.id
  // get question by id
  polls.find({id}).toArray((err, polls) => {
    if (err) {
      return res.send(err)
    } 
    // sends back array for now
    res.send(polls)
  })
}

handlers.vote = (req, res) => {
  // receives answer index to increment inside req.body {index}
  // gets poll index from url params
  // increments answer vote count
  // sends back updated poll
  const db = MongoUtil.getDb()
  const polls = db.collection('polls')
  // get poll id from url
  const id = req.params.id
  // get answer index from req body
  const { index } = req.body
  // update vote count for answer with given index
  polls.findOneAndUpdate(
    {id},
    {$inc: { [`answers.${index}.votes`]: 1}},
    {returnOriginal: false},
    (err, poll) => {
      if (err) {
        return res.send(err)
      }
      // send back updated poll
      res.send(poll)
  })
}
