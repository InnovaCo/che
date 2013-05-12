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
  sectionSelectorAttributeName: "selector"
  sectionSelectorNSAttributeName: 'section-namespace'
  sectionNSdelimiter: ' '
  storage: ["fake", "localStorage", "cookies"]
  
  setup: (customConfig) ->
    @[param] = value for param, value of customConfig
    @