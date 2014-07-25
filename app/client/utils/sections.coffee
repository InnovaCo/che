#### *module* utils/sections
#
# Вспомогательный модуль для загрузки модулей без использования навигационого
# модуля.
# Модули загружаются без событий pageTransition.
# Модули могут быть загружены данным модулем, как вызовом на прямую, так и
# через параметры в ссылках.
#
# Загрузка модуля на прямую:
#     require("utils/sections").load("UserBarWidget", "#UserBarWidget")
#
# Загрузка модуля через ссылку:
#     <a href="./" data-reload-sections='UserBarWidget: #UserBarWidget' data-reload-params='{ "loadSectionsSilently": true }'>Text</a>
#
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