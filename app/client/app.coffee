#### Точка входа для приложения
# 
#

# Подключает модули 'loader', 'lib/domReady'

requirejs ['loader', 'lib/domReady', 'clicks'], (loader, domReady) ->
  # сразу запускает поиск виджетов
  domReady loader.searchForWidgets