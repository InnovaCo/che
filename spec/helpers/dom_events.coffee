window.domEvents = 
  triggerMouseEvent : (eventName, element) ->
    if document.createEvent
      event = document.createEvent "MouseEvents"
      event.initEvent eventName, true, true
    else 
      event = document.createEventObject()
      event.eventType = eventName;

    event.eventName = eventName;
    event.memo = {};

    if document.createEvent
      element.dispatchEvent event
    else
      element.fireEvent "on" + event.eventType, event

  triggerMouseEventWithKey : (eventName, keys, element) ->
    modifiers =
      ctrl: false
      alt: false
      shift: false
      meta: false

    if typeof keys is 'string'
      keys = [keys]

    modifiers[key] = true for key in keys

    if document.createEvent
      event = document.createEvent "MouseEvents"
      event.initMouseEvent(
        eventName, true, true, window
        0, 0, 0, 0, 0
        modifiers.ctrl, modifiers.alt, modifiers.shift, modifiers.meta
        0, null
      )

    else 
      event = document.createEventObject()
      event.eventType = eventName;

    event.eventName = eventName;
    event.memo = {};

    if document.createEvent
      element.dispatchEvent event
    else
      element.fireEvent "on" + event.eventType, event
