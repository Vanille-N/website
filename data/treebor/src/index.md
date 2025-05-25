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
and define the precise requirements of the aliasing constraints.
When these aliasing constraints are violated, the code is declared
Undefined Behavior (UB). This enables optimizations that would otherwise be
unsound in the presence of `unsafe`{.rust} code.

> <span class="sbnote">
**[Note: Stacked Borrows]**
When the document makes a comparison between Stacked Borrows and Tree Borrows,
it will be formatted like this. If you know nothing about Stacked Borrows,
skipping these explanations should not impede your understanding.
</span>

---

> <span class="alert">
(Oct. 2023) During the ongoing project of formalizing Tree Borrows,
we have discovered insufficiencies regarding spurious reads under concurrency.
This leads to the introduction of the `conflicted` flag and implicit reads on function exit
for protected locations. <br>
If you're new to Tree Borrows you can continue reading as normal.
If you know the basics of Tree Borrows and want to know specifically what changed,
you can consult [the diff](diff.0.html).
</span>

> <span class="alert">
(Jul. 2024) As formalization progresses, Johannes Hostert (who joined the project)
found other bugs, also related to `Reserved` and spurious reads.
These are fixed by making `Active` protected locations get an implicit write
(instead of read) on function exit. <br>
If you're new to Tree Borrows you can continue reading as normal.
If you know the basics of Tree Borrows and want to know specifically what changed,
you can consult [the diff](diff.1.html).
</span>


> <span class="info">
(Nov. 2024) Tree Borrows has been submitted for publication!
You may read a preprint [here](aux/preprint.pdf). <br>

(May 2024) Tree Borrows has been accepted for publication at PLDI'25 <br>
I will be giving the talk next June in [Seoul](https://pldi25.sigplan.org/details/pldi-2025-papers/42/Tree-Borrows) <br>

An alternative mirror for the preprint can be found on
[J. Hostert's website](https://jhostert.de/news/ann_03_tree_borrows_submitted/),
who joined the project to work on several aspects,
from proving some of Tree Borrows' claims in Coq
and fixing bugs in the core model, to improving performance in Miri. <br>
In related news, the formalization of Tree Borrows in Coq is complete,
significantly increasing our confidence in the claims we have made.
</span>

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
