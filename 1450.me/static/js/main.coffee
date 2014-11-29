document.addEventListener "DOMContentLoaded", ->
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
    if lastX?
      d = Math.sqrt(Math.pow(lastX - x, 2) + Math.pow(lastY - y, 2))
      if d > 70
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
