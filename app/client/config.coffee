#### *module* config
#
# конфиги для черхитектуры
#

define ['utils/popups', 'utils/scroll'], (popupsModule, scrollModule) ->
  widgetDataAttributeName: 'data-js-widgets'
  reloadParamsDataAttributeName: 'data-reload-params'
  reloadSectionsDataAttributeName: 'data-reload-sections'
  baseWidgetsPath: ''
  sectionTagName: "section"
  autoScrollOnTransitions: true
  sectionSelectorAttributeName: "data-selector"
  storage: ["fake", "localStorage", "cookies"]
  # todo сделать непереопределяемыми
  _modules:
    popups: popupsModule
    scroll: scrollModule
  
  setup: (customConfig) ->
    @[param] = value for param, value of customConfig
    @