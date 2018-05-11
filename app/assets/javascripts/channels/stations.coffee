jQuery(document).on 'turbolinks:load', ->
  reviews = $('#reviews')
  aboveCom=$('#above')
  if reviews.length > 0
    App.global_chat = App.cable.subscriptions.create {
      channel: "StationsChannel"
      station_id: reviews.data('station-id')
    },
    connected: ->
    disconnected: ->
    received: (data) ->
      aboveCom.append data['review']
    send_review: (review, station_id) ->
      @perform 'send_review', review: review, station_id: station_id
  $('#new_review').submit (e) ->
    $this = $(this)
    textarea = $this.find('#review_content')
    if $.trim(textarea.val()).length > 1
      App.global_chat.send_review textarea.val(),
      reviews.data('station-id')
      textarea.val('')
    e.preventDefault()
    return false