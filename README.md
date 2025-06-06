# Personal homepage

Served at [my homepage](https://perso.crans.org/vanille),
thanks to the [Crans [fr]](https://www.crans.org/).

## Navigation

### If you are here for **Tree Borrows**:

The root folder is
[`data/treebor/`](data/treebor),
with the source code (Markdown)
stored in [`src/`](data/treebor/src).

To build:
- `make core.html` for one specific file,
- `make all` for the entire project.


### If you are here for **Typ2HTML**:

The root folder is
[`data/typ2html/`](data/typ2html),
with the source code (Typst)
stored in [`_src/`](data/typ2html/_src).

To build:
- `just compile index` for one specific file,
- `just compile-all` for the entire project,
- `just watch-all` to dynamically rebuild-on-change.

### Other

- The source code (Typst) of the homepage is in
  [`data/_src`](data/_src)
- Some public documents (e.g. preprints) are stored in
  [`data/share/`](data/share)

## Dependencies

### For **Tree Borrows**

- `pandoc`
- `make`

### For **Typ2HTML**

- `typst` (>= 0.13.0)
- `just`

### For the whole website

- `bash`
- `rsync`
- `tar`


## Licensing

This repository contains a variety of components, and the licensing of each is
detailed below.

### Original content

This includes --unless explicitly stated otherwise--
the content of all `.typ`, `.md`, `.css`,
`.html` files (both written directly and compiled from Typst/Markdown),
as well as Makefiles, justfiles, Readmes.
By making a Pull Request to this project you agree to have your own changes
be licensed under the same conditions.

- All source code written for this project is licensed under
  [MIT](https://opensource.org/license/mit).
- All resulting textual content is under
  [Creative Commons Attribution 4.0 CC-BY]().


### Shared documents

This applies to documents whose creation I was involved in
and for which I (at least partially) own the rights,
but that were not made specifically with the intent
of being added to this website.

- The preprints and documents in
  [`data/share`](data/share) are *in general* licensed under
  [Creative Commons Attribution 4.0 CC-BY](),
  but exceptions may be explicitly stated.


### Redistributed content

This includes the assets, images, fonts, libraries, etc that are used in this
project but not produced by me.

- A version of [`highlight.js`]() is redistributed as source code in
  [`data/typ2html/_highlight`](data/typ2html/_highlight).
  The original [BSD 3-Clause License](https://opensource.org/license/bsd-3-clause)
  is preserved as is required.
- [`highlighter-rust`]() is bundled into
  [`data/typ2html/_highlight/highlight-typst.js`](data/typ2html/_highlight/highlight-typst.js)
  and should remain under the [Apache-2.0]() license.
- The sitelen pona font
  [sitelen seli kiwen](https://github.com/kreativekorp/sitelen-seli-kiwen?tab=OFL-1.1-1-ov-file#readme)
  is used in this project and included in this repository as part of the rendering
  process.
  You can find it for example in
  [`data/_assets/sitelen-seli-kiwen.ttf`](data/_assets/sitelen-seli-kiwen.ttf).
  It retains its original [OFL-1.1]() license.
- Several subdirectories (e.g. `data/_img/`)
  store SVG and PNG images of various logos or icons to include on the website.
  These were all sourced either from the original project,
  from [svgrepo.com](https://www.svgrepo.com/), or sometimes from Wikipedia.
  In particular see the following non-exhaustive list:
  - [Typst Brand Guidelines](https://typst.app/legal/brand/),
  - [Rust Trademark Policy](https://rustfoundation.org/policy/rust-trademark-policy/),
  - [arXiv Name and Logo Use](https://info.arxiv.org/brand/brand-guidelines.html),
  - [GitHub Logos and Usage](https://github.com/logos).

