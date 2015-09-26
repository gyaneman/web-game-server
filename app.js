(function() {
  var app, defaultRooms, express, http, io, path;

  express = require('express');

  app = express();

  http = require('http').Server(app);

  io = require('socket.io')(http);

  path = require('path');

  app.use(express["static"](path.join(__dirname, 'build')));

  defaultRooms = ['general'];

  app.get('/', function(req, res) {
    return res.sendfile('index.html');
  });

  app.get('/chat/list', function(req, res) {
    var json, resData;
    res.contentType('application/json');
    resData = defaultRooms;
    json = JSON.stringify(resData);
    return res.send(json);
  });

  http.listen(3000, function() {
    return console.log('listening on *:3000');
  });

  io.on('connection', function(socket) {
    console.log('a user connected');
    socket.on('chat message', function(msg) {
      return io.emit('chat message', msg);
    });
    return socket.on('disconnect', function() {
      return console.log('disconnected');
    });
  });

}).call(this);
