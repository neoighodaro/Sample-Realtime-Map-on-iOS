//
// Load the required libraries
//
let Pusher     = require('pusher');
let express    = require('express');
let bodyParser = require('body-parser');

//
// initialise express and pusher
//
let app        = express();
let pusher     = new Pusher(require('./config.js'));

//
// Middlewares
//
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));


//
// Generates 20 simulated GPS coords and sends to Pusher
//
app.post('/simulate', (req, res, next) => {
  let loopCount = 0;
  let operator = 0.001000
  let longitude = parseFloat(req.body.longitude)
  let latitude  = parseFloat(req.body.latitude)

  let sendToPusher = setInterval(() => {
    loopCount++;

    // Calculate new coordinates and round to 6 decimal places...
    longitude = parseFloat((longitude + operator).toFixed(7))
    latitude  = parseFloat((latitude - operator).toFixed(7))

    // Send to pusher
    pusher.trigger('mapCoordinates', 'update', {longitude, latitude})

    if (loopCount === 20) {
      clearInterval(sendToPusher)
    }
  }, 2000);
  res.json({success: 200})
})


//
// Index
//
app.get('/', (req, res) => {
  res.json("It works!");
});


//
// Error Handling
//
app.use((req, res, next) => {
    let err = new Error('Not Found');
    err.status = 404;
    next(err);
});


//
// Serve app
//
app.listen(4000, function() {
    console.log('App listening on port 4000!')
});
