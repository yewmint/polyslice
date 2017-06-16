geometry = require("./geometry.coffee")

if (not String.prototype.format)
  String.prototype.format= ()->
    args = arguments
    return this.replace(/\{(\d+)\}/g, (s,i)->
      return args[i]
    )

class Painter

  color: "#888888"
  x: 0
  y: 0

  constructor: (parentId, @width, @height)->
    @parent = document.getElementById(parentId);
    @parent.innerHTML = '<canvas width="{0}" height="{1}"></canvas>'.format(@width, @height);
    @canvas = @parent.firstChild;
    @context = @canvas.getContext('2d');
    @_enableCursor()

  setColor: (@color)->

  paintPoint: (point)->
    p = @_convCoord(point)
    @context.fillStyle = @color
    @context.beginPath()
    @context.arc(p.x, p.y, 5, 0, 2*Math.PI)
    @context.fill()

  paintSeg: (seg)->
    @context.beginPath()
    @context.strokeStyle = @color
    pointA = @_convCoord(seg.vtxA)
    pointB = @_convCoord(seg.vtxB)
    @context.moveTo(pointA.x, pointA.y)
    @context.lineTo(pointB.x, pointB.y)
    @context.stroke()

  paintPolygon: (poly)->
    for vtx in poly.vtxs
      @paintSeg vtx.segOut

  clear: ()->
    @context.clearRect(0, 0, @width, @height)

  getCursor: ()->
    return new geometry.Point(@x, @y)

  _convCoord: (point)->
    return new geometry.Point(point.x, @height - point.y)

  _parseCursor: (x, y)->
    bbox = canvas.getBoundingClientRect()
    return {
      x: x - bbox.left * (canvas.width / bbox.width) || 0
      y: y - bbox.top  * (canvas.height / bbox.height) || 0
  }

  _enableCursor: ()->
    @canvas.addEventListener("mousemove", (e)=>
      x = e.clientX
      y = e.clientY
      bbox = @canvas.getBoundingClientRect()
      @x = x - bbox.left * (@canvas.width / bbox.width) || 0
      y = y - bbox.top * (@canvas.height / bbox.height) || 0
      @y = @height - y
    , false)

module.exports = {
  Painter: Painter
}
