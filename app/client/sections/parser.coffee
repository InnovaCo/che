#### *module* sections/parser
#
#
# Модуль для парсинга селекторов у приходящих секций.
# (возможно и для построения?)
#

define [
  "sections/asyncQueue",
  "sections/section",
  "dom",
  "config"], (asyncQueue, Section, dom, config) ->
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
        section = new Section()
        section.element = element

        if nodeName is config.sectionTagName
          @parseSectionParams section, element.getAttribute config.sectionSelectorAttributeName
        else if nodeName is 'title'
          section.name = nodeName
          section.params.target = nodeName
        else if nodeName is 'link' and element.rel is 'shortcut icon'
          section.params.target = 'icon'
          section.params.ns = ['icon']

        parsedSections.push section

      return parsedSections

    parseSectionParams: (section, sectionParams) ->
      parsedSectionParams = /([^:]+):\s*(.+)/.exec sectionParams
      return if not parsedSectionParams
      
      section.name = parsedSectionParams[1]
      try
        section.params = JSON.parse parsedSectionParams[2]
      catch e
        section.params = {"target": parsedSectionParams[2]}
  }
