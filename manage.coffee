getCardsSize = (deck) ->
  main = {}
  for v,k in deck
    if !v.id
      continue
    main[v.id] = main[v.id] or 0
    main[v.id] += 1
  mainr = []
  for k,v of main
    mainr.push
      id: parseInt(k)
      size: v
  mainr

Manage = (@scene) ->
  @hold = null
  @layout = {}
  @layout.side = new Hand 0, -6, 0, 10
  @layout.side.seat = "side"
  @layout.extra = new Hand 0, -4, 0, 10
  @layout.extra.seat = "extra"
  @layout.main = new Vast 0, -2, 0, 10, 15
  @layout.main.seat = "main"
  @layout.result = new Paging 13, -4, 0, 4, 6, 6
  @layout.result.seat = "result"
  for k,v of @layout
    mouse.Hint v
    mouse.Alone v


  t = this

  @eve = ["click", ((event) ->
    c = event.toElement.hold
    if t.hold == null
      t.hold = c.hold
      while t.hold.Length() != 0
        c = t.hold.Pop()
        t.layout[c.seat].Push c
      t.deckname.value = v.name
    return
  ), false]
  f = (c, rio) ->
    if rio == 3
      t.layout.side.Push c
      c.seat = t.layout.side.seat
    else if rio == 1
      c.Remove()

  mouse.Drag @layout.main, f

  mouse.Drag @layout.extra, f

  mouse.Drag @layout.side, (c, rio) ->
    if rio == 7
      $.get("/cards/json/#{c.id}.json", ((data, status)->
        d = JSON.parse data
        ty = d["卡片种类"]
        if ty == '融合怪兽' or ty == '仪式怪兽' or ty == '同调怪兽' or ty == 'XYZ怪兽'
          t.layout.extra.Push c
          c.seat = t.layout.extra.seat
        else
          t.layout.main.Push c
          c.seat = t.layout.main.seat
      ))
    else if rio == 1
      c.Remove()
  mouse.Drag @layout.result, (c, rio) ->
    if rio == 5
      $.get("/cards/json/#{c.id}.json", ((data, status)->
        d = JSON.parse data
        ty = d["卡片种类"]
        if ty == '融合怪兽' or ty == '仪式怪兽' or ty == '同调怪兽' or ty == 'XYZ怪兽'
          t.AddCard t.layout.extra, c.id, 1, t.layout.extra.seat
        else
          t.AddCard t.layout.main, c.id, 1, t.layout.main.seat
      ))


  @deckname = face.SetInput "卡组名", true
  query = face.SetInput "查询", true
  query.addEventListener "input", ((event) ->
    WsCardFind {query: event.srcElement.value}, (data) ->
      t.UpdateQuery data
  ), false
  face.SetButton "退后", (event) ->
    ExitPage()
  face.SetButton "保存", (event) ->
    unless t.decks[t.deckname.value]
      t.decks[t.deckname.value] = new Pile 19, -4 + t.k * 2, 0
      t.decks[t.deckname.value].addEventListener t.eve...
      t.k++
    WsGameSetDeck
      main: getCardsSize t.layout.main
      extra: getCardsSize t.layout.extra
      side: getCardsSize t.layout.side
      name: t.deckname.value
    t.layout.side.MoveTo t.decks[t.deckname.value]
    t.layout.extra.MoveTo t.decks[t.deckname.value]
    t.layout.main.MoveTo t.decks[t.deckname.value]
    t.hold = null
    t.deckname.value = ""
  @decks = {}
  @deck = {}
  t = this
  @k = 0
  WsGameGetDeck (d) ->
    log d
    for k, v of  d
      log v
      t.AddCards k, v
      t.k = k
    return
  WsCardFind {query: ""}, (data) ->
    t.UpdateQuery data
  return

Manage::UpdateQuery = (data)->
  @layout.result.Clear()
  if data
    for v in data
      @AddCard @layout.result, v, 1, "result"
Manage::AddCards = (k, v) ->
  t = this
  @deck[v.name] = v
  @decks[v.name] = new Pile 19, -4 + k * 2, 0
  @decks[v.name].addEventListener t.eve...
  if v.side
    for x in v.side
      @AddCard @decks[v.name], x.id, x.size, "side"
  if v.extra
    for x in v.extra
      @AddCard @decks[v.name], x.id, x.size, "extra"
  if v.main
    for x in v.main
      @AddCard @decks[v.name], x.id, x.size, "main"
  return


Manage::AddCard = (deck, id, size = 1, seat) ->
  if deck
    t = this
    for x in [0...size]
      c = new Card(@scene)
      c.FaceUp()
      c.Attack()
      c.SetFront id
      c.seat = seat
      deck.Push c
  return