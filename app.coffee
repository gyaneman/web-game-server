express = require('express')
bodyParser = require 'body-parser'
app = express()
http = require('http').Server(app)
io = require('socket.io')(http)
path = require('path')
mongodb = require('mongodb')

app.set('views', path.join(__dirname, 'views'))
app.set('view engine', 'jade')
app.use(express.static(path.join(__dirname, 'build')))
app.use(bodyParser.json())

rooms = null
mongodb.MongoClient.connect 'mongodb://localhost/web-game', (err, database) ->
  if err != null && database == null
    console.log err, database
    return
  rooms = database.collection 'rooms'
  console.log 'mongodb: connected'

defaultRooms = ['general']
app.get '/', (req, res) ->
  console.log 'request: /'
  res.render('index')

app.get '/create', (req, res) ->
  console.log 'request: /create'
  res.render('room-create')

app.get '/room/list', (req, res) ->
  res.contentType('application/json')
  resData = defaultRooms
  json = JSON.stringify(resData)
  # res.send(json)
  rooms.find().toArray (err, items) ->
    res.send(items)

app.post '/room/create', (req, res) ->
  newRoom = req.body
  console.log newRoom
  res.send {result: true}
  #rooms.findOne {name: newRoomName}, (err, data) ->
  #  console.log(data)

http.listen 3000, ->
  console.log('listening on *:3000')


io.on 'connection', (socket) ->
  console.log('a user connected');
  socket.on 'chat message', (msg) ->
    io.emit('chat message', msg);

  socket.on 'disconnect', ->
    console.log('disconnected');
