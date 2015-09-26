express = require('express')
app = express()
http = require('http').Server(app)
io = require('socket.io')(http)
path = require('path')
mongodb = require('mongodb')

app.use(express.static(path.join(__dirname, 'build')))

rooms = null
mongodb.MongoClient.connect 'mongodb://localhost/web-game', (err, database) ->
  if err != null && database == null
    console.log err, database
    return
  rooms = database.collection 'rooms'
  console.log 'mongodb: connected'

defaultRooms = ['general']
app.get '/', (req, res) ->
  res.sendfile('index.html')

app.get '/room/list', (req, res) ->
  res.contentType('application/json')
  resData = defaultRooms
  json = JSON.stringify(resData)
  # res.send(json)
  rooms.find().toArray (err, items) ->
    res.send(items)

app.post '/room/create', (req, res) ->
  newRoomName = req.body.room
  rooms.findOne {name: newRoomName}, (err, data) ->
    console.log(data)

http.listen 3000, ->
  console.log('listening on *:3000')


io.on 'connection', (socket) ->
  console.log('a user connected');
  socket.on 'chat message', (msg) ->
    io.emit('chat message', msg);

  socket.on 'disconnect', ->
    console.log('disconnected');
