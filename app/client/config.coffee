#### *module* config
#
# конфиги для черхитектуры
#

define ['utils/popups'], (popupsModule) ->
  widgetDataAttributeName: 'data-js-widgets'
  reloadSectionsDataAttributeName: 'data-reload-sections'
  baseWidgetsPath: ''
  sectionTagName: "section"
  sectionSelectorAttributeName: "data-selector"
  storage: ["fake", "localStorage", "cookies"]
  # todo сделать непереопределяемыми
  _modules:
    popups: popupsModule
  
  setup: (customConfig) ->
    @[param] = value for param, value of customConfig
    @