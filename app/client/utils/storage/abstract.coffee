define [], ->
  class Storage
  
    constructor: () ->
      @instance = @constructor
  
    save: (moduleName, varName, value, isSessionOnly, isStorageOnly) ->
      value = JSON.stringify value
      key = createVarName moduleName, varName
      return @instance.save key, value, isSessionOnly

    get: (moduleName, varName) ->
      key = createVarName moduleName, varName
      value = @instance.get key, varName
      return JSON.parse value

    remove: (moduleName, varName) ->
      return @instance.remove createVarName moduleName, varName

    getKeys: () ->
      return @instance.getKeys
      
    createVarName = (moduleName, varName) ->
      "#{moduleName}/#{varName}"
        
  return Storage