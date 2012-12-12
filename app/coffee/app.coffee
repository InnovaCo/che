#### *module* app, запускает приложение
#
#---
# Точка входа для приложения
#

requirejs.config
  baseUrl: 'app/js'

requirejs ['preloader'], (preloader) ->
  # nothing to do