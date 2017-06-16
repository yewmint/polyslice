class Point

  @ZERO: new Point(0, 0)

  constructor: (@x, @y)->

  distance: (point)->
    dx = point.x - @x
    dy = point.y - @y
    return Math.sqrt(dx * dx + dy * dy)

  same: (point)->
    return point.x is @x and point.y is @y

  clone: ()->
    return new Point(@x, @y)

  offset: (point)->
    return new Point(@x + point.x, @y + point.y)

class Vertex extends Point

  constructor: (x, y, @segOut = null, @segIn = null)->
    super(x, y)

  clone: ()->
    return new Vertex(@x, @y, @segOut, @segIn)

  offset: (point)->
    return new Vertex(@x + point.x, @y + point.y, @segOut, @segIn)

class Intersection extends Point

  constructor: (x, y, @segA = null, @segB = null, @isInner)->
    super(x, y)

  clone: ()->
    return new Intersection(@x, @y, @segA, @segB)

  offset: (point)->
    return new Intersection(@x + point.x, @y + point.y, @segA, @segB)

class Segment

  constructor: (@vtxA, @vtxB)->

  vec2: ()->
    return Vector2.fromPoints(@vtxA, @vtxB)

  vec3: ()->
    return Vector2.fromPoints(@vtxA, @vtxB).vec3()

  left: (point)->
    va = Vector2.fromPoints(point, @vtxA)
    vb = Vector2.fromPoints(point, @vtxB)
    return va.cross(vb) > 0

  same: (seg)->
    return (@vtxA.same(seg.vtxA) and @vtxB.same(seg.vtxB)) or
      (@vtxA.same(seg.vtxB) and @vtxB.same(seg.vtxA))

  intersect: (seg)->
    segA = @
    segB = seg

    r_px = segA.vtxA.x
    r_py = segA.vtxA.y
    r_dx = segA.vtxB.x - segA.vtxA.x
    r_dy = segA.vtxB.y - segA.vtxA.y

    s_px = segB.vtxA.x
    s_py = segB.vtxA.y
    s_dx = segB.vtxB.x - segB.vtxA.x
    s_dy = segB.vtxB.y - segB.vtxA.y

    H = s_dx * r_dy - r_dx * s_dy

    if H is 0
      return null

    Hrt = s_dx * (s_py - r_py) - s_dy * (s_px - r_px)
    Hst = r_dx * (s_py - r_py) - r_dy * (s_px - r_px)

    rt = Hrt / H
    st = Hst / H

    if rt < 0 or rt > 1 then return null
    if st < 0 or st > 1 then return null

    x = r_px + r_dx * rt
    y = r_py + r_dy * rt

    isInner = true

    if rt is 0 or st is 0 or rt is 1 or st is 1
      isInner = false

    return new Intersection(x, y, segA, segB, isInner)

class Polygon

  constructor: (points)->
    if points.length <= 2 then return null

    @vtxs = []

    for point in points
      @vtxs.push new Vertex(point.x, point.y)

    @vtxs.forEach (vertex, index, arr)=>
      nextVertex = arr[(index + 1) % arr.length]
      prevVertex = arr[(index - 1 + arr.length) % arr.length]
      vertex.segOut = new Segment(vertex, nextVertex)
      vertex.segIn = new Segment(prevVertex, vertex)

  segOnEdge: (seg)->
    for vtx in @vtxs
      if seg.same(vtx.segOut)
        return true
    return false

  pointInside: (point)->
    ray =   new Segment(point, point.offset(new Point(-10000, 0)))
    interCnt = 0
    innerCnt = 0
    interPoints = []
    for vtx in @vtxs
      seg = vtx.segOut
      inter = ray.intersect(seg)
      if inter
        interPoints.push inter
    interPoints = _.uniq(interPoints, (point)->
      return { x: point.x, y: point.y }
    )
    return interPoints.length % 2 is 1

  segInside: (seg)->
    for vtx in @vtxs
      inter = vtx.segOut.intersect(seg)
      if inter and inter.isInner
        return false
    centerX = (seg.vtxA.x + seg.vtxB.x) / 2
    centerY = (seg.vtxA.y + seg.vtxB.y) / 2
    center = new Point(centerX, centerY)
    return @pointInside(center)

  clone: ()->
    points = []
    for vertex in @vtxs
      points.push vertex.clone()
    return new Polygon(points)

  offset: (point)->
    points = []
    for vertex in @vtxs
      points.push vertex.offset(point)
    return new Polygon(points)

class Vector2

  @fromPoints: (pointA, pointB)->
    dx = pointB.x - pointA.x
    dy = pointB.y - pointA.y
    return new Vector2(dx, dy)

  constructor: (@x, @y)->

  perpendicular: ()->
    newDest = new Point(@y, -@x)
    return new Vector2(Point.ZERO, newDest)

  normalize: ()->
    distance = @distance()
    return new Vector2(@x / distance, @y / distance)

  dot: (vec)->
    return @x * vec.x + @y * vec.y

  cross: (vec)->
    return @vec3().cross(vec.vec3()).z

  radians: (vec)->
    dot = @dot(vec)
    cosVal = dot / @distance() / vec.distance()
    return Math.acos(cosVal)

  distance: ()->
    Point.ZERO.distance(new Point(@x, @y))

  vec3: ()->
    return new Vector3(@x, @y, 0)

class Vector3

  constructor: (@x, @y, @z)->

  cross: (vec)->
    vecA = @
    vecB = vec
    x = vecA.y * vecB.z - vecA.z * vecB.y
    y = vecA.z * vecB.x - vecA.x * vecB.z
    z = vecA.x * vecB.y - vecA.y * vecB.x
    return new Vector3(x, y, z)

module.exports = {
  Point: Point
  Vertex: Vertex
  Intersection: Intersection
  Segment: Segment
  Polygon: Polygon
  Vector2: Vector2
  Vector3: Vector3
}
