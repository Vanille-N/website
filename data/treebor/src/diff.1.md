---
title: "Tree Borrows -- Diff for 2023-07-04"
subtitle: A new aliasing model for Rust
author: Neven Villani
date: De.c 2024
output: html_document
lang: en
---

\[ ------------ | [Up](index.html) | ------------ \]

In the process of trying to formalize the rules of Tree Borrows to prove that they do indeed provide the optimizations
we claim, we discovered some issues and attempted to fix them.

This document is an explanation of what issues we found, and how we solved them.

If you are already familiar with the old Tree Borrows model and want
to have a quick update on what changed since the last time Tree Borrows was fully explained, you're in the right
place. If you are new to Tree Borrows you should consider reading directly the
[updated model](https://perso.crans.org/vanille/treebor) so that you don't waste time learning about things that
were later changed.

---

# The problem

The issue is outlined in this [pull request](https://github.com/rust-lang/miri/pull/3732).
In short, when we added implicit reads on function exit for protected locations
(see [explanation](https://perso.crans.org/vanille/treebor/diff.0.html)),
we were not thorough enough and failed to notice that this does not enable
reordering writes as we intended.

It is known that Tree Borrows does not permit spurious writes, but it should allow
reordering writes to already-activated locations in function calls!

# Our solution

This is an easy fix because we already have all the ingredients in the model.
We simply switch the implicit read on function exit to be an implicit write
for protected `Active` locations.

See for example the newly added test, written by J. Hostert, that explains why this is necessary:
```rs
fn the_other_function(ref_to_fst_elem: &mut i32, ptr_to_vec: *mut i32) -> *mut i32 {
    // Activate the reference. Afterwards, we should be able to reorder arbitrary writes.
    *ref_to_fst_elem = 0;
    // Here is such an arbitrary write.
    // It could be moved down after the retag, in which case the `funky_ref` would be invalidated.
    // We need to ensure that the `funky_ptr` is unusable even if the write to `ref_to_fst_elem`
    // happens before the retag.
    *ref_to_fst_elem = 42;
    // this creates a reference that is Reserved Lazy on the first element (offset 0).
    // It does so by doing a proper retag on the second element (offset 1), which is fine
    // since nothing else happens at that offset, but the lazy init mechanism means it's
    // also reserved at offset 0, but not initialized.
    let funky_ptr_lazy_on_fst_elem =
        unsafe { (&mut *(ptr_to_vec.wrapping_add(1))) as *mut i32 }.wrapping_sub(1);
    // If we write to `ref_to_fst_elem` here, then any further access to `funky_ptr_lazy_on_fst_elem` would
    // definitely be UB. Since the compiler ought to be able to reorder the write of `42` above down to
    // here, that means we want this program to also be UB.
    return funky_ptr_lazy_on_fst_elem;
}

fn main() {
    let mut v = vec![0, 1];
    // get a pointer to the root of the allocation
    // note that it's not important it's the actual root, what matters is that it's a parent
    // of both references that will be created
    let ptr_to_vec = v.as_mut_ptr();
    let ref_to_fst_elem = unsafe { &mut *ptr_to_vec };
    let funky_ptr_lazy_on_fst_elem = the_other_function(ref_to_fst_elem, ptr_to_vec);
    // now we try to use the funky lazy pointer.
    // It should be UB, since the write-on-protector-end should disable it.
    unsafe { println!("Value of funky: {}", *funky_ptr_lazy_on_fst_elem) }
    //^~ ERROR: /reborrow through .* is forbidden/
}
```


\[ ------------ | [Up](index.html) | ------------ \]

---

