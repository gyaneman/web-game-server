express = require('express')
app = express()
http = require('http').Server(app)
io = require('socket.io')(http)
path = require('path')

app.use(express.static(path.join(__dirname, 'build')))

defaultRooms = ['general']
app.get '/', (req, res) ->
  res.sendfile('index.html')

app.get '/chat/list', (req, res) ->
  res.contentType('application/json')
  resData = defaultRooms
  json = JSON.stringify(resData)
  res.send(json)

http.listen 3000, ->
  console.log('listening on *:3000')


io.on 'connection', (socket) ->
  console.log('a user connected');
  socket.on 'chat message', (msg) ->
    io.emit('chat message', msg);

  socket.on 'disconnect', ->
    console.log('disconnected');
