#### *module* app, запускает приложение
#
#---
# Точка входа для приложения
#

requirejs ['loader', 'lib/domReady'], (loader, domReady) ->
  domReady loader.searchForWidgets
  # nothing to do