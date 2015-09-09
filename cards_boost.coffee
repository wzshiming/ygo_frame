gridX = (x) ->
  x * 130 - 1300

gridY = (y) ->
  -(y * 130)

cards_boost = (@pos, @s = 100)->
  return

cards_boost:: = new Cards()

cards_boost::Update = (s = @s) ->
  if @queue.length != 0
    @queue.unshift s
    @queue.pop()
    return

  t = this
  setTimeout (->
    t.Flash t.queue.pop()
    e = t.queue.pop()
    if e
      t.Update e
  ), s

  return

cards_boost::Flash = (s = @s) ->
  for v, k in this
    v.MoveTo @pos(k), s
  return

cards_boost::Placed = (u, s = null) ->
  i = Cards::Placed.call this, u
  @Update s
  i

cards_boost::Insert = (i, c, s = null) ->
  if c
    Cards::Insert.call this, i, c
    for v,k in @event
      c.addEventListener v...
    @Update s
  return

cards_boost::Remove = (i, s = null) ->
  c = Cards::Remove.call this, i
  if c
    for v,k in @event
      c.removeEventListener v...
  @Update s
  c

cards_boost::Push = (c, s = null)->
  if c
    Cards::Push.call this, c
    for v,k in @event
      c.addEventListener v...
    @Update s
  return

cards_boost::Pop = (s = null) ->
  c = Cards::Pop.call this
  if c
    for v,k in @event
      c.removeEventListener v...
  @Update s
  c

cards_boost::addEventListener = (s, f, b) ->
  l = [s, f, b]
  @event.push l
  for v,k in this
    v.addEventListener l...
  return


# 堆在一起的
Pile = (@x = 0, @y = 0, @a = 0, @h = 1)->
  @queue = []
  @event = []
  @rotation = (new (THREE.Matrix4)).makeRotationZ(@a)
  return

Pile:: = new cards_boost((i)->
  object = new (THREE.Object3D)
  object.matrix.makeTranslation gridX(@x), gridY(@y), @h + i
  object.applyMatrix @rotation
  object.position
)


Dig = (@x = 0, @y = 0, @a = 0, @h = 1, @s = 100)->
  @queue = []
  @event = []
  @rotation = (new (THREE.Matrix4)).makeRotationZ(@a)
  @p = 0
  t = this
  @addEventListener "mouseover", (->
    if t.p == 1
      return
    t.p = 1
    t.Update @s
    return
  ), false
  @addEventListener "mouseout", (->
    if t.p == 0
      return
    t.p = 0
    t.Update @s
    return
  ), false
  return

Dig:: = new cards_boost (i)->
  object = new (THREE.Object3D)
  if @p == 0
    object.matrix.makeTranslation gridX(@x), gridY(@y), @h + 1
    object.applyMatrix @rotation
    object.position
  else
    object.matrix.makeTranslation gridX(@x) + ( i - @Length() / 2) * 5, gridY(@y), @h + 50 + i * 2
    z = 1
    if @Length() > 40
      z = 1 - (@Length() - 40) / @Length()
    object.applyMatrix (new (THREE.Matrix4)).makeRotationZ(@a - (i - @Length() / 2) / 180 * PI * 9 * z)
    object.position #.multiplyScalar 0.9


# 位置 伸缩
flex = (x, y, a, r, i, l, h = 1)->
  object = new (THREE.Object3D)
  z = 1
  if l > r
    z = 1 - (l - r) / l
  object.matrix.makeTranslation gridX(x + r / 2 + 0.5 + (i - l / 2) * 1.2 * z), gridY(y), i + h
  object.applyMatrix a
  object.position

#手上的
Hand = (@x = 0, @y = 0, @a = 0, @b = 8, @c = 10)->
  @queue = []
  @event = []
  @rotation = (new (THREE.Matrix4)).makeRotationZ(@a)
  return

Hand:: = new cards_boost (i)->
  flex(@x, @y, @rotation, @b, i, @Length())


Vast = (@x = 0, @y = 0, @a = 0, @b = 8, @c = 10)->
  @queue = []
  @event = []
  @rotation = (new (THREE.Matrix4)).makeRotationZ(@a)
  return

Vast:: = new cards_boost((i)->
  l = parseInt(i / @c)
  m = i % @c

  if l == parseInt(@Length() / @c)
    z = @Length() % @c
    flex(@x, @y + l * 1.5, @rotation, @b, m, z)
  else
    flex(@x, @y + l * 1.5, @rotation, @b, m, @c)
)


#可翻页的
Paging = (@x = 0, @y = 0, @a = 0, @b = 8, @c = 10, @l = 8)->
  @queue = []
  @event = []
  @up = new Pile(@x, @y - 2, @a)
  @down = new Pile(@x + @b, @y - 2, @a)
  @show = new Vast(@x, @y, @a, @b, @c)
  @rotation = (new (THREE.Matrix4)).makeRotationZ(@a)
  t = this
  @up.addEventListener "click", (->
    t.Prev()
  ), false
  @down.addEventListener "click", (->
    t.Next()
  ), false
  return

Paging::addEventListener = (s, f, b) ->
#@up.addEventListener s,f,b
#@down.addEventListener s,f,b
  @show.addEventListener s, f, b
  return

Paging::Push = (c, s = null)->
  if @show.Length() > @c * @l - 1
    @down.Push c, s
  else
    @show.Push c, s
  return

Paging::Pop = (s = null) ->
  if @down.Length() != 0
    @down.Pop s
  else if @show.Length() != 0
    @show.Pop s
  else if @up.Length() != 0
    @up.Pop s
  return


Paging::Clear = ->
  @down.Clear()
  @show.Clear()
  @up.Clear()
  return

Paging::Prev = ->
  @show.MoveTo @down
  for i in [0...@c * @l]
    @show.Push @up.Pop()

Paging::Next = ->
  @show.MoveTo @up
  for i in [0...@c * @l]
    @show.Push @down.Pop()

#横着铺开的
Rows = (@x = 0, @y = 0, @a = 0)->
  @queue = []
  @event = []
  @rotation = (new (THREE.Matrix4)).makeRotationZ(@a)
  return

Rows:: = new cards_boost (i)->
  object = new (THREE.Object3D)
  object.matrix.makeTranslation gridX(@x + i * 2), gridY(@y), i + 1
  object.applyMatrix @rotation
  object.position


# 提示挑选的
Pick = (@x = 0, @y = 0, @a = 0, @b = 8, @c = 15)->
  @queue = []
  @event = []
  @rotation = (new (THREE.Matrix4)).makeRotationZ(@a)
  return

Pick:: = new cards_boost (i)->
  flex(@x, @y, @rotation, @b, i, @Length(), 500)

Pick::Push = (c, s = null)->
  if c
    @push c
    for v,k in @event
      c.addEventListener v...
    @Update s
  return

Pick::Pop = (s = null) ->
  c = @pop this
  if c
    for v,k in @event
      c.removeEventListener v...
  @Update s
  c

#Pick::Push = (c, s = null)->
#  if c
#    @push c
#    @Update s
#  return
#
#Pick::Pop = (s = null) ->
#  r = @pop this
#  @Update s
#  r
#
#Pick::Homing = (hold) ->
#  while @Length() != 0
#    c = @Pop()
#    if c.hold
#      c.Update()
#    else
#      hold.Push c
#  return
