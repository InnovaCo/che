define ->
  params  = (data, prefix, result) ->
    result = result or []
    if _.isString data
      result.push (prefix or "") + "=#{encodeURIComponent data}"
    else
      for field, value of data
        if prefix?
          nextPrefix = prefix + "[#{field}]"
        else
          nextPrefix = field

        if _.isFunction value
          nextValue = value()
        else
          nextValue = value

        params nextValue, nextPrefix, result

    encodeURI result.join "&"

  (data) ->
    if _.isFunction data
      return params data()
    else if _.isObject data
      return params data
    else 
      return data?.toString()