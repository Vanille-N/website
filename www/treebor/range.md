---
title: "Tree Borrows -- Range"
subtitle: A new aliasing model for Rust
author: Neven Villani
date: Mar. 2023
output: html_document
lang: en
---

\[ [Prev](interiormut.html) | [Up](index.html) | ----------- \]

The model is complete for one-byte allocations, but we have not yet tackled
allocations that contain several locations. The main difficulties that arise
are reported to be

- [Issue #276: handling `extern type`](https://github.com/rust-lang/unsafe-code-guidelines/issues/276)
- [Issue #134: range of raw pointers is too strict](https://github.com/rust-lang/unsafe-code-guidelines/issues/134)

These boil down to an issue of knowing on what range a pointer can be used.
Reborrowing immediately for the entire allocation is much too strict, since
we need the following code to be accepted:

> ```diff
> + TB: NOT UB (Disjoint mutable references)
> + This is safe code that compiles, it MUST NOT BE UB.
> ```
> ```rust
> fn inc_both(u: &mut u8, v: &mut u8) {
>     *u += 1;
>     *v += 1;
> }
> 
> fn main() {
>     let mut t = (0, 0);
>     // `t.0` and `t.1` belong to the same allocation, but it is allowed
>     // to take a mutable reference to each. Thus reborrowing `t.0` MUST NOT
>     // reborrow all of `t`.
>     inc_both(&mut t.0, &mut t.1);
> }
> ```
<!-- ` -->

But on the other hand we would also like to be able to, among other things

- use a `*mut T` to access an entire array of `T`;
- access locations with the `add` method on pointers, which could offset the pointer
  beyond the range it was reborrowed on;
- have some guarantees for `extern type`s, the size of which is unknown.

So Tree Borrows must have some tolerance with regards to using a pointer
outside of the range it was reborrowed for.
Tree Borrows' solution is to not reborrow for the locations outside the range,
but to maintain enough information so that whenever the location is accessed
through a pointer for which it is out of range it can be initialized with a delay
and receive the permissions it would have had if it had been reborrowed from the start.
If such a location becomes `Disabled` it will not trigger a possible protector because
it has never been accessed through a child pointer. We write these
`Reserved?`, `Frozen?` and `Disabled?`. `Active?` is impossible because it requires
a child access to exist. `Frozen?` reacts the same way as `Frozen` for foreign
accesses, and it becomes `Frozen` on a child access.

> ```diff
> + TB: NOT UB (Delayed initialization)
> + Common pattern, it would be PREFERABLY NOT UB.
> ```
> ```rust
> let val = [1u8, 2];
>                                      // --- val: Active|Active
> let ptr = &val[0] as *const u8;
>                                      // --- val: Active|Active
>                                      //     |--- ptr: Frozen|Frozen?
> let _val = unsafe { *ptr.add(1) };
>                                      // --- val: Active|Active
>                                      //     |--- ptr: Frozen|Frozen
> ```
<!-- ` -->

> ```diff
> + TB: NOT UB (Disjoint mutable references)
> + This is safe code that compiles, it MUST NOT BE UB.
> ```
> ```rust
> fn inc_both(u: &mut u8, v: &mut u8) {
>               // ---t: Active|Active
>               //    |--- u: Reserved|Reserved? [protected]
>               //    |--- v: Reserved?|Reserved [protected]
>     *u += 1;
>               // ---t: Active|Active
>               //    |--- u: Active|Reserved? [protected]
>               //    |--- v: Disabled?|Reserved [protected]
>     *v += 1;
>               // ---t: Active|Active
>               //    |--- u: Active|Disabled? [protected]
>               //    |--- v: Disabled?|Active [protected]
> }
>
> fn main() {
>     let mut t = (0, 0);
>     inc_both(&mut t.0, &mut t.1);
> }
> ```
<!-- ` -->


---

\[ [Prev](interiormut.html) | [Up](index.html) | ----------- \]

---
