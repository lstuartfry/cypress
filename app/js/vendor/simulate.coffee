window.Simulate = do ($, _) ->

  $.fn.cySimulate = (event, options) ->
    @each (index, el) ->
      Simulate.create(el, event, options)

  events = [
    {event: "click", type: "MouseEvents", bubbles: true, cancelable: true}
  ]

  Simulate = {
    create: (el, event, options) ->
      switch
        when _(events).findWhere({event:event})
          new Simulate.Native(el, event, options)
  }

  class Simulate.Native
    constructor: (el, event, options = {}) ->
      @document = el.ownerDocument
      @window   = @getWindowByDocument(@document)

      @initialize(el, event, options)

    initialize: (el, event, options) ->
      eventObj = @createEvent(el, event, options)
      @dispatchEvent(el, eventObj)

    getWindowByDocument: (document) ->
      _.find window.frames, (frame, index) ->
        try
          frame.document is document

    createEvent: (el, event, options) ->
      obj = @lookupEventObj(event)

      method = @getEventMethodByType(obj.type)
      method.call @, el, obj, options

    dispatchEvent: (el, eventObj) ->

    lookupEventObj: (event) ->
      _(events).findWhere({event: event}) or
        throw new Error("Event: #{event} was not found as an available event to simulate!")

    getEventMethodByType: (type) ->
      method = "on" + type
      throw new Error("Event method: #{method} does not exist on Simulate") if not @[method]
      @[method]

    onMouseEvents: (el, obj, options) ->
      offset = $(el).offset()
      $doc   = $(@document)

      _.defaults options,
        view: @window
        detail: 1
        screenX: 0
        screenY: 0
        clientX: offset.left - $doc.scrollLeft()
        clientY: offset.top - $doc.scrollTop()
        ctrlKey: false
        altKey: false
        shiftKey: false
        metaKey: false
        button: 0
        relatedTarget: null

      switch
        when document.createEvent
          ## https://developer.mozilla.org/en-US/docs/Web/API/event.initMouseEvent
          event = document.createEvent("MouseEvents")
          event.initMouseEvent.apply event, [
            obj.event, ## type (click / dblclick / mousedown / mouseup)
            obj.bubbles,
            obj.cancelable,
            options.view,
            options.detail,
            options.screenX
            options.screenY
          ]

          ## need to research what other properties should
          ## be added to the event object
          event.pageX = offset.left
          event.pageY = offset.top

        when document.createEventObject then ""

    onHTMLEvents: (event, options) ->

    onKeyEvents: (event, options) ->

    onTouchEvents: (event, options) ->

  return Simulate