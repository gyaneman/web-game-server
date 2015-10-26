express = require('express')
cookieParser = require('cookie-parser')
bodyParser = require 'body-parser'
app = express()
http = require('http').Server(app)
io = require('socket.io')(http)
path = require('path')
mongodb = require('mongodb')
gamesJson = require('./games.json')
uuid = require('uuid')


app.set('views', path.join(__dirname, 'views'))
app.set('view engine', 'jade')
app.use(express.static(path.join(__dirname, 'build')))
app.use(bodyParser.json())
app.use(cookieParser())



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

rooms = {}
# rooms = null
###
mongodb.MongoClient.connect 'mongodb://localhost/web-game', (err, database) ->
  if err != null && database == null
    console.log err, database
    return
  rooms = database.collection 'rooms'
  console.log 'mongodb: connected'
###

# User list
users = []

defaultRooms = ['general']
app.get '/', (req, res) ->
  console.log 'request: /'
  res.render('index')

app.get '/create', (req, res) ->
  console.log 'request: /create'
  gameList = []
  for key,val of games
    game =
      title: games[key].config.title
      maxNum: games[key].config.maxOfPeople
    gameList.push game
  res.render('room-create', {gameList: gameList})

app.get '/room/list', (req, res) ->
  res.contentType('application/json')
  console.log rooms
  res.send rooms
  ###
  rooms.find().toArray (err, items) ->
    res.send(items)
  ###

app.post '/room/create', (req, res) ->
  console.log('/room/create: post')
  res.send createRoom req.body.room

app.get '/game/:_id', (req, res) ->
  roomName = req.params._id
  console.log '/game/' + roomName
  if  rooms[roomName] == null ||
      rooms[roomName] == undefined
    errorStr = 'No such room name: ' + roomName
    console.log errorStr
    # res.render errorStr
    res.redirect '/'

  newUserId = uuid.v1()
  users[newUserId] =
    name: null
    room: null
  res.cookie('id', newUserId)
  res.cookie('room', roomName)
  res.render 'game', {script: '../' + games[rooms[roomName].game].config.clientScript}
  ###
  rooms.findOne {_id: mongodb.ObjectID(req.params._id)}, (err, item) ->
    if item == null
      res.redirect '/'
      return
    item.num += 1
    console.log req.params._id
    res.render 'game', {script: '../' + games[item.game].config.clientScript}
  ###

http.listen 3000, ->
  console.log('listening on *:3000')


io.on 'connection', (socket) ->
  console.log('a user connected');
  #socket.on 'chat message', (msg) ->
  #  io.emit('chat message', msg);
  socket.on 'join', (data) ->
    console.log('join: ' + data.id + ', to ' + data.room)
    socket.join(data.room)
    users[data.id].room = data.room
    users[data.id].name = data.name
    rooms[data.room].num += 1
    io.to(data.room).emit('joined', data)

  socket.on 'chat message', (msg) ->
    io.to(users[msg.id].room).emit('chat message', msg)

  socket.on 'disconnect', ->
    console.log('disconnected')


createRoom = (newRoomData) ->
  if newRoomData.name == ''
    return {result: false}
  if newRoomData.game == ''
    return {result: false}
  if !(newRoomData.maxNum >= 0 && newRoomData.maxNum <= 8)
    return {result: false}
  ###
  rooms.findOne {name: newRoomData.name}, (err, data) ->
    if err != null
      return {result: false, error: err}
    if data != null
      return {result: false}
  ###
  newRoom =
    name: newRoomData.name
    game: newRoomData.game
    num: 0
    maxNum: newRoomData.maxNum
  console.log 'createRoom: ' + newRoom
  rooms[newRoomData.name] = newRoom
  ###
  rooms.save newRoom, ->
    console.log newRoom
  {result: true, room: newRoom}
  ###
