socket = io()

activeRoom = null
vue = new Vue
  el: "body"
  data:
    roomList: [],
  methods:
    reload: ->
      console.log 'reload'
      reloadRoomList()
    selected: (item) ->
      for room in this.roomList
        room.isActive = false
      item.isActive = true
      activeRoom = item
    join: ->
      if activeRoom == null
        return
      # joinGame(activeRoom.id)
      joinGame activeRoom.name

$('form').submit ->
  socket.emit('chat message', $('#m').val())
  $('#m').val('')
  false

socket.on 'chat message', (msg) ->
  $('#messages').append($('<li>').text(msg))

updateRoomList = (list) ->
  vue.roomList = []
  console.log list
  for key,val of list
    console.log key, val
    room =
      # id: item._id,
      name: val.name,
      game: val.game,
      num: val.num,
      maxNum: val.maxNum,
      isActive: false
    vue.roomList.push room

reloadRoomList = ->
  $.getJSON 'room/list', (res) ->
    updateRoomList res

joinGame = (roomId) ->
  if roomId == null
    return
  url = 'game/' + roomId
  console.log url
  location.href = url
  #$.get url, (res) ->
  #  console.log res

# initialize
reloadRoomList()
