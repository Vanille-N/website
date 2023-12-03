---
title: "Tree Borrows"
subtitle: A new aliasing model for Rust
author: Neven Villani
date: Mar. 2023
output: html_document
lang: en
---

> <span class="alert">
This document has been updated on 2023-10-20 in favor of the [newer version](https://perso.crans.org/vanille/treebor)
that includes the [two recent PRs to Miri](https://github.com/rust-lang/miri/pull/3067).
You may still read here the original version, but a better idea would be to consult
[the updated writeup](https://perso.crans.org/vanille/treebor) if you don't know Tree Borrows yet,
and [the exact diff between the two versions](https://perso.crans.org/vanille/treebor/diff.0.html) if you are
familiar with Tree Borrows and want to know only what changed and why.
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
