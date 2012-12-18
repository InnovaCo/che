define [], ->
  S4 = ->
    Math.floor(Math.random() * 0x10000).toString 16

  ->
    S4() + S4() + "-" +
    S4() + "-" +
    S4() + "-" +
    S4() + "-" +
    S4() + S4() + S4()