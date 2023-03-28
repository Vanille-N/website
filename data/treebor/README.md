# Tree Borrows

This module is online [here](https://perso.crans.org/vanille/treebor).
It describes the purpose and mechanism of the Tree Borrows aliasing semantics.

## Building

As shown in the Makefile, this page is built by `pandoc`.

```bash
# The code blocks use a modified Rust language definition that recognizes special
# comment markers such as `//-` `//+` `//?`. This allows clearer examples.
SYN = conf/rust.xml

# Gruvbox-themed coloring for both plaintext and code
CSS = conf/style.css
HLTHEME = conf/hl.theme

# Invocation: builds a single `html` file from a `md` file
pandoc \
    --syntax-definition $SYN \
    --highlight-style $HLTHEME \
    --embed-resources --standalone \
    -f markdown -t html \
    src/$FILENAME.md -o .target/$FILENAME.html \
    -H $CSS
```

## Complementary material

See sources in [src/refs.md](https://perso.crans.org/vanille/treebor/refs.html)
