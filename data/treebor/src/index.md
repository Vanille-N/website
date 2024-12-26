---
title: "Tree Borrows"
subtitle: A new aliasing model for Rust
author: Neven Villani
date: Mar. 2023
output: html_document
lang: en
---

> <span class="alert">
This document replaces the pre-2023-10-20 version that did not yet include the updates
from the [two latest PRs in Miri](https://github.com/rust-lang/miri)
For completeness you can still find the unedited version [here](https://perso.crans.org/vanille/treebor.0).
If you don't know Tree Borrows yet, you're in the right place.
If you are familiar with Tree Borrows and want to know only what changed and why,
you may consult [the diff](diff.0.html).
</span>

> <span class="info">
(Nov. 2024) Tree Borrows has been submitted for publication!
You may read a preprint [here](aux/preprint.pdf).
</span>

Tree Borrows is a proposed alternative to
[Stacked Borrows](https://www.ralfj.de/blog/2019/05/21/stacked-borrows-2.1.html)
that fulfills the same role: to analyse the execution of Rust code at runtime
and define the precise requirements of the aliasing constraints.
When these aliasing constraints are violated, the code is declared
Undefined Behavior (UB). This enables optimizations that would otherwise be
unsound in the presence of `unsafe`{.rust} code.

---

The current version of Tree Borrows is
[implemented](https://github.com/rust-lang/miri/tree/master/src/borrow_tracker/tree_borrows)
in the
[Miri](https://github.com/rust-lang/miri/)
interpreter.
Compared to [another description](https://github.com/Vanille-N/tree-borrows/blob/master/half/main.pdf),
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


See also some [References](refs.html).
Suggest modifications to this document by opening a
[pull request](https://github.com/Vanille-N/website/tree/master/data/treebor/src).

---
