---
title: "Tree Borrows -- Sharing Data"
subtitle: A new aliasing model for Rust
author: Neven Villani
date: Mar. 2023
output: html_document
lang: en
---

\[ [Prev](core.html) | [Up](index.html) | [Next](protectors.html) \]

Previously we introduced the core of the Tree Borrows model which tracks the
permissions of mutable references between `Active` and `Disabled` to guarantee
that no two references hold mutable access to the same piece of memory at the same
time.

We now introduce the transitory permissions `Frozen` and `Reserved` which let
us extend the model with shared references and delayed activation respectively.

> ```rust
> macro_rules! phantom_read {
>     ($x:expr) => {{ let _v = *x }}
> }
> ```
<!-- ` -->

## References can live together when `Frozen`

What does it take for shared references to live together with mutable references ?
Shared references can live several at the same time, and as long as the data is
not accessed mutably.

We introduce the `Frozen` permission to represent shared references: several
`Frozen` can exist together and they are unaffected by foreign reads, i.e.
shared references live for as long as only read accesses are performed.
Like `Active`, `Frozen` becomes `Disabled` upon encountering a foreign write:
if the data is being mutated then the shared references must be killed.
Unlike `Active` however, `Frozen` disallows child writes since one cannot use
a shared reference to mutate data.

One can assert that a shared reference is alive by attempting to read through it:

> ```diff
> + TB: NOT UB (no aliasing)
> ```
> ```rust
> fn example(u: &mut u8) {
>     phantom_write!(u);
>     ...
>     let x = &*u;      // `x` is alive at least
>     phantom_read!(x); // from here...
>                       //
>     let _v = *x;      //
>                       //
>     phantom_read!(x); // ...until here.
>     ...
>     phantom_write!(u);
> }
> ```

#### Example: write access kills shared references

> ```diff
> - TB: UB (shared reference is killed by write)
> ```
> ```rust
> fn share_until_write(u: &mut u8) {
>     phantom_write!(u);
> 
>     let x = &*u;
>     phantom_read!(x);
>     let y = &*x;
>     phantom_read!(y);
>     let z = &*y;
>     phantom_read!(z);
>                         // As many `Frozen` as needed can coexist.
>                         // They can be only read, but the order does not matter.
>                         // --- u: Active
>     let _v = *y;        //     |--- x: Frozen
>     let _v = *x;        //     |    |--- y: Frozen
>     let _v = *z;        //     |--- z: Frozen
>                         // (`Frozen` is unaffected by child and foreign reads)
>                         // (`Active` is unaffected by child reads)
> 
>     phantom_read!(z);
>     phantom_read!(y);
>     phantom_read!(x);
>     let w = &mut *u;
>     phantom_write!(w);
>                        // All shared borrows are killed on a write access
>                        // --- u: Active
>                        //     |--- x: Disabled
>                        //     |    |--- y: Disabled
>                        //     |--- z: Disabled
>                        //     |--- w: Active
> 
>     let _v = *x;
>                       // Attempted read through a `Disabled` pointer
>                       // This is UB.
> 
>     phantom_write!(w);
>     phantom_write!(u);
> }
> ```
<!-- ` -->

In summary

- `Frozen` allows child reads and forbids (UB) child writes,
- `Frozen` is unaffected by foreign reads,
- `Frozen` becomes `Disabled` on a foreign write.


## Don't `Disable` immediately, keep `Frozen` instead

Until now we have dodged the question of what to do when an `Active` encounters
a read. Since mutable references also permit read-only access it should be obvious
that child reads are allowed, but what happens on a foreign read ?

The Borrow Tracker suggests that the mutable reference should be killed completely,
but we argue that it should merely become `Frozen`. In other words a mutable
reference is downgraded to a shared reference when other shared references start
accessing the data.

> ```diff
> + TB: NOT UB (mutable reference is still accessible as read-only)
> - Does not compile. error[E0502]: cannot borrow `*u` as immutable because it is also borrowed as mutable.
> ```
> ```rust
> fn shared_from_mut(u: &mut u8) {
>     phantom_write!(u);
> 
>     let x = &mut *u;
>     phantom_write!(x);
>                         // First mutable borrow
>                         // --- u: Active
>                         //     |--- x: Active
>                         // (`u: Active` is unafected by the child write)
>     *x = 42;
>     phantom_write!(x);  // The mutable lifetime of `x` ends here, but it will still be available read-only
> 
>     let y = &*u;
>     phantom_read!(y);
>     phantom_read!(x);
>                         // Second borrow is immutable
>                         // --- u: Active
>                         //     |--- x: Frozen
>                         //     |--- y: Frozen
>                         // (`u: Active` is unaffected by the child read)
>                         // (`x: Active` is made `Frozen` by the foreign read)
> 
>     let _v = *x;        // `x` has been downgraded to a shared reference,
>                         // this read access _is_ allowed by TB (not by the compiler though),
>                         // and is a no-op in terms of permissions.
> 
>     phantom_read!(y);
>     phantom_read!(x);   // `x` is still alive in read-only mode until here
>     phantom_write!(u);
> }
> ```
<!-- ` -->

So why do we allow this ? The main reason is that we want the compiler to always
be able to reorder read-only accesses, and doing so must absolutely not introduce
new UB !

> ```diff
> + TB: NOT UB (properly nested)
> + Compiles without errors.
> ```
> ```rs
> fn swappable_reads(u: &mut u8) {
>     phantom_write!(u);
> 
>     let x = &mut *u;
>     phantom_write!(x);
>     ...
>     phantom_write!(x);
> 
>                       // Currently
>                       // --- u: Active
>                       //     |--- x: Active
>                       //
>                       // What happens if we reorder these two reads ?
>     let _v = *x;      //  <--- (1)
>     let _v = *u;      //  <--- (2)
>                       //
>                       // Answer: `x: Active` would be subjected to (2) a foreign read.
>                       // If this made `x` become `Disabled`, then the following (1) child write would be UB.
>                       // For reads to always be possible to reorder, it must hold that a read through a
>                       // pointer never makes another pointer `Disabled`. Since the other pointer must not stay
>                       // `Active`, `Frozen` is the solution.
> 
>     phantom_read!(x);
>     phantom_write!(u);
> }
> ```
<!-- ` -->

This shows us that we must have

- `Active` allows child reads,
- `Active` becomes `Frozen` on a foreign read.


## `Reserve` until needed


---
