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