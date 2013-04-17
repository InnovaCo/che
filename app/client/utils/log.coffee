#### Logger
#
#
define ['module'], (module) ->
  # ----------------------------------
  # Options
  # ----------------------------------
  options = _.extend
    maxEntries: 500
    logLevel: 10
  , module.config()

  # ----------------------------------
  # Small class for one log entry
  # ----------------------------------
  class LogEntry
    constructor: (@message, @namespace = "global", @type, @objectsArray) ->
      @time = new Date().getTime()

  # ----------------------------------
  # Entries list manager
  # ----------------------------------
  entriesList =
    entries: []
    maxEntries: options.maxEntries

    append: (message, namespace, objectsArray, type) ->
      @entries.push new LogEntry(message, namespace, type, objectsArray)
      @checkMaxLogStack()

    # sortByTime: (a, b) ->
    #   return (a.time - b.time)

    getEntries: (type) ->
      return @entries if not type?
      resultArray = []
      resultArray.push(entry) for entry in @entries when entry.type is type
      resultArray

    checkMaxLogStack: () ->
      return true if @entries.length <= @maxEntries
      return @entries.shift()

    empty: () ->
      @entries.length = 0
      true

  # ----------------------------------
  # Proxy functions
  # ----------------------------------
  _log = (message, namespace, objectsArray, type = "log") ->
    entriesList.append(message, namespace, objectsArray, type)

  _info = () ->
    _log arguments[0],arguments[1],arguments[2], "info"

  _notice = () ->
    _log arguments[0],arguments[1],arguments[2], "notice"

  _warn = () ->
    _log arguments[0],arguments[1],arguments[2], "warn"

  _error = () ->
    _log arguments[0],arguments[1],arguments[2], "error"

  _empty = () ->
    entriesList.empty()

  _getEntries = (type) ->
    entriesList.getEntries(type)

  _printEntries = (type) ->
    return if not console?
    entries = entriesList.getEntries(type)
    for entry in entries
      printType = if console[entry.type]? then entry.type else "log"

      if entry.objectsArray
        console[printType] "L: [#{entry.namespace}][#{entry.type}]:", entry.message, entry.objectsArray
      else
        console[printType] "L: [#{entry.namespace}][#{entry.type}]:", entry.message
    entries

  _saveToServer = () ->
    true

  _sendStat = () ->
    true

  _getMaxEntries = () ->
    return 0 + entriesList.maxEntries

  # ----------------------------------
  # Module API
  # ----------------------------------
  return {
    log: _log
    info: _info
    notice: _notice
    warn: _warn
    error: _error
    empty: _empty
    getEntries: _getEntries
    printEntries: _printEntries
    saveToServer: _saveToServer
    sendStat: _sendStat
    getMaxEntries: _getMaxEntries
  }