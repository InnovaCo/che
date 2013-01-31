define ["underscore"], (_)->
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

  (data) ->
    return (params data()).join "&" if _.isFunction data
    return (params data).join "&" if _.isObject data
    return data?.toString()