define ['dom!', 'config', 'events'], (dom, config, events) ->
  clicks = null

  dom('body').on "form[#{config.reloadSectionsDataAttributeName}] input[type='submit']", "click", (e) ->
    if clicks?

      formNode = @
      while not found
        if formNode.nodeName.toLowerCase() is "form"
          found = true
        else if formNode is document
          return true
        else
          formNode = formNode.parentNode

      data = formNode.getAttribute config.reloadSectionsDataAttributeName
      url = formNode.getAttribute('action') or ""
      method = formNode.getAttribute('method') or "GET"
      
      clicks.trigger "form:click", [url, data, method]
      e.preventDefault()
      return false

  init = (callback) ->
    if not clicks?
      clicks = events.sprout()

    clicks.bind "form:click", callback

  init.reset = ->
    clicks = null

  init
