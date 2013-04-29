#### *module* config
#
# конфиги для черхитектуры
#

define
  widgetClassName: 'widget'
  widgetDataAttributeName: 'data-js-modules'
  reloadSectionsDataAttributeName: 'data-reload-sections'
  baseWidgetsPath: ''
  sectionTagName: "section"
  sectionSelectorAttributeName: "selector",
  storage: ["fake", "localStorage", "cookies"],
  
  setup: (customConfig) ->
    @[param] = value for param, value of customConfig
    @