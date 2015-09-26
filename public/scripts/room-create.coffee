vue = new Vue
  el: 'body'
  data:
    title: ''
    game: ''
    maxNum: null
    gameList: ["othello"]
  methods:
    clickedSubmitBtn: (e) ->
      e.preventDefault()
      console.log 'submit'
      if this.title == '' || this.game == '' || this.maxNum == null
        console.log 'empty form'
      else
        jsonData =
          room:
            name: this.title
            game: this.game
            maxNum: this.maxNum
        console.log jsonData
        $.ajax
          type: "POST"
          url: "room/create"
          data: JSON.stringify jsonData
          contentType: "application/json"
          dataType: "json"
          success: (res) ->
            console.log res
