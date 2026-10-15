root := justfile_directory()

export TYPST_ROOT := root

[private]
default:
  @just --list --unsorted

# extract the logo variants from the official sheets in tools/sources/
logos:
  python3 tools/extract-logos.py

# compile the examples and the template
examples: install-preview
  typst compile --root . examples/example-thesis.typ
  typst compile --root . --input lang=da examples/example-thesis.typ examples/example-thesis-da.pdf
  typst compile --root . examples/asset-gallery.typ
  typst compile template/main.typ template/main.pdf

# regenerate the template thumbnail
thumbnail: install-preview
  typst compile template/main.typ assets/thumbnail.png --pages 1 --ppi 150

# package the library into the specified destination folder
package target:
  ./scripts/package "{{target}}"

# install the library with the "@local" prefix
install: (package "@local")

# install the library with the "@preview" prefix (for pre-release testing)
install-preview: (package "@preview")

[private]
remove target:
  ./scripts/uninstall "{{target}}"

# uninstalls the library from the "@local" prefix
uninstall: (remove "@local")

# uninstalls the library from the "@preview" prefix (for pre-release testing)
uninstall-preview: (remove "@preview")
