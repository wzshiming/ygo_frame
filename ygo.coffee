YGO = (@scene) ->
  @players = []
  t = this
  # 这里是注册接收服务器通信的部分
  WsGameRegister (e) ->
    if e.method
      if typeof t[e.method] == 'function'
        t[e.method] e.args
      else
        MsgErr e.method
  return

#游戏初始化
# index int 玩家自身的索引
# users []struct {
#   hp   int
#   name string
#}
YGO::init = (args) ->
  @users = args.users
  @index = args.index
  if @users instanceof Array
    for v,i in @users
      k = i + @index
      if k >= @users.length
        k = k - @users.length
      if k == 0
        @playerindex = i
        angle = 0
        x = 0
        y = 0
      else if k == 1
        angle = PI
        x = 0
        y = 0
      else if k == 2
        angle = PI * 0.5
        x = 0
        y = 0
      else if k == 3
        angle = PI * 1.5
        x = 0
        y = 0
      @players[i] = new Player(@scene, i, x, y, angle, v)
#MsgInfo '游戏开始了'
    face.InitGame()

  else
    MsgErr '初始化游戏错误'

# 待废除
YGO::remind = (args) ->
  c = Card::Find(args.uniq)
  if c
    c.Remind()
  else
    MsgErr "remind err"



# 怪兽卡进入场地时的 底部文字
# uniq int 卡牌
# params map #怪兽属性变更
      #比如变更种族之后吧新的种族名 发过来 如  Races:战士族
      #以及攻击力防御力之类的怪兽属性的提示
YGO::setCardFace = (args) ->
  c = Card::Find(args.uniq)
  if c
    for own k,v of args.params
      c.SetHTML k, v
  else
    MsgErr "setCardFace err"
  return

#移动 卡牌位置 如果  不存在则新建一张
# uniq int 卡牌
# pos string
  #deck    // 卡组
  #hand    // 手牌
  #mzone   // 怪兽区
  #szone   // 魔陷区
  #grave   // 墓地
  #removed // 移除
  #extra   // 额外
  #field   // 场地
  #overLay //
  #fzone   //
  #pzone   //
  #portrait // 玩家牌
YGO::moveCard = (args) ->
  @players[args.master].Join args.uniq, args.pos
  return

#修改卡牌正面
# uniq int 卡牌
# desk int 卡牌索引
YGO::setFront = (args) ->
  c = Card::Find(args.uniq)
  if c
    c.SetFront(args.desk)
  else
    MsgErr "setFront err"

  return

#修改卡牌表示形式
# uniq int 卡牌
# expr int 表示形式
  #  LE_None le_type = 0
  #  LE_FaceUp   le_type = 1 << (32 - 1 - iota) // 正面朝上
  #  LE_FaceDown                                // 正面朝下
  #  LE_Attack                                  // 攻击状态
  #  LE_Defense                                 // 守备状态
  #  LE_FaceUpAttack    = LE_FaceUp | LE_Attack    // 朝上攻击
  #  LE_FaceDownAttack  = LE_FaceDown | LE_Attack  // 朝下攻击
  #  LE_FaceUpDefense   = LE_FaceUp | LE_Defense   // 朝上防御
  #  LE_FaceDownDefense = LE_FaceDown | LE_Defense // 朝下防御
YGO::exprCard = (args) ->
  c = Card::Find(args.uniq)
  if c
    if (args.expr & 1 << 30) != 0
      c.FaceUp()
    else if (args.expr & 1 << 29) != 0
      c.FaceDown()
    if (args.expr & 1 << 28) != 0
      c.Attack()
    else if (args.expr & 1 << 27) != 0
      c.Defense()
  else
#MsgErr "exprCard err"
  return

#设置当前回合数
#round 回合数
YGO::flagName = (args) ->
  face.RoundSize args.round
  #face.SetHTML "回合数", args.round
  return

#右上的信息栏
#准备废除
YGO::setFace = (args) ->
  for own k,v of args
    face.SetHTML k, v

#右下的信息栏
#message string 一段待格式化的字符串
#params map 格式化的数据
# 如 "{self}受到{num}基本分伤害！", {self:"玩家",num:"100"}
YGO::message = (args) ->
  for own k,v of args.params
    if v == @users[@playerindex].name
      args.params[k] = "您"
    c = Card::Find(v)
    if c
      CardInfo c, (data)->
        args.params[k] = " #{data["type"]} 「#{data["name"]}」 "

  m = args.message.format args.params
  face.Msg m
  return


#当前处于的阶段以及 时间
#step int  阶段序号
#wait int 阶段时间 除以1000000000 单位就是秒了
YGO::flagStep = (args) ->
#  t = this
#  if t.stepInterval
#    window.clearInterval t.stepInterval
  p = if args.step == 0
    "Chain"
  else if args.step == 1
    "DP"
  else if args.step == 2
    "SP"
  else if args.step == 3
    "MP1"
  else if args.step == 4
    "BP"
  else if args.step == 5
    "MP2"
  else if args.step == 6
    "EP"
  else
    "现在什么阶段?"
  ti = args.wait / 1000000000
  face.Gage ti, args.step
  return

#改变生命值
#uniq int  玩家卡牌
#hp int 改变之后的生命值
YGO::changeHp = (args)->
  c = Card::Find(args.uniq)
  if c
    c.SetHTML "HP", "#{args.hp}"

#改变玩家卡牌的头像
#uniq int  玩家卡牌
#desk int 玩家卡牌的头像索引
YGO::setPortrait = (args)->
  c = Card::Find(args.uniq)
  if c
    c.SetPortrait args.desk

#对方玩家触碰的卡牌
#uniq int  卡牌
YGO::touch = (args)->
  c = Card::Find(args.uniq)
  if c
    c.MoveAdd args

#gameover
YGO::over = ()->
  ExitPage()
  MsgInfo "游戏结束"

# 游戏中提示发动时的红边框
# uniqs []int 卡牌
YGO::trigg = (args) ->
  if @trigger
    for v in @trigger
      c = Card::Find v
      if c
        c.SetClass "card"
  @trigger = args.uniqs
  if @trigger
    for v in @trigger
      c = Card::Find v
      if c
        c.SetClass "card0"


# 从卡组选择卡牌的时候 弹出来给玩家选择的 对方也可以看到
# master int 哪位玩家
# uniqs []int 卡牌
YGO::setPick = (args) ->
  pl = @players[args.master]
  pick = pl.decks.pick
  while pick.Length() != 0
    c = pick.Pop()
    if c.hold
      c.Update()
    else
      pl.Join c.uniq, "deck"
  for v in args.uniqs
    pl.Join v, "pick"