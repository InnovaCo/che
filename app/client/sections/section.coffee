define ["events", "underscore"], (events, _) ->
  Section = () ->
    @name
    @params = {}
    @element

  Section:: =
    init: () ->
      postfix = "inserted"
      @notifyAll postfix
      @processNamespaces "inited"

    onInsert: () ->
      postfix = "inserted"
      @notifyAll postfix
      @processNamespaces postfix

    onRemove: () ->
      postfix = "removed"
      @notifyAll postfix
      @processNamespaces postfix

    processNamespaces: (postfix) ->
      return if not @params.ns?

      @params.ns = [@params.ns] if _.isString @params.ns
      @notifyAll(postfix, "-#{type}") for type in @params.ns

    notifyAll: (postfix, suffix) ->
      return unless postfix
      events.trigger "section#{suffix}:#{postfix}", [@]

  Section