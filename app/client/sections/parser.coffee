#### *module* sections/parser
#
#
# Модуль для парсинга селекторов у приходящих секций.
# (возможно и для построения?)
#

define [
  "sections/asyncQueue",
  "dom",
  "config",
  "underscore"], (asyncQueue, dom, config, _) ->

  ####
  #
  # Three ways to describe reload-sections:
  #
  # data-reload-sections="AppWidget: #someTarget"
  # data-reload-sections="AppWidget: #someTarget:[popup,hidden]"
  # data-reload-sections='AppWidget: {"target": "#someTarget", "type": ["popup"], "someData": "someData"}'
  #
  # Single-Quoted Attribute Value Syntax вполне допустим
  # http://dev.w3.org/html5/html-author/#single-quote-attr

  Parser = (@reloadSections) ->
    @parsedSections = {}
    @parseSections()
    return @parsedSections

  Parser:: =
    parseSections: () ->
      # asyncQueue.next =>
      reloadSectionsHtml = dom @reloadSections
      for element in reloadSectionsHtml.get()
        nodeName = element.nodeName.toLowerCase()
        sectionName = ''

        if nodeName is config.sectionTagName
          sectionName = element.getAttribute "data-#{config.sectionName}"
          selector = @parseSelector element.getAttribute "data-#{config.sectionSelectorAttributeName}"
        else if nodeName is 'title'
          selector = {"target": nodeName}
          # пока кладем вместе со всеми dom-секциями, пусть заменяется
          # стандартным путем. Потом, если надо будет, можно сделать
          # специальную отдельную вставку.
          #
          # sectionType = "title"
        else
          continue

        if selector.target? then sectionType = "dom" else sectionType = "other"

        # приводим type к единому стандарту — array.
        if selector.type? and _.isString selector.type
          selector.type = [selector.type]

        @parsedSections[sectionType] = [] if not @parsedSections[sectionType]?
        @parsedSections[sectionType].push
          name: sectionName
          element: element
          selector: selector

    # Считаем для простоты, что если просто строка, то это css-селектор
    parseSelector: (selector) ->
      try
        # ...
        parsedSelector = JSON.parse selector
        return parsedSelector
      catch e
        return {"target": selector}
        # ...


  return Parser
