#### *module* clicks/forms
#
# Обрабатывает клики на кнопке submit для форм
# с аттрибутом data-reload-sections,
# достает данные о необходимых секциях, url и вызывает
# обработчика, после чего отменяет дефолтное поведение.
# Обрабатывает именно клики по кнопке, так как необходима
# делегация событий, а событие submit не поднимается вверх к корню.

define ['dom!', 'config', 'events', 'lib/serialize'], (dom, config, events, serialize) ->
  # Внутренний диспетчер событий, для вызова обработчиков клика
  clicks = null

  # ----------- old code — may be need to remove ------
  # Непосредственно навешивание обработчика, который работает
  # только если есть хоть один обработчик клика, на это
  # указывает наличие clicks
  #dom('body').on "form[#{config.reloadSectionsDataAttributeName}] input[type='submit'], form[#{config.reloadSectionsDataAttributeName}] button[type='submit']", "click", (e) ->
  # ---------
  # проблема в том, что самбит может быть также <button>, а может быть вообще форма без кнопки внутри, а самбититься
  # при помощи нажатия Enter в текстовом инпуте.

  # Временно пробуем все же работать с сабмитом. Кто сказал, что submit не поднимается?
  dom('body').on "form[#{config.reloadSectionsDataAttributeName}]", "submit", (e) ->
    return true if not clicks?
    return true if @type is 'reset' or @type is 'button'

    # Достаем форму из родителей кнопки
    formNode = @
    while not found
      if formNode.nodeName.toLowerCase() is "form"
        found = true
      else if formNode is document
        return true
      else
        formNode = formNode.parentNode

    onSubmit(formNode, e)

  processForms = (section) ->
    section = dom section ? 'body'
    forms = section.find("form[#{config.reloadSectionsDataAttributeName}]").get()
    (form.onsubmit = (e) ->
      onSubmit e.target, e
    ) for form in forms

  onSubmit = (formNode, e) ->
    data = formNode.getAttribute config.reloadSectionsDataAttributeName
    url = formNode.getAttribute('action') or ""
    formData = serialize formNode

    # Достаем метод по которому должна быть отправлена форма,
    # по умолчанию это "GET".
    # Следует отметить, что "POST"-запросы за секциями не кешируются

    method = formNode.getAttribute('method') or "GET"

    clicks.trigger "form:click",
      url: url,
      data: data,
      method: method,
      formData: formData
    e.preventDefault()
    return false


  #### init(callback)
  #
  # Интерфейс модуля. Представляет функцию, которая принимает
  # обработчиков кликов.
  # Функция создает новый диспетчер событий, если до этого его не было
  #

  init = (callback) ->
    if not clicks?
      clicks = events.sprout()

    clicks.bind "form:click", callback

  #### init.reset()
  #
  # Удялет диспетчер событий, тем самым возвращая к предыдущему
  # состоянию
  #

  init.reset = ->
    clicks = null

  #### init.processForms()
  #
  # Навешивает обработчик onsubmit на формы внутри секции
  # По сути, костыльное решение из-за отсутствия аналога $.on,
  # которое реализует всплытие события submit
  #
  init.processForms = (section) ->
    processForms section

  init
