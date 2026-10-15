// Example thesis for ucph-lehmann-thesis. Compile from the repo root:
//   typst compile --root . examples/example-thesis.typ
//   typst compile --root . --input lang=da examples/example-thesis.typ examples/example-thesis-da.pdf
#import "../src/lib.typ": thesis, appendix, colors
#import "earth.typ": earth

#let lang = sys.inputs.at("lang", default: "en")
#let da = lang == "da"

#show: thesis.with(
  lang: lang,
  type: if da [Speciale] else [Master's thesis],
  title: if da [Om jordens indre kerne] else [On the Inner Core of the Earth],
  subtitle: if da [Et eksempel på en afhandling skrevet med ucph-lehmann-thesis] else [An example thesis typeset with ucph-lehmann-thesis],
  authors: ((name: "Inge Lehmann", id: "abc123"),),
  advisors: ("Prof. Niels Erik Nørlund",),
  date: datetime(year: 2026, month: 10, day: 15),
  faculty: if da [Det Natur- og Biovidenskabelige Fakultet] else [Faculty of Science],
  department: if da [Institut for Matematiske Fag] else [Department of Mathematical Sciences],
  description: if da [Et eksempel, der viser skabelonens funktioner.] else [An example that shows the features of the template.],
  cover-image: earth(size: 78mm),
  abstracts: (
    en: [
      This document is an example of the `ucph-lehmann-thesis` template for the University of Copenhagen. It shows the front page with the official logo, the information page generated from the thesis metadata, abstracts in two languages, the table of contents, and the conventions for chapters, figures, tables, equations, references and appendices. #lorem(60)
    ],
    da: [
      Dette dokument er et eksempel på skabelonen `ucph-lehmann-thesis` til Københavns Universitet. Det viser forsiden med det officielle logo, oplysningssiden, der dannes ud fra afhandlingens metadata, resuméer på to sprog, indholdsfortegnelsen og konventionerne for kapitler, figurer, tabeller, ligninger, referencer og appendiks.
    ],
  ),
  preface: [
    The template is named after Inge Lehmann (1888--1993), who graduated from the University of Copenhagen in 1920 and in 1936 showed that the Earth has a solid inner core. Her paper announcing the discovery carried what may be the shortest title in the history of geophysics: "P′" @lehmann1936. #lorem(40)
  ],
  character-count: true,
  list-of-figures: true,
  list-of-tables: true,
)

#show raw.where(block: true): set text(size: 8.5pt)
#show raw.where(block: true): block.with(fill: colors.ucph-medium.champagne, inset: 8pt, radius: 2pt, width: 100%)

= Introduction <intro>

A thesis is a long document, and most of its typography should be decided once and then forgotten. This template takes care of the University of Copenhagen front page, the page numbering, and the numbering of chapters, figures, tables and equations, so that the author can concentrate on the content.#footnote[Footnotes are counted towards the number of characters, as are headings and the body text.]

The front matter uses roman page numbers and the main text starts again at page 1. Figures and equations are numbered within chapters, as in @fig:earth and @eq:ols. References are written with `@key` and set in author--year style, e.g. #cite(<boserup1965>, form: "prose") or @schelling1971.

== Motivation

#lorem(120)

== Structure of the thesis

@methods describes the setup, @results presents the results and @conclusion concludes. Additional material is collected in @app:extra.

= Using the template <methods>

The whole template is configured in one show rule at the top of the document:

```typ
#import "@preview/ucph-lehmann-thesis:0.1.0": thesis, appendix

#show: thesis.with(
  lang: "en",                 // or "da"
  type: [Master's thesis],
  title: [On the Inner Core of the Earth],
  authors: ((name: "Inge Lehmann", id: "abc123"),),
  advisors: ("Prof. Niels Erik Nørlund",),
  date: datetime(year: 2026, month: 10, day: 15),
  faculty: [Faculty of Science],
  department: [Department of Mathematical Sciences],
  abstracts: (en: [...], da: [...]),
  character-count: true,
)
```

== Fonts

The body is set in Liberation Serif and the headings in Liberation Sans, which have the same metrics as Times New Roman and Arial. If they are not installed, the template falls back to Times New Roman/Arial and finally to Libertinus Serif, which is built into Typst.

== Characters and normal pages

At UCPH, a normal page is 2,400 characters including spaces. With `character-count: true`, the information page reports the number of characters in the main text, stopping at the appendix and leaving out figures, tables, equations and the reference list. Rules differ between programmes, so check yours.

#lorem(80)

= Results <results>

== A figure

#figure(
  earth(size: 60mm),
  caption: [A cross-section of the Earth with the inner core in red. Rays from an earthquake at the top bend as they pass through layers of different density.],
) <fig:earth>

#lorem(60)

== An equation

The ordinary least squares estimator is

$ hat(bold(beta)) = (bold(X)^top bold(X))^(-1) bold(X)^top bold(y), $ <eq:ols>

which is consistent under the usual assumptions @angrist2009. #lorem(40)

== A table

#figure(
  table(
    columns: (1fr, auto, auto, auto),
    align: (left, right, right, right),
    table.hline(stroke: 0.8pt),
    table.header([], [(1)], [(2)], [(3)]),
    table.hline(stroke: 0.5pt),
    [Treatment], [0.124], [0.118], [0.097],
    [], [(0.031)], [(0.030)], [(0.028)],
    [Controls], [No], [Yes], [Yes],
    [Fixed effects], [No], [No], [Yes],
    table.hline(stroke: 0.5pt),
    [Observations], [12,408], [12,408], [12,408],
    table.hline(stroke: 0.8pt),
  ),
  caption: [Illustrative regression estimates. Standard errors in parentheses.],
) <tab:main>

@tab:main shows how a regression table looks with the default settings. #lorem(50)

= Conclusion <conclusion>

#lorem(150)

#bibliography("refs.bib", style: "harvard-cite-them-right")

#show: appendix

= Additional material <app:extra>

Appendix chapters are lettered, and so are their figures, tables and equations:

$ y_i = alpha + x_i beta + epsilon_i $ <eq:app>

#figure(
  table(
    columns: 3,
    table.hline(stroke: 0.8pt),
    table.header([Layer], [Depth (km)], [State]),
    table.hline(stroke: 0.5pt),
    [Crust and mantle], [0--2,900], [Solid],
    [Outer core], [2,900--5,150], [Liquid],
    [Inner core], [5,150--6,370], [Solid],
    table.hline(stroke: 0.8pt),
  ),
  caption: [Approximate layers of the Earth.],
) <tab:layers>

@eq:app and @tab:layers are numbered within the appendix.
