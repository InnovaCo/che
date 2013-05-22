define ["events", "underscore"], (events, _) ->
  Section = () ->
    @name
    @params = {}
    @element
  
  Section:: =
    init: () ->
      @processNamespaces "inited"
      
    onInsert: () ->
      @processNamespaces "inserted"
    
    onRemove: () ->
      @processNamespaces "removed"
        
    processNamespaces: (postfix) ->
      return if not @params.ns?
      
      @params.ns = [@params.ns] if _.isString @params.ns
      events.trigger "section-#{type}:" + postfix, [@] for type in @params.ns

  Section