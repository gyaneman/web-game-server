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
  if (data.id === myId) {
    $('.chat-log').append($('<li class="chat-log__item chat-log__item--mine">').text(data.message));
  } else {
    $('.chat-log').append($('<li class="chat-log__item chat-log__item--others">').text(data.message));
  }
});

var sendMassage = function (message) {
  console.log('message')
  socket.emit('chat message', {
    id: myId,
    room: myRoom,
    name: myName,

    message: message
  });
}

$('.chat-form').submit(function() {
  console.log($('.chat__input').val());
  sendMassage($('.chat__input').val());
  $('.chat__input').val('');
  return false;
});
