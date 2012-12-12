define [], ->
  instances = {}
  registerModuleInstance = (name, instance) ->
    instances[name] = instances[name] or {}
    instances[name][instance.id] = instance

  loader = (widgetName, domElement) ->
    require [widgetName], (widget) ->
      if not domElement.getAttribute('data-widget-' + widgetName)
        instance = new widget.init(domElement)
        instance.id = instance.id or +new Date
        registerModuleInstance(widgetName, instance)
        domElement.setAttribute('data-widget-' + widgetName, instance.id)
      
      

  loader