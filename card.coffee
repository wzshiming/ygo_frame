# 永远朝向视口
Shade = (@scene, t) ->
  @element = document.createElement('div')
  @element.className = 'shade'
  @element.innerHTML = t
  @object = new (THREE.CSS3DObject)(@element)
  @object.position.x = 0
  @object.position.y = 0
  @object.position.z = 2000
  @scene.add @object
  return


# 单面的元素
Element = (@scene) ->
  @element = document.createElement('div')
  @object = new (THREE.CSS3DSprite)(@element)
  @object.position.x = 0
  @object.position.y = 0
  @object.position.z = 2000
  @scene.add @object
  return


#双面的卡片
Card = (@scene, id = 0, b = 0) ->
  @element = document.createElement('div')
  @infos = {}
  @info = document.createElement('div')
  @element.appendChild @info
  @info.className = "card_text"
  @img = document.createElement('img')
  @element.appendChild @img
  #@img.className = "card"
  @SetFront id

  @elementB = document.createElement('img')
  #@elementB.className = "card"

  @SetClass "card"
  @SetBack b
  @object = new (THREE.CSS3DDoubleObject)(@element, @elementB)
  @object.position.x = Math.random() * 4000 - 2000
  @object.position.y = Math.random() * 4000 - 2000
  @object.position.z = 4000
  @hold = null
  @scene.add @object

  @info.hold = this
  @img.hold = this
  @element.hold = this
  @elementB.hold = this
  @uniq = 0
  @x = @object.position.x
  @y = @object.position.y
  @z = @object.position.z
  @ry = 0
  @rz = 0
  #设置卡片 的属性显示

  return

#Card::All = []

Card::Index = {}

Card::SetClass = (name) ->
  @img.className = name
  @elementB.className = name

Card::Find = (uniq) ->
  @Index[uniq]

Card::SetUniq = (uniq) ->
  delete @Index[@uniq] if @uniq
  @uniq = uniq
  @Index[@uniq] = this
  return

Card::SetPortrait = (id) ->
  @id = 0
  @img.src = "/cards/derivate/" + id + ".jpg"

#设置正面
Card::SetFront = (@id) ->
  @img.src = "/cards/img/" + @id + ".jpg"
  return

#设置背面
Card::SetBack = (@b) ->
  @elementB.src = "/cards/cover/" + @b + ".jpg"
  return

#移除
Card::Remove = ->
  @Placed()
  @scene.remove @object
  delete @Index[@uniq] if @uniq
  return

#设置所在组
Card::SetHold = (@hold = null) ->

Card::Update = (s = null) ->
  if @hold
    @hold.Update s

#拿起
Card::Placed = ->
  if @hold
    return @hold.Placed(this)
  -1

Card::Nature = (s = 1000)->
  t1 = (Math.random() - 0.5) * 10
  t2 = (Math.random() - 0.5) * 10
  Translate @object, {x: @x + t1, y: @y + t2, z: @z}, s

  t = (Math.random() - 0.5) * PI / 20
  Rotate @object, {y: @ry, z: @rz + t}, s

#移动至
Card::Move = (pos, s = 500) ->
  b = false
  p = {}
  if typeof pos.x == "number" and @x != pos.x
    p.x = pos.x
    b = true
  if typeof pos.y == "number" and @y != pos.y
    p.y = pos.y
    b = true
  if typeof pos.z == "number" and @z != pos.z
    p.z = pos.z
    b = true
  unless b
    return
  Translate @object, p, s

Card::MoveAdd = (pos, s = 100) ->
  p = {}
  unless typeof pos.x == "number"
    pos.x = 0
  p.x = pos.x + @x
  unless typeof pos.y == "number"
    pos.y = 0
  p.y = pos.y + @y
  unless typeof pos.z == "number"
    pos.z = 0
  p.z = pos.z + @z
  if p.x
    p.x += (Math.random() - 0.5) * 10
  if p.y
    p.y += (Math.random() - 0.5) * 10
  Translate @object, p, s
  t = (Math.random() - 0.5) * PI / 20
  Rotate @object, {y: @ry, z: @rz + t}, s
  #Translate @object, pos, s
  #@Nature s

  return


Card::MoveTo = (pos, s = 500) ->
  b = false
  p = {}
  if typeof pos.x == "number" and @x != pos.x
    @x = pos.x
    p.x = @x
    b = true
  if typeof pos.y == "number" and @y != pos.y
    @y = pos.y
    p.y = @y
    b = true
  if typeof pos.z == "number" and @z != pos.z
    @z = pos.z
    p.z = @z
    b = true
  unless b
    return

  if p.x
    p.x += (Math.random() - 0.5) * 10
  if p.y
    p.y += (Math.random() - 0.5) * 10

  Translate @object, p, s

  t = (Math.random() - 0.5) * PI / 20
  Rotate @object, {y: @ry, z: @rz + t}, s
  #Translate @object, pos, s
  #@Nature s
  return

#调整姿态
Card::PoseTo = (pose, s = 1000) ->
  Move @object, pose, s
  return

#面朝上
Card::FaceUp = (s = 200) ->
  if @ry == 0
    return
  @ry = 0
  Rotate @object, {y: @ry}, s
  #@Nature s
  return

#面朝下
Card::FaceDown = (s = 200) ->
  if @ry == PI
    return
  @ry = PI
  Rotate @object, {y: @ry}, s
  #@Nature s
  return

#攻击表示
Card::Attack = (s = 200)  ->
  if @rz == 0
    return
  @rz = 0
  t = (Math.random() - 0.5) * PI / 20
  Rotate @object, {z: @rz + t}, s
  #Rotate @object, { z: @rz }, s
  #@Nature s
  return

#防御表示
Card::Defense = (s = 200) ->
  if @rz == PI / 2
    return
  @rz = PI / 2
  t = (Math.random() - 0.5) * PI / 20
  Rotate @object, {z: @rz + t}, s
  #Rotate @object, { z: @rz }, s
  #@Nature s
  return

Card::Remind = ->
  this.SetHTML("状态", "可以连锁")
  window.setTimeout (->
    this.SetHTML("状态")
  ), 10000
#停止移动
Card::Stop = ->
  TWEEN.remove @object
  return

Card::addEventListener = (s, f, b) ->
#log ["add",s,f,b]
  @element.addEventListener s, f, b
  @elementB.addEventListener s, f, b
  return

Card::removeEventListener = (s, f, b) ->
#log ["remove",s,f,b]
  @element.removeEventListener s, f, b
  @elementB.removeEventListener s, f, b
  return
