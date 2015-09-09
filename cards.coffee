# 卡牌组
Cards = ->
  return

Cards:: = []


#压入
Cards::Push = (c) ->
  if c
    c.Placed()
    @push c
    c.SetHold this
  return

#弹出
Cards::Pop = ->
  c = @pop()
  if c
    c.SetHold()
  c

Cards::Insert = (i, c) ->
  @splice(i, 0, c)
  c.SetHold this
  return
#移除
Cards::Remove = (i) ->
  c = @splice(i, 1)[0]
  c.SetHold()
  c

#拿起
Cards::Placed = (u) ->
  i = @Index(u)
  if i != -1
    @Remove i
  i

#获取索引
Cards::Index = (u) ->
  if typeof u == "object"
    for v, k in this
      if v == u
        return k
  else
    for v, k in this
      if v.uniq == u
        return k
  return -1

#清空
Cards::Clear = ->
  while @Length() != 0
    @Pop().Remove()
  return

#全部移动至
Cards::MoveTo = (to) ->
  while @Length() != 0
    to.Push @Pop()
  return

Cards::Length = ->
  @length