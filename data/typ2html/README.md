# Typ2HTML

A showcase of Typst's [HTML output format](https://typst.app/docs/reference/html/)

## Website

The output of these files is served at [perso.crans.org/vanille/typ2html](https://perso.crans.org/vanille/typ2html/)

## Building

Minimal setup:
- Typst >= 0.13

Recommended setup:
- `just`
- `parallel`

The build command is `typst compile --features html --format html _src/index.typ index.html`.

The provided `justfile` allows automatically building everything on change with `just watch-all`.

## Files

The file structure is thus:
```
README.md                This file
justfile                 Build process
_src/                    Typst source code
    xhtml.typ              Specializes html.elem for convenience
    css.typ                Enables dynamically defined CSS to be inserted in the document
    struct.typ             Redefines functions such as text, box, align, table, ...
    excerpt.typ            Allows including pieces of source code in a page
    common.typ             Headers for index.html and meta.html
    footer.typ             Defines the footer of index.html and meta.html
    meta.typ               Renders the source code of all other files for browsing
    index.typ              Main file
_assets/                 Non-typst files used
    global.css             Global style definitions
    link.svg               Image asset used as demo
_highlight/              Handles code highlighting
    highlight.min.js       Entry point of highlight.js
    highlight-typst.js     Downloaded from https://www.npmjs.com/package/@myriaddreamin/highlighter-typst?activeTab=readme
    ...                    Other files downloaded from https://highlightjs.org/download
list:page                Typst files that should be compiled as roots
list:all                 Files whose source code should be included in meta.html
manage                   Implementation detail for my whole website, not relevant here
```
