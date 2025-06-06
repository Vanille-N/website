# Personal homepage

Served at [my homepage](https://perso.crans.org/vanille),
thanks to the [Crans [fr]](https://www.crans.org/).

## Navigation

### If you are here for **Tree Borrows**:

The root folder is [data/treebor/](https://github.com/Vanille-N/website/tree/master/data/treebor),
with the source code (Markdown)
stored in [src/](https://github.com/Vanille-N/website/tree/master/data/treebor/src).

To build:
- `make core.html` for one specific file,
- `make all` for the entire project.


### If you are here for **Typ2HTML**:

The root folder is [data/typ2html/](https://github.com/Vanille-N/website/tree/master/data/typ2html),
with the source code (Typst)
stored in [_src/](https://github.com/Vanille-N/website/tree/master/data/typ2html/_src).

To build:
- `just compile index` for one specific file,
- `just compile-all` for the entire project,
- `just watch-all` to dynamically rebuild-on-change.

### Other

- The source code (Typst) of the homepage is in
  [data/_src](https://github.com/Vanille-N/website/tree/master/data/_src)
- Some public documents (e.g. preprints) are stored in
  [data/share/](https://github.com/Vanille-N/website/tree/master/data/share)

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

