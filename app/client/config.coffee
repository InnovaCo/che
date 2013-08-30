#### *module* config
#
# конфиги для черхитектуры
#

define ['utils/popups'], (popupsModule) ->
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
  ####
  #
  # Пример задания правил редиректа:
  #
  #    che({
  #        redirectDefaultRule: 'pageView',
  #        redirectRules: {
  #            'pageView': {
  #                'target': '#GlobalContent'
  #            },
  #            'popupWidget': {
  #                'target': '#OverlayContent',
  #                'ns': 'popup'
  #            }
  #        }
  #    });
  #
  # Если прийдет редирект с урлом "/page1?popupWidget=AuthPopupWidget&redirectTo=/page2",
  # черхитектура сделает запрос на новый урл сформирова на основе урла следующие
  # sectionsHeader – "AuthPopupWidget: {"target":"#OverlayContent","ns":"popup"}"
  redirectDefaultRule: "default"
  redirectRules:
    default:
      target: "body"

  setup: (customConfig) ->
    @[param] = value for param, value of customConfig
    @