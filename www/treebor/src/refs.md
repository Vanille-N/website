---
title: "Tree Borrows -- References"
subtitle: A new aliasing model for Rust
author: Neven Villani
date: Mar. 2023
output: html_document
lang: en
---

## Tree Borrows

- [This](https://perso.crans.org/vanille/treebor)
- [Description](https://github.com/Vanille-N/tree-borrows)
- [Implementation](https://github.com/rust-lang/miri/tree/master/src/borrow_tracker/tree_borrows)
- [Early thoughts about `Reserved`](https://rust-lang.zulipchat.com/#narrow/stream/136281-t-lang.2Fwg-unsafe-code-guidelines/topic/can.20.26mut.20just.20always.20be.20two-phase)

Note: although [this project](https://internals.rust-lang.org/t/improve-upon-stacked-borrows-by-introducing-a-tree/16576)
shares the same name, it is otherwise completely unrelated.

## Stacked Borrows

- [Paper](https://plv.mpi-sws.org/rustbelt/stacked-borrows/)
- [Reference](https://github.com/rust-lang/unsafe-code-guidelines/blob/master/wip/stacked-borrows.md)
- [Design steps](https://www.ralfj.de/blog/2019/05/21/stacked-borrows-2.1.html)
- [Implementation](https://github.com/rust-lang/miri/tree/master/src/borrow_tracker/stacked_borrows)

## UB according to Tree Borrows in existing code

- [[Resolved] In the standard library test suite](https://github.com/rust-lang/rust/pull/107954)

---
