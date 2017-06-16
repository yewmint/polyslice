{ Point, Vector2, Polygon, Segment } = require("./geometry.coffee")
{ Painter } = require("./painter.coffee")

painter = new Painter("wrapper", 640, 480)

window.pt = painter

outbox = new Polygon([
  new Point(0, 0)
  new Point(640, 0)
  new Point(640, 480)
  new Point(0, 480)
])

target = new Polygon([
  new Point(253, 358)
  new Point(27, 191)
  new Point(87, 33)
  new Point(260, 121)
  new Point(460, 95)
  new Point(427, 121)
  new Point(548, 197)
])

target2 = new Polygon([
  new Point(194, 384)
  new Point(292, 352)
  new Point(179, 200)
  new Point(348, 75)
  new Point(348, 254)
  new Point(459, 254)
  new Point(384, 369)
  new Point(424, 384)
])

init = (poly)->
  for vtx in poly.vtxs
    vtx.edgeCnt = 2

getRadians = (vtx, seg)->
  va = Vector2.fromPoints(vtx, seg.vtxA)
  vb = Vector2.fromPoints(vtx, seg.vtxB)
  return va.radians(vb)

getDTA = (seg, poly)->
  dt = null
  pradians = null
  for vtx in poly.vtxs
    if vtx.edgeCnt > 0 and seg.left(vtx)
      if vtx isnt seg.vtxA and vtx isnt seg.vtxB
        destVtx = seg.vtxB.segOut.vtxB
        vecTryB = Vector2.fromPoints(seg.vtxB, vtx)
        isInsideB = (()->
          while destVtx isnt vtx
            vecCur = Vector2.fromPoints(seg.vtxB, destVtx)
            if vecCur.cross(vecTryB) < 0
              return false
            destVtx = destVtx.segOut.vtxB
          return true
        )()
        destVtx = seg.vtxA.segIn.vtxA
        vecTryA = Vector2.fromPoints(seg.vtxA, vtx)
        isInsideA = (()->
          while destVtx isnt vtx
            vecCur = Vector2.fromPoints(seg.vtxA, destVtx)
            if vecCur.cross(vecTryA) > 0
              return false
            destVtx = destVtx.segIn.vtxA
          return true
        )()
        console.log "test"
        if isInsideA and isInsideB
          console.log "pass"
          if not dt
            dt = vtx
            pradians = getRadians(vtx, seg)
          else
            radians = getRadians(vtx, seg)
            if radians > pradians
              dt = vtx
              pradians = radians
  return dt

getDTB = (seg, poly)->
  dt = null
  pradians = null
  for vtx in poly.vtxs
    if vtx.edgeCnt > 0 and seg.left(vtx)
      if vtx isnt seg.vtxA and vtx isnt seg.vtxB
        segA = new Segment(seg.vtxA, vtx)
        segB = new Segment(seg.vtxB, vtx)
        if (poly.segOnEdge(segA) or poly.segInside(segA)) and
        (poly.segOnEdge(segB) or poly.segInside(segB))
          if not dt
            dt = vtx
            pradians = getRadians(vtx, seg)
          else
            radians = getRadians(vtx, seg)
            if radians > pradians
              dt = vtx
              pradians = radians
  return dt

getAddEdge = (poly)->
  init(poly)
  stack = [ poly.vtxs[0].segOut ]
  ans = []
  while stack.length > 0
    s0 = stack.pop()
    dt = getDTB(s0, poly)
    if not dt then #continue
    potSegA = new Segment(s0.vtxA, dt)
    potSegB = new Segment(dt, s0.vtxB)
    for s1 in [ potSegA, potSegB ]
      if not poly.segOnEdge(s1)
        if _.find(stack, s1)
          stack = _.without(stack, s1)
        else
          ans.push s1
          stack.push s1
        s1.vtxA.edgeCnt++
        s1.vtxB.edgeCnt++
      else
        s1.vtxA.edgeCnt--
        s1.vtxB.edgeCnt--
    s0.vtxA.edgeCnt--
    s0.vtxB.edgeCnt--
  return ans

curPoly = target2

painter.paintPolygon(outbox)
painter.paintPolygon(curPoly)

window.slice = _.once(()->
  painter.setColor("#ff0000")
  for seg in getAddEdge(curPoly)
    painter.paintSeg(seg)
)

# curSeg = target.vtxs[0].segOut
# curSeg = new Segment(new Point(260, 121), new Point(253, 358))
# painter.paintPoint(getDTB(curSeg, target))
# console.log getDTB(curSeg, target)
