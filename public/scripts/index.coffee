socket = io()

$.getJSON 'chat/list', (res) ->
  for i in res
    console.log i

$('form').submit ->
  socket.emit('chat message', $('#m').val())
  $('#m').val('')
  false

socket.on 'chat message', (msg) ->
  $('#messages').append($('<li>').text(msg))

$('.room-list__update').click ->
  console.log('clicked')
