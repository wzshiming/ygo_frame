Player = (@scene, @index = 0, @x = 0, @y = 0, @a = 0, @v = {}) ->
  @decks = {}

  @inDeckSize = 0
  # 手牌
  @decks.hand = new Hand @x + 6, @y + 6, @a

  # 卡组
  @decks.deck = new Pile @x + 16, @y + 5, @a, -100

  # 额外卡组
  @decks.extra = new Dig @x + 4, @y + 5, @a

  # 排除卡组
  @decks.removed = new Dig @x + 16, @y + 1, @a

  # 墓地
  @decks.grave = new Dig @x + 16, @y + 3, @a

  # 场地卡
  @decks.field = new Dig @x + 4, @y + 3, @a

  # 怪物卡区
  @decks.mzone = new Rows @x + 6, @y + 2, @a

  # 魔陷区
  @decks.szone = new Rows @x + 6, @y + 4, @a

  # 玩家头像
  @decks.portrait = new Dig @x + 15, @y + 5, @a, 500

  # 选择
  @decks.pick = new Pick @x, @y + 1, @a, 10, 20

  for k,v of @decks
    if k != "deck"
      mouse.Hint v
      mouse.Drag v, (c, rio)->
        WsSelectable c.uniq, rio
      mouse.Lay v

  return


Player::Join = (u, lay, s = null) ->
  if lay == "portrait"
    unless @decks.portrait[0]
      c = new Card(@scene)
      @decks.portrait.Push c
    c.FaceUp()
    c.SetHTML "玩家牌", @v.name
    c.SetUniq u
    #@decks.portrait[0].SetPortrait u
    return
  else if @decks[lay]
    c = Card::Find u
    unless c
      if lay != "deck" and @decks.deck.Length() != 0
        c = @decks.deck.Pop()
        c.SetUniq u
      else
        c = new Card(@scene)
        c.FaceDown()
        c.Attack()
    if lay == "deck"
      c.FaceDown()
      c.SetUniq "#{ @index }_{ @inDeckSize++ }"
#      if c.uniq != 0
#        setTimeout (->
#          c.SetUniq "#{ @index }_{ @inDeckSize++ }"
#          c.SetFront 0
#        ), 10

    else
      c.SetUniq u
    @decks[lay].Push c, s
  return

