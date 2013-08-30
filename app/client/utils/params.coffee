define ["underscore"], (_)->
  paramsRegex = /[?&]([^=]+)\=([^&]+)/
  params  = (data, prefix, result) ->
    result = result or []
    if _.isString data
      result.push (prefix or "") + "=#{encodeURIComponent data}"
    else
      for field, value of data
        nextPrefix = if prefix? then prefix + encodeURIComponent("[#{field}]") else encodeURIComponent field
        nextValue = value?() or value
        params nextValue, nextPrefix, result

    result

  (data, asObject) ->
    return (params data()).join "&" if _.isFunction data
    return (params data).join "&" if _.isObject data
    if (typeof data == "string" and asObject)
      result = {}
      paramsArr = data.split "&"
      for val, i in paramsArr
        paramArr = paramsRegex.exec((if i then "&" else "") + val)
        result[paramArr[1]] = paramArr[2] if paramArr?
      return result
    return data?.toString()
