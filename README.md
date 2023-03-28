# Personal homepage

Served at [my homepage](https://perso.crans.org/vanille),
thanks to the [Crans [fr]](https://www.crans.org/).

## Contents

```
data                         The main folder where everything happens
  |--- better-pbm-viewer     A Bitmap and Pixmap image generator/editor/viewer
  |--- pics                  Small photo gallery
  |--- share                 Various documents for school/research/configuration
  |--- treboor               Sources for the Tree Borrows in-depth explanation
```

## Dependencies

### Major

- [`pandoc`](https://pandoc.org/)
- [`python`](https://www.python.org/)

### Minor

`tar`, `rsync`, `fd`

### Administrative

- `remote`, a personal script (wrapper around `rsync` + `ssh`) to push to the server

## Structure

This web page is built by a recursive `make` system. Each `Makefile` defines
a module, with possible submodules, and the website is a hierarchy of all
the modules.

### Location

The website structure follows the directory structure:

- `data/**/foo/Makefile` defines the actions for `foo`
- `data/**/foo/` is online at `perso.crans.org/vanille/**/foo`

### Build

The build system uses the `.target` directory as a build directory:

- `data/**/foo/.target` is the build directory for `foo`
- `data/**/foo/bar/.target` is the build directory for the submodule `bar`
- `data/**/foo/bar/.target` is symlinked to `data/**/foo/.target/bar`,
effectively moving data to the root by permuting the `.target` folder

Finally `data/.target` is resolved to `www` which is then pushed to
the server.

