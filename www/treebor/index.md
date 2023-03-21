---
title: "Tree Borrows"
subtitle: A new aliasing model for Rust
author: Neven Villani
date: Mar. 2023
output: html_document
lang: en
---

Tree Borrows is a proposed alternative to
[Stacked Borrows](https://www.ralfj.de/blog/2019/05/21/stacked-borrows-2.1.html)
that fulfills the same role: to analyse the execution of Rust code at runtime
(so actually MIR rather than Rust) and declare the precise requirements of the aliasing constraints.
When the aliasing assumptions are considered to have been violated, the code is declared UB.

---

The current version of Tree Borrows is implemented in the
[Miri](https://github.com/rust-lang/miri/tree/master/src/borrow_tracker/tree_borrows)
interpreter.
Compared to [the detailed description](https://github.com/Vanille-N/tree-borrows/blob/master/half/main.pdf),
this document is more example-oriented.

# Table of contents

- Part 1: [Core Model](core.html)
    (mutable references and accesses)
- Part 2: [Sharing Data](shared.html)
    (shared references)
- Part 3: [Introducing Protectors](protectors.html)
    (function calls and the `noalias` attribute)
- Part 4: [Dealing with Cells](interiormut.html)
    (interior mutability)
- Part 5: [Ranges](range.html)
    (`extern type` and pointer offsets)


# References

## Tree Borrows

- [This](https://perso.crans.org/vanille/treebor)
- [Description](https://github.com/Vanille-N/tree-borrows)
- [Implementation](https://github.com/rust-lang/miri/tree/master/src/borrow_tracker/tree_borrows)
- [[Name collision] A prior attempt](https://internals.rust-lang.org/t/improve-upon-stacked-borrows-by-introducing-a-tree/16576)
- [Early thoughts about `Reserved`](https://rust-lang.zulipchat.com/#narrow/stream/136281-t-lang.2Fwg-unsafe-code-guidelines/topic/can.20.26mut.20just.20always.20be.20two-phase)

## Stacked Borrows

- [Paper](https://plv.mpi-sws.org/rustbelt/stacked-borrows/)
- [Reference](https://github.com/rust-lang/unsafe-code-guidelines/blob/master/wip/stacked-borrows.md)
- [Design steps](https://www.ralfj.de/blog/2019/05/21/stacked-borrows-2.1.html)
- [Implementation](https://github.com/rust-lang/miri/tree/master/src/borrow_tracker/stacked_borrows)

## Concerns and possible issues

### Detected by Stacked Borrows

- [List](https://github.com/rust-lang/unsafe-code-guidelines/blob/master/wip/stacked-borrows.md#adjustments-to-libstd)

### Detected by Tree Borrows

- [In the standard library test suite](https://github.com/rust-lang/rust/pull/107954)

### Raised about Stacked Borrows

- [Asserting uniqueness too early](https://github.com/rust-lang/unsafe-code-guidelines/issues/133)
    (Solved in TB by [`Reserved`](shared.html))
- [Reborrow range is too restrictive](https://github.com/rust-lang/unsafe-code-guidelines/issues/134)
    (Solved in TB by [delayed initialization](range.html))
- [Handling of `extern type`](https://github.com/rust-lang/unsafe-code-guidelines/issues/276)
    (Solved in TB by [delayed initialization](range.html))
- [Raw pointers inheriting permissions](https://github.com/rust-lang/unsafe-code-guidelines/issues/227)
    (Solved in TB by [raw pointers sharing tags](shared.html))

---
