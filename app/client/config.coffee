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

  ####
  #
  # Пример задания правил редиректа:
  #
  #    che({
  #        redirectDefaultRuleName: 'common',
  #        redirectRules: {
  #            'common': [{
  #                'sectionName': 'UserBarWidget',
  #                'params': {
  #                    'target': '#UserBarWidget'
  #                }
  #            },{
  #                'sectionName': 'pageView',
  #                'params': {
  #                    'target': '#GlobalContent'
  #                }
  #            },{
  #                'sectionName': 'EmptyWidget',
  #                'params': {
  #                    'target': '#OverlayContent'
  #                }
  #            }],
  #            'popupWidget': {
  #                'target': '#OverlayContent',
  #                'ns': 'popup'
  #            }
  #        }
  #    });
  #
  # Если прийдет редирект с урлом "/page1?popupWidget=AuthPopupWidget&redirectTo=/page2",
  # черхитектура сделает запрос на новый урл сформирова на основе урла следующие
  # sectionsHeader – "UserBarWidget: {"target":"#UserBarWidget"};pageView: {"target":"#GlobalContent"};AuthPopupWidget: {"target":"#OverlayContent","ns":"popup"}"
  # Если же в урле не будет указан popupWidget, то sectionsHeader будет равен:
  # "UserBarWidget: {"target":"#UserBarWidget"};pageView: {"target":"#GlobalContent"};EmptyWidget: {"target":"#OverlayContent"}"
  redirectDefaultRuleName: "common"
  redirectRules:
    common:
      target: "body"

  setup: (customConfig) ->
    @[param] = value for param, value of customConfig
    @