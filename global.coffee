container = null
face = null
mouse = null

InitGlobal = ->
  container = document.getElementById "page"
  face = new Face()
  mouse = new Mouse()
  Card::SetHTML = Face::SetHTML

ExitPage = ->
#$('#page').hide()
  $('#home').show()
  container.innerHTML = ""

log = (x)->
  console.dir x


String::format = (params)->
  @replace /{([^{}]+)}/gm, (match, name) -> "#{params[name]}"


tmpCardInfo = []
CardInfo = (c, f) ->
  if tmpCardInfo[c.id]
    f(tmpCardInfo[c.id])
  else
    $.get("/cards/i18n/zh-CN/#{c.id}.json", ((data, status)->
      d = JSON.parse data
      tmpCardInfo[c.id] = d
      f(d)
    ))

CurentTime = ->
  now = new Date();
  year = now.getFullYear() #年
  month = now.getMonth() + 1 #月
  day = now.getDate() #日

  hh = now.getHours() #时
  mm = now.getMinutes() #分
  ss = now.getSeconds() #秒
  clock = year + "-"
  if(month < 10)
    clock += "0"
  clock += month + "-"
  if(day < 10)
    clock += "0"
  clock += day + " "
  if(hh < 10)
    clock += "0"
  clock += hh + ":"
  if (mm < 10)
    clock += '0'
  clock += mm + ":"
  if (ss < 10)
    clock += '0'
  clock += ss
  clock


gui = (id, classs) ->
  camera = undefined
  scene = undefined
  renderer = undefined
  controls = undefined

  onWindowResize = ->
    camera.aspect = window.innerWidth / window.innerHeight
    camera.updateProjectionMatrix()
    renderer.setSize window.innerWidth, window.innerHeight
    render()
    return

  animate = ->
    requestAnimationFrame animate
    TWEEN.update()
    controls.update()
    render()
    return

  render = ->
    renderer.render scene, camera
    return

  do ->
    InitGlobal()
    camera = new (THREE.PerspectiveCamera)(40, window.innerWidth / window.innerHeight, 1, 10000)
    camera.position.z = 3000
    #camera.position.y = -2500;
    scene = new (THREE.Scene)
    renderer = new (THREE.CSS3DRenderer)
    renderer.setSize window.innerWidth, window.innerHeight
    renderer.domElement.style.position = 'absolute'

    @game = document.createElement 'div'
    @game.id = id
    container.appendChild @game
    @game.appendChild renderer.domElement
    controls = new (THREE.TrackballControls)(camera, renderer.domElement)
    #    controls.rotateSpeed = 0.5;
    #    controls.minDistance = 500;
    #    controls.maxDistance = 6000;
    controls.addEventListener 'change', render
    controls.noRotate = true
    controls.noZoom = true
    controls.noPan = true
    controls.noRoll = true
    window.addEventListener 'resize', onWindowResize, false
    new classs(scene)
    #new YGO(scene)
    animate()
    return
