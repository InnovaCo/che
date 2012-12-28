define [], ->
  init: (layout) ->
    className = @element.className
    @element.className = className + " " + @name.replace("/", "-")