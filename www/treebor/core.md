---
title: "Tree Borrows -- Basic Model"
subtitle: A new aliasing model for Rust
author: Neven Villani
date: Mar. 2023
output: html_document
lang: en
---

In this first part we establish the base model of Tree Borrows (TB), which for
now handles only code that has no function calls and no types with interior
mutability, since those are two aspects that are difficult to handle.
This introduction to the model is structured so that adding functions
and interior mutability will not _modify_ any parts of the model already
introduced, so the following explanations can be treated as the description
of a _partial_ model, rather than a _simplified_ one.

---

## Preliminaries

### Access-based borrow tracking

Tree Borrows is characterized by the fact that it executes at runtime and is
access-based, as opposed to compile-time and scope-based.
The code is executed, and the model tracks updates to the state of borrows after
each _access_. Code that is never executed cannot produce UB.

Tree Borrows is in this sense more fine-grained than the Borrow Checker,
which rejects some examples where it is very obvious that no aliasing _actually_
occurs thanks to runtime conditional guards.

#### Example 1: faulty code is unreachable at runtime
> ```diff
> + TB: NOT UB (aliasing code never executes)
> - Does not compile. error[E0499]: cannot borrow `*u` as mutable more than once at a time
> ```
> ```rust
> fn unreachable_faulty(u: &mut u8) {
>     if false {
>         let x = &mut *u;
>         let y = &mut *u;
>         *x += 1;
>         *y += 1;
>     }
> }
> ```

#### Example 2: aliasing never occurs thanks to conditional
> ```diff
> + TB: NOT UB (in all possible executions, if `u` and `v` are disjoint then `x` and `y` are disjoint)
> - Does not compile. error[E0499]: cannot borrow `*v` as mutable more than once at a time
> ```
> ```rust
> fn maybe_aliasing(u: &mut u8, v: &mut u8, b: bool) 
>     let x = if b { &mut *u } else { &mut *v }
>     let y = if b { &mut *v } else { &mut *u }
>     *x += 1
>     *y += 1
> }
> ```
<!-- ` -->

### Unsafe

Tree Borrows also differs from the Borrow Checker in that it does not handle
`unsafe`{.rust} code any differently from safe code. Sometimes we will show code
that does not actually compile because it is rejected by the Borrow Checker.
This is to make the notations less heavy, and should any code fail to compile
you should assume that the following transformations are to be applied:

- wrap the entire code snippet in `unsafe`{.rust},
- perform a round trip to and from raw pointers on each reborrow.

These are no-ops from the point of view of the Tree Borrows, but they trick
the Borrow Tracker into losing track of the compile-time aliasing conflicts.

#### Example: the two following functions are identical for Tree Borrows
> ```diff
> - TB: UB (`x` and `y` alias)
> - Does not compile. error[E0499]: cannot borrow `*u` as mutable more than once at a time.
> ```
> ```rust
> fn example_default(u: &mut u8) {
>     let x = &mut *u;
>     let y = &mut *u;
>     *x += 1;
>     *y += 1;
> }
> ```

> ```diff
> - TB: UB (`x` and `y` alias)
> + Compiles without errors.
> ```
> ```rust
> fn example_fixed(u: &mut u8) { unsafe {
>     let x = &mut *addr_of_mut!(*u);
>     let y = &mut *addr_of_mut!(*u);
>     *x += 1;
>     *y += 1;
> } }
> ```

using `std::ptr::addr_of_mut`{.rust}.
The same trick works with `let x = &mut *(u as *mut u8)`{.rust}.


## The core model

### Active and Disabled: tracking exclusive mutable access

The first step of tracking borrows should of course be ensuring that mutable
references have _exclusive_ mutable access to the ressource they borrow.

Since Tree Borrows updates its internal state on each memory access, we can
match the beginning and end of the lifetime of a mutable reference to specific
memory accesses. Performing a write operation asserts that the reference is
currently alive.

> ```rust
> macro_rules! phantom_write {
>     ($x:expr) => {{ *$x = *$x }} // a "write" that doesn't change the value
> }
> ```
> ```diff
> + TB: NOT UB (no aliasing)
> ```
> ```rust
> fn example(u: &mut u8) {
>     phantom_write!(u); // assert that `u` has started its lifetime
>
>     let x = &mut *u;
>     phantom_write!(x); // assert that `x` has started its lifetime
>     ...
>     *x = 42;
>     ...
>     phantom_write!(x); // assert that `x` is still alive
>
>     phantom_write!(u); // assert that `u` is still alive
> }
> ```
<!-- ` -->

Guaranteeing that mutable references have exclusive access means that the
lifetimes of mutable references must be disjoint. This is easy to check: when
the lifetime of a new mutable reference begins, the old ones must no longer
be active. Equivalently when an access occurs that activates a mutable reference,
we kill other mutable references.

> ```diff
> + TB: NOT UB (the mutable references properly have exclusive access for disjoint lifetimes)
> ```
> ```rust
> fn refmut_disjoint(u: &mut u8) {
>     phantom_write!(u);
>
>     let x = &mut *u;   // x is alive
>     phantom_write!(x); // from here...
>     *x = 42;           //
>     phantom_write!(x); // ...until here.
>
>     // ----- `x` and `y` lifetimes properly disjoint -----
>
>     let y = &mut *u;                     // y is alive
>     phantom_write!(y);                   // from here...
>     *y = 36;                             //
>     phantom_write!(y);                   // ...until here.
>
>     phantom_write!(u);
> }
> ```
<!-- ` -->

> ```diff
> - TB: UB (the lifetimes of mutable references intersect)
> ```
> ```rust
> fn refmut_intersecting(u: &mut u8) {
>     phantom_write!(u);
>
>     let x = &mut *u;   // x is alive
>     phantom_write!(x); // from here...
>                        //
>     let y = &mut *u;   //                // y is alive
>     phantom_write!(y); //                // from here...
>                        //                //
>     *x = 42;           //                //                 <-- oh no, they intersect !
>     phantom_write!(x); // ...until here. //
>                                          //
>     *y = 36;                             //
>     phantom_write!(y);                   // ...until here.
>
>     phantom_write!(u);
> }
> ```
<!-- ` -->

There is however a missing ingredient: what if `y` is a reborrow of `x` rather than
a separate borrow of `u` ? After all we are allowed to do a temporary reborrow as
long as we respect the nesting.

> ```diff
> + TB: NOT UB (properly nested reborrow)
> ```
> ```rust
> fn refmut_nested(u: &mut u8) {
>     phantom_write!(u);
>
>     let x = &mut *u;   // x is alive
>     phantom_write!(x); // from here...
>                        //                                         Yes they intersect, but
>     let y = &mut *x;   //           // y is alive                 1. `y` is borrowed from `x`, not `u`
>     phantom_write!(y); //           // from here...               2. their usage is properly nested
>     *y = 36;           //           //
>     phantom_write!(y); //           // ...until here.
>                        //
>     *x = 42;           //
>     phantom_write!(x); // ...until here.
>
>     phantom_write!(u);
> }
> ```
<!-- ` -->

> ```diff
> - TB: UB (improperly nested reborrow)
> ```
> ```rust
> fn refmut_nested(u: &mut u8) {
>     phantom_write!(u);
>
>     let x = &mut *u;   // x is alive
>     phantom_write!(x); // from here...
>                        //
>     let y = &mut *x;   //                // y is alive           Even though `y` is derived from `x`,
>     phantom_write!(y); //                // from here...         this code attempts to use them in a
>                        //                //                      non-nested manner.
>     *x = 42;           //                //
>     phantom_write!(x); // ...until here. //
>                                          //
>     *y = 36;                             //
>     phantom_write!(y);                   // ...until here.
>
>     phantom_write!(u);
> }
> ```
<!-- ` -->

### Implementation

We can summarize these observations as

- if two mutable references `x` and `y` are unrelated, then their periods of mutable activation
  must be disjoint,
- if `y` is descended from `x`, then the period of mutable activation of `y` must be properly
  nested inside that of `x`.

We can check these constraints with the following model:

- whenever `y` is reborrowed from `x`, record `y` as a child of `x`.
- we denote by `Active` a mutable reference during its period of mutability.
  We call this the _permission_ of `x`. It is allowed to write through an `Active` reference.
- we denote by `Disabled` a mutable reference that is no longer useable because its lifetime
  has ended. It is forbidden (UB) to write through a `Disabled` reference.

and the update rules

- **(this rule rejects improperly nested reborrows)**
  when a parent pointer performs a write, the permission goes from `Active` to `Disabled`,
- **(this rule allows properly nested reborrows)**
  when a child pointer performs a write, nothing happens to an `Active` permission,
- **(this rule rejects intersecting unrelated borrows)**
  when a non-parent and non-child pointer performs a write, the permission goes from
  `Active` to `Disabled`.

From these we can observe a separation between two kinds of pointers: child pointers,
and non-child pointers. We call _child access_ an access through a child pointer.
We call _foreign access_ an access through a non-child pointer. As we will see
the entire rules of Tree Borrows can be expressed in terms of

- which permissions allow child accesses (`Active` allows child writes, `Disabled` does not),
- how each permission should be updated in response to each kind of foreign access
(`Active` become `Disabled` upon a foreign write, `Disabled` is unchanged by foreign writes).

#### Example: how TB detects an improperly nested reborrow

> ```diff
> - TB: UB (improperly nested reborrow)
> ```
> ```rust
> fn refmut_nested(u: &mut u8) {
>     phantom_write!(u);
>                        // The borrows on function entry are
>                        // --- u: Active
>     let x = &mut *u;
>     phantom_write!(x);
>                        // Created a new reborrow `x` child of `u`
>                        // --- u: Active
>                        //     |--- x: Active
>                        // (`u` is unchanged by the child write through `x`)
>     let y = &mut *x;
>     phantom_write!(y);
>                        // Created a new reborrow `y` child of `x`
>                        // --- u: Active
>                        //     |--- x: Active
>                        //          |--- y: Active
>                        // (`u` is unchanged by the child write through `y`)
>                        // (`x` is unchanged by the child write through `y`)
>     *x = 42;
>     phantom_write!(x);
>                        // Write access
>                        // --- u: Active
>                        //     |--- x: Active
>                        //          |--- y: Disabled
>                        // (`u` is unchanged by the child write through `x`)
>                        // (`y` is disabled by the foreign write through `x`)
>     *y = 36;
>     phantom_write!(y);
>                        // Attempted write through a pointer that is `Disabled`.
>                        // This is UB.
>     phantom_write!(u);
> }
> ```
<!-- ` -->

#### Example: how TB detects intersecting lifetimes

> ```diff
> - TB: UB (the lifetimes of mutable references intersect)
> ```
> ```rust
> fn refmut_intersecting(u: &mut u8) {
>     phantom_write!(u);
>                        // The borrows on function entry are
>                        // --- u: Active
>
>     let x = &mut *u;
>     phantom_write!(x);
>                        // Created a new reborrow `x` child of `u`
>                        // --- u: Active
>                        //     |--- x: Active
>                        // (`u` is unchanged by the child write through `x`)
>
>     let y = &mut *u;
>     phantom_write!(y);
>                        // Created a new reborrow `y` child of `u`
>                        // --- u: Active
>                        //     |--- x: Disabled
>                        //     |--- y: Active
>                        // (`x` is unchanged by the child write through `y`)
>
>     *x = 42;
>     phantom_write!(x);
>                        // Attempted write through a pointer that is `Disabled`.
>                        // This is UB.
>
>     *y = 36;
>     phantom_write!(y);
>
>     phantom_write!(u);
> }
> ```
<!-- ` -->

---
