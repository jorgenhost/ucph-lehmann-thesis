// A cross-section of the Earth with seismic rays: a nod to Inge Lehmann's
// discovery of the inner core (Lehmann 1936). Drawn natively, no image files.
#import "../src/colors.typ" as colors

#let earth(size: 70mm) = {
  let r = size / 2
  let c = (r, r)
  let at(angle, radius) = (r + radius * calc.sin(angle), r - radius * calc.cos(angle))
  box(width: size, height: size, {
    place(circle(radius: r, fill: colors.ucph-light.grey, stroke: none))
    place(dx: r - 0.545 * r, dy: r - 0.545 * r, circle(radius: 0.545 * r, fill: colors.ucph-light.petroleum, stroke: none))
    place(dx: r - 0.19 * r, dy: r - 0.19 * r, circle(radius: 0.19 * r, fill: colors.red, stroke: none))
    // rays from an epicentre at the top
    let src = at(0deg, r)
    for (target, bend) in ((150deg, 0.16), (165deg, 0.08), (180deg, 0.0), (125deg, 0.30), (60deg, 0.55), (95deg, 0.42)) {
      let dst = at(target, r)
      let mid = ((src.at(0) + dst.at(0)) / 2, (src.at(1) + dst.at(1)) / 2)
      // bend the ray towards the centre-right to suggest refraction
      let ctrl = (mid.at(0) + bend * r * 0.6, mid.at(1) + bend * r * 0.25)
      place(curve(
        stroke: 0.7pt + colors.ucph-dark.blue,
        curve.move(src),
        curve.quad(ctrl, dst),
      ))
    }
    place(dx: src.at(0) - 2.5pt, dy: src.at(1) - 2.5pt, circle(radius: 2.5pt, fill: colors.ucph-dark.blue))
  })
}
