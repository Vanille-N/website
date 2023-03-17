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

We can use the following code to assert that a reference is currently readable:

> ```rust
> macro_rules! phantom_read {
>     ($x:expr) => {{ let _v = *x }}
> }
> ```
<!-- ` -->

In addition, since we want shared and mutable references to be marked
[dereferenceable](https://llvm.org/docs/LangRef.html) in LLVM, we count reborrow
as reads. This guarantees that it is impossible to reborrow from a `Disabled` pointer,
and thus that `dereferenceable` is valid.

> ```diff
> - TB: UB (reborrow from `Disabled`)
> - This code violates LLVM assumptions, it MUST BE UB.
> ```
> ```rust
> fn reborrow_disabled(u: &mut u8) {
>     let x = &mut *u;
>     phantom_write!(x);
> 
>     let y = &mut *u;
>     phantom_write!(y);
>                         // --- u: Active
>                         //     |--- x: Disabled
>                         //     |--- y: Active
>     let _v = *x;
>                         // This is an attempted reborrow from `x: Disabled`.
>                         // It counts as an attempted read, and `Disabled` forbids
>                         // reads.
>                         // This is UB.
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
> + This is safe code that compiles, it MUST NOT BE UB.
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

Symetrically to how mutable references are downgraded to shared references once they
lose exclusive access (a foreign read occurs) and as long as there is not yet another pointer that
has claimed exclusive access (no foreign write), we can look into whether we should allow
mutable references to behave like shared references _before_ they claim mutable access.

The reasoning is that as long as a mutable reference has not been written to, only read from,
it doesn't yet invalidate the existing shared references.
We give this permission the name `Reserved`, with the rules

- `Reserved` becomes `Active` on the first child write,
- `Reserved` otherwise behaves exactly like a `Frozen`: it allows child reads,
  is unaffected by foreign reads, and becomes `Disabled` on a foreign write.

and this gives us the complete lifetime of a mutable reference:

> ```diff
> + TB: NOT UB ("normal" life cycle of a mutable reference)
> ```
> ```rust
> fn life_of_mut(u: &mut u8) {
>     phantom_write!(u);
> 
>                             // Before this point, `x` does not exist.
>     let x = &mut *u;
>                             // Upon creation:
>     phantom_read!(x);       //   From here...
>     phantom_read!(u);       //
>                             //                 `x` does not have mutable access _yet_.
>     let _v = *x;            //   (Reserved)    For now it is readable and other references can also read,
>     let _v = *u;            //                 until at some point `x` will claim its exclusive mutable
>                             //                 access by performing a write access.
>                             //
>     phantom_read!(x);       //   ...until here.
>     phantom_read!(u);
> 
>                             // On the first child write:
>     phantom_write!(x);      //   From here...
>                             //
>                             //                 `x` has exclusive mutable access.
>      *x = 42;               //   (Active)      It has permission to read and write without interference.
>                             //                 Mutable reborrows are allowed if they are well-nested.
>                             //
>     phantom_write!(x);      //   ...until here.
> 
>                             // On the first foreign read:
>     phantom_read!(u);       //   From here...
>     phantom_read!(x);       //
>                             //
>     let _v = *u;            //                 `x` still has access, but no longer mutably.
>     let _v = *x;            //   (Frozen)      It can perform read-only accesses and coexist with
>                             //                 other such read-only accesses through any other reference.
>                             //                 Child writes are UB.
>                             //
>     phantom_read!(x);       //   ...until here.
>     phantom_read!(u);
> 
>                             // On the first foreign write:
>     phantom_write!(u);      //   From here...
>                             //
>                             //                 After this point, `x` is no longer useable, because
>      *u = 36;               //   (Disabled)    `u` has taken back its exclusive access.
>                             //                 Child reads and writes are UB.
>                             //
>                             //   .. until the end
>     phantom_write!(u);
> }
> ```
<!-- ` -->

It turns out that this `Reserved` permission makes a lot of code allowed, including
some very common patterns of `unsafe` code, and even some safe code that we would have
needed to allow anyway and would have been much more difficult to handle were it not
for `Reserved`.

#### Example: stdlib test that passes thanks to `Reserved`

> ```diff
> + TB: NOT UB (still `Reserved` at the time of `assert`)
> + This is (almost) stdlib code, it would be PREFERABLY NOT UB.
> ```
> ```rust
> fn mut_raw_then_mut_shr() {
>     let mut x = 2;
>     let xref = &mut x;
>     let xmut = &mut *xref;
>     let xshr = &*xref;
>     assert_eq!(*xshr, 2); // At this point, `xmut: Reserved`. It allows the foreign read through `xshr: Frozen`.
>     *xmut = 4;            // Now `xmut` becomes `Active`.
>     assert_eq!(x, 4);     // And then a parent read through `x: Active` makes `xmut: Frozen`
> }
> ```
<!-- ` -->

Safe code that is accepted by TB thanks to `Reserved` includes code that makes use of
[two-phase borrows](https://rustc-dev-guide.rust-lang.org/borrow_check/two_phase_borrows.html).

#### Example: easy two-phase borrow with `Reserved`

> ```diff
> + TB: NOT UB (standard two-phase borrow example)
> + This is safe code that compiles, it MUST NOT BE UB.
> ```
> ```rust
> fn push_len(v: &mut Vec<usize>) {
>     v.push(v.len());
> }
> ```
<!-- ` -->

The above code desugars to approximately

> ```diff
> + TB: NOT UB (standard two-phase borrow example -- desugared)
> + This is (unsafe) desugaring of safe code, it would be PREFERABLY NOT UB.
> ```
> ```rust
> fn push_len_desugared(v: &mut Vec<usize>) {
>     let temp_vmut = &mut v;
>     // --- Two-phase borrow begins ---
>     let temp_vshr = &v;
>                                          // At this point we have
>                                          // --- v: Reserved
>                                          //     |--- temp_vmut: Reserved
>                                          //     |--- temp_vshr: Frozen
>     let temp_len = Vec::len(temp_vshr);
>                                          // This is a foreign read for `temp_vmut: Reserved` which
>                                          // is unaffected. No write has occured since the beginning of
>                                          // the two-phase borrow.
>     // --- Two-phase borrow becomes a true active mutable borrow. ---
>     Vec::push(temp_vmut, temp_len);
>                                          // Now a child write through `temp_vmut` finally occurs
>                                          // --- v: Active
>                                          //     |--- temp_vmut: Active
>                                          //     |--- temp_vshr: Disabled
> }
> ```
<!-- ` -->


---

