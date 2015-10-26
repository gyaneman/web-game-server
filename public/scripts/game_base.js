var socket = io();
var myId = $.cookie('id');
var myRoom = $.cookie('room');

var myName = 'test user';

if (myId === undefined || myRoom === undefined) {
  console.log('Cookie error...');
}


socket.emit('join', {
  id: myId,
  room: myRoom,
  name: myName
});

socket.on('joined', function(data) {
  if (data.id === myId) {
    console.log('joined: to ' + myRoom);
  }
});

socket.on('chat message', function(data) {
  console.log(data.message);
});


var sendMassage = function (message) {
  socket.emit('chat message', {
    id: myId,
    room: myRoom,
    name: myName,

    message: message
  });
}
