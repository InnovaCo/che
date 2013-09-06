define ["underscore"], (_)->
  paramsRegex = /[?&]([^=]+)\=([^&]+)/g
  params = (data, prefix, result) ->
    result = result or []

    if _.isString data
      result.push (prefix or "") + "=#{encodeURIComponent data}"
    else
      for field, value of data
        nextPrefix = if prefix? then prefix + encodeURIComponent("[#{field}]") else encodeURIComponent field
        nextValue = value?() or value
        params nextValue, nextPrefix, result

    result
  strToObject = (data) ->
    result = {}

    while paramArr = paramsRegex.exec data
      result[paramArr[1]] = paramArr[2] if paramArr?

    result

  (data, asObject) ->
    return (params data()).join "&" if _.isFunction data
    return (params data).join "&" if _.isObject data
    return (strToObject data) if typeof data == "string" and asObject
    return data?.toString()
