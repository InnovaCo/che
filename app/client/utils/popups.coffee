define ["underscore","events"], (_, events)->

  showedPopup = null
  turnedOn = off
  registeredShowFunc = null
  registeredHideFunc = null


  defaultShowFunc = (section) ->
    console.log "show!", section

  defaultHideFunc = (section) ->
    console.log "hide!", section

  showPopup = (section) ->
    showedPopup = section
    return registeredShowFunc(showedPopup) if typeof registeredShowFunc is 'function'
    return defaultShowFunc(showedPopup)

  hidePopup = () ->
    return false if !showedPopup
    return registeredHideFunc(showedPopup) if typeof registeredHideFunc is 'function'
    return defaultHideFunc(showedPopup)

  removePopup = () ->
    console.log "remove!", showedPopup
    showedPopup = null


  bindEvents = () ->
    events.bind "section-popup:inserted", showPopup
    events.bind "section-popup:removed", removePopup
    turnedOn = on


  unbindEvents = () ->
    events.unbind "section-popup:inserted", showPopup
    events.unbind "section-popup:removed", removePopup
    turnedOn = off

  bindEvents()

  return {
    on: () ->
      bindEvents()

    off: () ->
      unbindEvents()

    getCurrentPopup: () ->
      return showedPopup

    isTurnedOn: () ->
      return (turnedOn)

    registerShowHideFunc: (funcShow, funcHide) ->
      return false if !funcShow or !funcHide
      registeredShowFunc = funcShow
      registeredHideFunc = funcHide

    unregisterShowHideFunc: () ->
      registeredShowFunc = null
      registeredHideFunc = null

  }