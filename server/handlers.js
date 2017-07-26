module.exports = handlers = {}

handlers.createPoll = (req, res) => {
  // create id
  console.log(req.body)
  // add to db
  // return id!!!
  res.send('m0ckQu3st1OnId')
}

handlers.getPoll = (req, res) => {
  console.log(req.params.id)
  // get question by id
  // send back question
  res.send('test')
}

handlers.vote = (req, res) => {
  // get question by id
  console.log(req.params.id)
  // get answer index from req body
  console.log(req.body)
  // update question
  // send back question
}
