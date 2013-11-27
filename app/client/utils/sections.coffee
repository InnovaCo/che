define [
  "sections/parser",
  "sections/invoker",
 ], (sectionParser, Invoker) ->
  link = document.createElement "a"
  link.href = "./"
  sectionsLoader = null
  return {
    load: (name, section) ->
      sectionsLoader = require "sections/loader" if not sectionsLoader?
      sectionsLoader link.href, "get", "#{name}:{\"target\":\"#{section}\"}", 0, null, "{ \"loadSectionsSilently\": true }"

    insert: (state) ->
      sections = sectionParser.parseSections state.sections
      invoker = new Invoker (sections if sections), state
      invoker.run()
  }