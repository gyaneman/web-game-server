socket = io()

vue = new Vue
  el: "body"
  data:
    roomList: [],

$.getJSON 'room/list', (res) ->
  #updateRoomList res

$('form').submit ->
  socket.emit('chat message', $('#m').val())
  $('#m').val('')
  false

socket.on 'chat message', (msg) ->
  $('#messages').append($('<li>').text(msg))

$('.room-list__update').click ->
  console.log('clicked')

updateRoomList = (list) ->
  vue.roomList = []
  for item in list
    console.log item
    room =
      id: item.id,
      name: item.name,
      game: item.game,
      num: item.peaple,
      maxNum: item.maxNum,
    vue.roomList.push room
