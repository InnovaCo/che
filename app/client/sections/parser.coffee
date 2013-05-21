#### *module* sections/parser
#
#
# Модуль для парсинга селекторов у приходящих секций.
# (возможно и для построения?)
#

define [
  "sections/asyncQueue",
  "dom",
  "config"], (asyncQueue, dom, config) ->
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

  return {
    parseSections: (reloadSections) ->
      parsedSections = []
      # asyncQueue.next =>
      reloadSectionsHtml = dom reloadSections
      for element in reloadSectionsHtml.get()
        nodeName = element.nodeName.toLowerCase()
        sectionData = null

        if nodeName is config.sectionTagName
          sectionData = @parseSectionParams element.getAttribute config.sectionSelectorAttributeName
        else if nodeName is 'title'
          sectionData = {"name": nodeName, "params": {"target": nodeName}}
          
        # если пришло что-то непотребное, пропускаем его
        continue if not sectionData

        parsedSections.push
          name: sectionData.name
          params: sectionData.params
          element: element
      
      return parsedSections

    parseSectionParams: (sectionParams) ->
      parsedSectionParams = /([^:]+):\s+(.+)/.exec sectionParams
      return false if not parsedSectionParams
      
      parsedParams = name: parsedSectionParams[1]
      try
        parsedParams.params = JSON.parse parsedSectionParams[2]
      catch e
        parsedParams.params = {"target": parsedSectionParams[2]}
      
      return parsedParams
  }
