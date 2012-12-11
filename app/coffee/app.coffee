#### *module* app, запускает приложение
#
#---
# Точка входа для приложения
#

requirejs.config
  baseUrl: 'app/javascripts/che'

requirejs ['preloader'], (preloader) ->
  # nothing to do