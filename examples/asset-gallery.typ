// Overview of the extracted logos, colours, fonts and the publication header.
//   typst compile --root . examples/asset-gallery.typ
#import "@preview/ucph-lehmann-thesis:0.1.0" as ul

#set page(paper: "a4", margin: (x: 20mm, top: 70mm, bottom: 18mm), header: none)
#set text(font: ul.default-font, size: 10pt)
#show heading: set text(font: ul.default-heading-font)

#place(top + left, dy: -70mm, dx: -20mm, ul.ucph-header(lang: "en", lines: ([Asset gallery], [ucph-lehmann-thesis])))

= Logo variants

Each variant is cut from the official logo sheets by `tools/extract-logos.py` and stored as SVG in `assets/logos/`. Use them with `ul.logo("name", width: ..)`.

#let tile(name) = {
  let dark = name.contains("negative")
  block(breakable: false, width: 100%, {
    box(
      width: 100%, height: 27mm, inset: 4mm,
      fill: if dark { ul.colors.red } else { luma(246) },
      align(center + horizon, ul.logo(name, width: 100%, height: 100%, fit: "contain")),
    )
    v(-0.6em)
    text(font: "DejaVu Sans Mono", size: 7.5pt, name)
  })
}
#grid(columns: 3, column-gutter: 6mm, row-gutter: 4mm, ..ul.logo-variants.map(tile))

#pagebreak()
= Colours

#ul.colors.show-color-palette()

#v(4mm)
Print colours from the official CMYK sheet:

#table(
  columns: (auto, auto, auto),
  stroke: none,
  inset: (x: 0pt, right: 10mm, y: 4pt),
  ..(
    ([Logo red, uncoated paper], ul.colors.print.red-uncoated, [C0 M100 Y65 K34]),
    ([Logo red, coated paper], ul.colors.print.red-coated, [C25 M100 Y77 K40]),
    ([Logotype grey], ul.colors.print.logotype-grey, [C0 M0 Y0 K70]),
  ).map(((name, c, v)) => (box(width: 12mm, height: 6mm, fill: c), name, v)).flatten(),
)

= Fonts

#let sample = [Københavns Universitet — Æble, øl og ål. The quick brown fox jumps over the lazy dog. 0123456789]
#table(
  columns: (32mm, 1fr),
  stroke: none,
  inset: (x: 0pt, y: 5pt),
  [Body], text(font: ul.default-font, sample),
  [Body italic], text(font: ul.default-font, style: "italic", sample),
  [Headings], text(font: ul.default-heading-font, weight: "bold", sample),
)

#page(margin: (x: 20mm, top: 70mm), {
  place(top + left, dy: -70mm, dx: -20mm, ul.ucph-header(lang: "da", lines: ([Det Samfundsvidenskabelige Fakultet], [Økonomisk Institut])))
  heading[Publication header in Danish]
  [The header follows "Placement of logo on publications" in the official CMYK logo sheet. Logotype, seal, dots and rule keep their official proportions; faculty and department are set as text underneath.]
})
