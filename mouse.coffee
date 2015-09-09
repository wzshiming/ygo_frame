orien = (x, y) ->
  len = Math.sqrt x * x + y * y
  if len < 150
    return 0
  a = 0
  a += Math.atan(y / x)
  if x < 0
    if y > 0
      a += PI
    else
      a -= PI
  r = PI / 4
  a += r / 2
  if a >= 0
    1 + parseInt a / r
  else
    8 - parseInt -a / r


Mouse = ->
  return

# 鼠标点击并移动
Mouse::Drag = (c, func)->
  f = ((event) ->
    c = event.toElement.hold
    unless c
      return
    targetX = 1
    targetY = 1
    clientX = event.layerX
    clientY = event.layerY
    c.Move {x: targetX, y: targetY, z: 1000}, 100
    mouseup = ->
      c.MoveAdd {x: 0, y: 0, z: 0}
      if c.hold
        c.hold.Update()
      document.removeEventListener 'mousemove', mousemove
      document.removeEventListener 'mouseup', mouseup
      return
    mousemove = (event0) ->
      ix = event0.layerX - clientX
      iy = clientY - event0.layerY
      c.Move {x: targetX + ix, y: targetY + iy, z: 1000}, 1
      rio = orien(ix, iy)
      if rio != 0
        func c, rio
        mouseup()
      return

    document.addEventListener 'mousemove', mousemove, false
    document.addEventListener 'mouseup', mouseup, false
    return)
  c.addEventListener "mousedown", f, false
  return

#鼠标悬浮显示资料
Mouse::Hint = (c) ->
  f1 = ((event)->
    c = event.toElement.hold
    if c and c.id
      face.ShowCard c
    return
  )
  f2 = ((event)->
    face.ShowCard()
    return
  )
  c.addEventListener "mouseover", f1, false
  c.addEventListener "mouseout", f2, false
  return

#鼠标悬浮抖动 对方也能看到
Mouse::Lay = (c) ->
  f1 = ((event)->
    c = event.toElement.hold
    if c and c.id
      WsSelectable c.uniq, 101
      c.MoveAdd {x: -2, y: -2, z: 100}
    return
  )
  f2 = ((event)->
    c = event.fromElement.hold
    if c and c.id
      WsSelectable c.uniq, 102
      c.MoveAdd {x: 2, y: 2, z: 2}
    return
  )
  c.addEventListener "mouseover", f1, false
  c.addEventListener "mouseout", f2, false
  return

#鼠标悬浮抖动
Mouse::Alone = (c) ->
  f1 = ((event)->
    c = event.toElement.hold
    if c and c.id
      c.MoveAdd {x: -2, y: -2, z: 100}
    return
  )
  f2 = ((event)->
    c = event.fromElement.hold
    if c and c.id
      c.MoveAdd {x: 2, y: 2, z: 2}
    return
  )
  c.addEventListener "mouseover", f1, false
  c.addEventListener "mouseout", f2, false
  return
