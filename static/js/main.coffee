document.addEventListener "DOMContentLoaded", ->
  map = document.getElementById("mapcontainer")
  avatar = document.getElementById("avatar")
  header_inner = document.getElementById("header_inner")
  header_lower = document.getElementById("header_lower")
  header_rect = header_inner.getBoundingClientRect()

  was_in_zone = false
  @waiting_for_frame = false
  @waiting_for_goggle_frame = false
  arcs = [
    [103, 26, 60, 19],
    [55, 17, 18, 23],
    [14, 25, 60, 14],
    [60, 14, 56, 24],
    [56, 24, 88, 37]
  ]

  clamp = (v) ->
    Math.max Math.min(v, 1.0), 0.0

  moving_average = (period) ->
    @nums = []
    return (num) =>
        @nums.push num
        if  @nums.length > period
            @nums.splice 0, 1
        vsum = @nums.reduce (t, s) -> t + s
        n = Math.min period, @nums.length
        return vsum / n

  if window.DeviceOrientationEvent?
      ma = moving_average 10
      @inital_motion = "none"
      update_wiggle = (event) =>
        @waiting_for_google_frame = false
        acc = event.accelerationIncludingGravity.z
        if @inital_motion is "none"
          @inital_motion = acc
        else
          avg = ma(acc)
          percent = (@inital_motion - avg) / 3
          if percent < 0
            @inital_motion = avg
          if percent > 1
            @inital_motion = avg + 3
          goggles clamp percent

      window.ondevicemotion = (event) =>
        if not @waiting_for_google_frame
          requestAnimationFrame -> update_wiggle(event)
          @waiting_for_google_frame = true

  goggles = (percent) ->
      $left = document.getElementById "goggleLeft"
      $right = document.getElementById "goggleRight"
      $left.style.marginTop = "#{-27 * percent}px"
      $left.style.marginLeft = "#{4 * percent}px"
      $left.style.webkitTransform = "scaleY(#{1 - 0.25 * percent}) rotate(#{-20 * percent}deg)"
      $left.style.mozTransform = "scaleY(#{1 - 0.25 * percent}) rotate(#{-20 * percent}deg)"
      $left.style.oTransform = "scaleY(#{1 - 0.25 * percent}) rotate(#{-20 * percent}deg)"
      $left.style.transform = "scaleY(#{1 - 0.25 * percent}) rotate(#{-20 * percent}deg)"
      $right.style.marginTop = "#{-27 * percent}px"
      $right.style.marginLeft = "#{-4 * percent}px"
      $right.style.webkitTransform = "scaleY(#{1 - 0.25 * percent}) rotate(#{20 * percent}deg)"
      $right.style.mozTransform = "scaleY(#{1 - 0.25 * percent}) rotate(#{20 * percent}deg)"
      $right.style.oTransform = "scaleY(#{1 - 0.25 * percent}) rotate(#{20 * percent}deg)"
      $right.style.transform = "scaleY(#{1 - 0.25 * percent}) rotate(#{20 * percent}deg)"

  scroll = =>
    [last_scroll, last_height] = [window.scrollY, window.innerHeight]
    if last_scroll < last_height and not @waiting_for_frame
      requestAnimationFrame update_scroll
      @waiting_for_frame = true

  update_scroll = =>
    @waiting_for_frame = false
    header_height = header_rect.bottom - header_rect.top
    # consoe.log "Header #{header_height} window #{windo}
    padding = (window.innerHeight - header_height) / 2
    px = window.scrollY / window.innerHeight
    if px <= 1
      goggles clamp px*2
      header_inner.style.marginTop = "#{(1 + px*2) * padding}px"
      header_lower.style.opacity = 1 - px

  resize = ->
    scroll()
    if window.innerWidth <= 767
      was_in_zone = true
      scale = (window.innerWidth - 20) / 1080
      map.style.webkitTransform = "scale(#{scale})"
      map.style.mozTransform = "scale(#{scale})"
      map.style.msTransform = "scale(#{scale})"
      map.style.transform = "scale(#{scale})"
      map.style.marginBottom = "-#{540 * (1-scale)}px"
    else if was_in_zone
      was_in_zone = false
      map.style.webkitTransform = ""
      map.style.mozTransform = ""
      map.style.msTransform = ""
      map.style.transform = ""
      map.style.marginBottom = ""

  if not /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)
    window.addEventListener "resize", resize
    window.addEventListener "scroll", scroll
  resize()
  plane_data = {}

  schedule_flight = ->
    available = (id for id, data of plane_data when not data['in_flight'])
    if available.length == 0
      setTimeout schedule_flight, 500
      return
    plane_id = available[Math.floor Math.random() * available.length]
    setTimeout (-> fly plane_id), Math.random() * 1500 + 500

  fly = (plane_id) ->
    plane = document.getElementById "plane#{plane_id}"
    plane_data[plane_id]['in_flight'] = true
    data = plane_data[plane_id]
    plane.style.left = if data['right'] then "-#{ydiff}px" else "0px"
    plane.style.top = "0px"
    plane.style.webkitTransform = "rotate(#{if data['right'] then "+" else "-"}180deg)"
    plane_inner = plane.children[0]
    new_rot = if data["right"] then data["rot"] - 180 + 2 * data['extra_arc'] else data["rot"] + 180 - 2 * data['extra_arc']
    plane_inner.style.webkitTransform = "rotate(#{new_rot}deg)"
    @plane = plane
    setTimeout (-> document.getElementById("plane#{plane_id}").classList.add "visible"), 1000
    setTimeout (-> land plane_id), 2800
    schedule_flight()

  land = (plane_id) ->
    plane = document.getElementById "plane#{plane_id}"
    plane.classList.remove "visible"
    setTimeout (-> reset plane_id), 1000

  reset = (plane_id) ->
    plane = document.getElementById "plane#{plane_id}"
    plane_data[plane_id]['in_flight'] = false
    plane.classList.add "red"
    data = plane_data[plane_id]
    plane.style.left = "#{plane_data[plane_id]["left"]}px"
    plane.style.top = "#{plane_data[plane_id]["top"]}px"
    plane.style.webkitTransform = "rotate(0deg)"
    plane.children[0].style.webkitTransform = "rotate(#{plane_data[plane_id]["rot"]}deg)"
    setTimeout (-> plane.classList.remove "red"), 50

  plane_id = 0
  for el in document.getElementsByClassName("city")
    x = el.getAttribute('data-x') * 9 - 5
    el.style.left = x + "px"
    y = el.getAttribute('data-y') * 9 - 5
    el.style.top  = y + "px"
    el.innerHTML = "<div class='tooltip-wrap'><div class='tooltip'><div class='date'>"+el.getAttribute('data-date')+"</div><div class='name'>"+el.getAttribute('data-name')+"</div></div></div>"
    if lastX? and el.className.indexOf("nofly") == -1
      right = lastX < x
      ydiff = Math.abs(lastX - x) / 3
      rot = -180 / Math.PI * (Math.atan2(lastX - x, lastY - y) + .5 * Math.PI )
      extra_arc = 35 - (y - lastY) / 3
      rot = if right then rot - extra_arc else rot + extra_arc
      plane_data[plane_id] =
        right: right
        ydiff: ydiff
        rot: rot
        extra_arc: extra_arc
        left: if right then lastX - x else lastX - x - ydiff
        top: lastY - y - ydiff
        in_flight: false
      plane = "<div class='plane-wrapper' id='plane#{plane_id}' style='left: #{plane_data[plane_id]["left"]}px; top: #{plane_data[plane_id]["top"]}px;  width: #{ydiff}px; height: #{ydiff}px'><div class='#{if right then "right" else "left"}' style='-webkit-transform: rotate(#{rot}deg)'></div></div>"
      el.setAttribute "plane_id", plane_id
      el.innerHTML += plane

      plane_id += 1
    [lastX, lastY] = [x, y]
  schedule_flight()
