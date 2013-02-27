define ['dom!', 'config', 'events'], (dom, config, events) ->
  clicks = null

  dom('body').on "a[#{config.reloadSectionsDataAttributeName}]", "click", (e) ->
    if clicks?
      data = @getAttribute config.reloadSectionsDataAttributeName
      url = @getAttribute 'href'
      clicks.trigger "anchor:click", [url, data, "GET"]

      e.preventDefault()
      return false

  init = (callback) ->
    if not clicks?
      clicks = events.sprout("anchors")

    clicks.bind "anchor:click", callback

  init.reset = ->
    clicks = null

  init