describe "config module", ->
  config = null
  originalConfig = null
  
  require ['config'], (configModule) ->
    originalConfig = configModule

  beforeEach ->
    waitsFor ->
      config?
    config = _.clone originalConfig

  it "should redefine default params by setup method", ->
    originalParam = config.widgetClassName
    config.setup
      widgetClassName: originalParam + 'Test123'

    expect(config.widgetClassName).toBe(originalParam + 'Test123')