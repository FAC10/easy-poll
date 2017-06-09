# easy-poll
Quick and easy poll app using elm.

### How to run locally
```bash
git clone https://github.com/FAC10/easy-poll && cd easy-poll
npm install

# Build Elm files and start server
npm start

# Open site in browser
open "http://127.0.0.1:4000/"
```

### How to run tests
```
elm test
```

### Features
- Submit poll and store it in a database with a POST request
- Retrieve poll with AJAX using Elm by id
- Smart answer autofill (tm)
