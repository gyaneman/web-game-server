express = require('express')
bodyParser = require 'body-parser'
app = express()
http = require('http').Server(app)
io = require('socket.io')(http)
path = require('path')
mongodb = require('mongodb')
gamesJson = require('./games.json')

app.set('views', path.join(__dirname, 'views'))
app.set('view engine', 'jade')
app.use(express.static(path.join(__dirname, 'build')))
app.use(bodyParser.json())

loadGameScripts = (gameList) ->
  for game in gameList
    gamePath = './games/' + game.title + '/'
    gameCfg = require(gamePath + 'config.json')
    scriptName = gameCfg.serverScript
    games[game.title] =
      config: gameCfg
      script: require(gamePath + scriptName)
    console.log 'loaded: ' + gamePath

games = []
loadGameScripts gamesJson.games

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
  rooms.find().toArray (err, items) ->
    res.send(items)

app.post '/room/create', (req, res) ->
  res.send createRoom req.body.room


http.listen 3000, ->
  console.log('listening on *:3000')


io.on 'connection', (socket) ->
  console.log('a user connected');
  socket.on 'chat message', (msg) ->
    io.emit('chat message', msg);

  socket.on 'disconnect', ->
    console.log('disconnected');


createRoom = (newRoomData) ->
  if newRoomData.name == ''
    return {result: false}
  if newRoomData.game == ''
    return {result: false}
  if !(newRoomData.maxNum >= 0 && newRoomData.maxNum <= 8)
    return {result: false}
  rooms.findOne {name: newRoomData.name}, (err, data) ->
    if err != null
      return {result: false, error: err}
    if data != null
      return {result: false}
  newRoom =
    name: newRoomData.name
    game: newRoomData.game
    num: 0
    maxNum: newRoomData.maxNum
  rooms.save newRoom, ->
    console.log newRoom
  {result: true, room: newRoom}
