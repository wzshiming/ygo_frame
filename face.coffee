newButton = (name = null, func = null) ->
  b = document.createElement('a')
  b.className = "btn btn-primary"
  b.innerText = name
  b.onclick = func
  b

Face = ->
  @face = document.createElement "Face"
  container.appendChild @face
  @face.className = "face"

  @img = document.createElement('img')
  @face.appendChild @img

  @text = document.createElement('p')
  @face.appendChild @text

  #  @phases = document.createElement "phases"
  #  container.appendChild @phases
  #  @phases.className = "phases"

  @infos = {}
  @info = document.createElement('div')
  @info.className = "phases"
  container.appendChild @info

  @chat = document.createElement('div')
  @chat.className = "chat"
  container.appendChild @chat

  @mid = document.createElement('div')
  @mid.className = "mid"
  container.appendChild @mid



  return
Face::InitGame = ()->
  ci = document.createElement('div')
  ci.id = "ygotime"
  @mid.appendChild(ci)

  @gage = new JustGage({
    id: "ygotime",
    value: 0,
    min: 0,
    max: 100,
    title: "",
    label: ""
  })

  @buttons = []
  for i in ["Chain", "DP", "SP", "MP1", "BP", "MP2", "EP"]
    t = newButton(i, (->))
    @buttons.push(t)
    @mid.appendChild(t)
  @buttons[0].onclick = ->
    WsSelectable 0, 11
  @buttons[4].onclick = ->
    WsSelectable 0, 4
  @buttons[5].onclick = ->
    WsSelectable 0, 5
  @buttons[6].onclick = ->
    WsSelectable 0, 6

  @rs = document.createElement('div')
  @rs.id = "roundSize"
  @rs.innerText = 0
  @mid.appendChild(@rs)

Face::RoundSize = (i,p) ->
  @rs.innerText = i

Face::Gage = (i, b)->
  if  b >= 7
    return
  t = this
  if b != 0
    for v in @buttons
      v.className = "btn btn-primary"
  @buttons[b].className = "btn btn-danger"
  if t.ti != i
    @gage.refresh i
    @gage.refresh @gage.originalValue, i
  if t.stepInterval
    window.clearInterval t.stepInterval
  t.ti = i
  t.stepInterval = window.setInterval((->
    t.ti--
    t.gage.refresh t.ti
    if t.ti <= 0
      t.ti = 0
      window.clearInterval t.stepInterval
    return
  ), 1000)


Face::Msg = (msg) ->
  b = document.createElement('p')
  b.innerText = CurentTime() + "\n" + msg + "\n"
  @chat.appendChild b
  @chat.scrollTop = @chat.scrollHeight
  return

Face::SetInput = (name = null, u = null) ->
  if u
    b = document.createElement('input')
    b.id = name
    b.type = "text"
    b.className = "form-control"
    b.name = name
    b.placeholder = name
    @SetHTML name, b
  else
    @SetHTML name
  return b


Face::SetButton = (name = null, func = null) ->
  if func
    b = document.createElement('a')
    b.className = "btn btn-primary"
    b.innerText = name
    b.onclick = func
    @SetHTML name, b
  else
    @SetHTML name
  return b


Face::SetHTML = (name = null, value = null) ->
  unless name
#log @infos
    for own k,v of @infos
      @info.removeChild @infos[k]
      delete @infos[k]
    @infos = {}
    return
  if value
    if typeof value == 'object'
      if @infos[name]
        @info.removeChild @infos[name]
        delete @infos[name]
      @info.appendChild value
      @infos[name] = value
    else
      unless @infos[name]
        @infos[name] = document.createElement('p')
        @info.appendChild @infos[name]
      @infos[name].innerHTML = "#{name}: #{value}"
  else if @infos[name]
    @info.removeChild @infos[name]
    delete @infos[name]
  return

Face::ShowCard = (c) ->
  if c
    @img.src = c.img.src
    @img.style.display = ""
    @text.style.display = ""
    t = this
    #@text.innerText = c.img.src.innerText
    #console.dir c
    CardInfo c, (data)->
      str = ""
      for own k,v of data
        str += "#{k}: #{v}<br>"
      t.text.innerHTML = str

  else
#@img.src = " "
    @img.style.display = "none"
    #@text.innerText = ""
    @text.style.display = "none"
  return
