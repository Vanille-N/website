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

The current version of Tree Borrows is
[implemented](https://github.com/rust-lang/miri/tree/master/src/borrow_tracker/tree_borrows)
in the
[Miri](https://github.com/rust-lang/miri/)
interpreter.
Compared to [the detailed description](https://github.com/Vanille-N/tree-borrows/blob/master/half/main.pdf),
this document is more example-oriented.

> <span class="implnote"> **[Note: Implementation]**
These blocks contain insights about the implementation.
They are not necessary for understanding the model.
</span>

> <span class="sbnote"> **[Note: Stacked Borrows]**
These are comparisons between Stacked Borrows and Tree Borrows.
If the reader is not familiar with Stacked Borrows they are secondary.
</span>

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


See also some [References](refs.html)

---
