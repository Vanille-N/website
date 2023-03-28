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

## Implicit accesses on reborrows

Being able to assume that a newly created reference is readable is desireable,
since it allows the insertion of read accesses in optimizations such as the following
one
```rust
//? Unoptimized
let x = &*u;
let mut sum = 0;
while condition() {
    sum += *x;
}

//? Optimized
let x = &*u;
let mut sum = 0;
let xval = *x; // Assuming that `x` is unconditionally dereferenceable
while condition() { // Assuming also that `condition()` does not modify `*x`
    sum += xval; // We can remove dereferencing operations
}
```
This optimization is incorrect if we only rely on `condition()` to
protect against `x` being dangling. Indeed in the unoptimized version it
suffices that `condition()` implies `x` is readable, whereas the optimized
version requires the unconditional validity of `x`.
Tree Borrow's approach to this is to perform a fake read access upon a reborrow,
thus asserting that every newly created reference can be read from.

> <span class="sbnote">
**[Note: Stacked Borrows]**
Both Tree Borrows and Stacked Borrows perform this fake read access on a shared reborrow.
However on a mutable reborrow, Stacked Borrows performs an additional fake write access,
which Tree Borrows does not. This costs some optimizations (some reorderings involving writes)
but makes mutable references interact more consistently with shared references.
</span>

This also allows the use of the
[dereferenceable](https://llvm.org/docs/LangRef.html) attribute in LLVM, which
enables additional optimizations.

```rust
//- TB: UB (reborrow from `Disabled`)
//- This code violates LLVM assumptions, it MUST BE UB.
fn reborrow_disabled(u: &mut u8) {
    let x = &mut *u;
    *x = 42;

    let y = &mut *u;
    *y = 36;
                        // --- u: Active
                        //     |--- x: Disabled
                        //     |--- y: Active
    let z = &*x;
                        // This is an attempted reborrow from `x: Disabled`.
                        // It counts as an attempted read, and `Disabled` forbids
                        // reads.
                        // This is UB.
}
```

Creating a raw pointer however does not perform this check, and the operation
`let xraw = x as *mut u8`{.rust} produces no read access. In addition, Tree Borrows
considers accesses through raw pointers to be equivalent to accesses through their
parent reference.
```rust
//+ TB: NO UB (raw pointers derived from the same reference can coexist)
fn several_raw(u: &mut u8) {
    let r0 = &mut *u;
    *r = 42;
                           // --- u: Active
                           //     |--- r0: Active

    let r1 = r0 as *mut u8;
    let r2 = r0 as *mut u8;
    let r3 = r0 as *mut u8;
                           // Raw pointers are considered equivalent to their parent reference.
                           // --- u: Active
                           //     |--- r0,r1,r2,r3: Active

    *r1 += 1;
    *r3 += 1;
    *r0 += 1;
    *r2 += 1;
    *r1 += 1;
                           // Any sequence of operations is allowed between raw pointers derived from
                           // the same reference, since TB sees all of these as if they were accesses
                           // through `r0` directly.

    *u += 1;
                           // Raw pointers die when their parent reference dies.
                           // --- u: Active
                           //     |--- r0,r1,r2,r3: Disabled
}
```

> <span class="sbnote">
**[Note: Stacked Borrows]**
Tree Borrows' approach to raw pointers (having them share exactly the same permission
as their direct parent at all times) avoids Stacked Borrows'
[Issue #227](https://github.com/rust-lang/unsafe-code-guidelines/issues/227)
of ambiguity in inherited permissions.
</span>

## References can live together when `Frozen`

Shared references point to data that must by definition allow sharing.
There must be some permission to represent data that is borrowed immutably,
and it must allow both child and foreign reads.
We call this permission `Frozen`, and it is unaffected by all read accesses.
Of course `Frozen` disallows child writes.

An assumption that we wish to make is that the shared data is immutable,
which allows the following optimization

```rust
//? Unoptimized
let x = &*u;
let before = *x;
foo();
let after = *x;
let sum = before + after;

//? Optimized
let x = &*u;
let xval = *x;
foo(); // Assumption: `foo()` cannot mutate `*x`
let sum = xval * 2;
```

This suggests that when the location is written to, `Frozen` must become `Disabled`:
a shared reference is only alive as long as no foreign writes occur.

#### Example: write access kills shared references

```rust
//- TB: UB (shared reference is killed by write)
fn share_until_write(u: &mut u8) {
    let x = &*u;
    let y = &*x;
    let z = &*u;
                        // As many `Frozen` as needed can coexist.
                        // They can be only read, but the order does not matter.
                        // --- u: Active
    let _v = *y;        //     |--- x: Frozen
    let _v = *x;        //     |    |--- y: Frozen
    let _v = *z;        //     |--- z: Frozen
                        // (`Frozen` is unaffected by child and foreign reads)
                        // (`Active` is unaffected by child reads)
    let w = &mut *u;
    *w = 42;
                       // All shared borrows are killed on a write access
                       // --- u: Active
                       //     |--- x: Disabled
                       //     |    |--- y: Disabled
                       //     |--- z: Disabled
                       //     |--- w: Active

    let _v = *x;
                       // Attempted read through a `Disabled` pointer
                       // This is UB.
}
```


## Don't `Disable` immediately, keep `Frozen` instead

Until now we have avoided the question of what to do when an `Active` encounters
a read. Since mutable references also permit read-only access it should be obvious
that child reads are allowed, but what happens on a foreign read ?

The Borrow Checker suggests that the mutable reference should be killed completely,
but we argue that it should merely become `Frozen`. In other words a mutable
reference is downgraded to a shared reference when other shared references start
accessing the data immutably.

```rust
//+ TB: NOT UB (mutable reference is still accessible as read-only)
//- Does not compile. error[E0502]: cannot borrow `*u` as immutable because it is also borrowed as mutable.
fn shared_from_mut(u: &mut u8) {
    let x = &mut *u;
                        // First mutable borrow
                        // --- u: Active
                        //     |--- x: Active
                        // (`u: Active` is unafected by the child write)
    *x = 42;

    // The mutable lifetime of `x` ends here, but it will still be available read-only

    let y = &*u;
                        // Second borrow is immutable
                        // --- u: Active
                        //     |--- x: Frozen
                        //     |--- y: Frozen
                        // (`u: Active` is unaffected by the child read)
                        // (`x: Active` is made `Frozen` by the foreign read)

    let _v = *x;        // `x` has been downgraded to a shared reference,
                        // this read access _is_ allowed by TB (not by the compiler though),
                        // and is a no-op in terms of permissions.
}
```

So why do we allow this ? The main reason is that we want the compiler to always
be able to reorder read-only accesses, and doing so must absolutely not introduce
new UB !

```rust
//+ TB: NOT UB (properly nested)
//+ This is safe code that compiles, it MUST NOT BE UB.
fn swappable_reads(u: &mut u8) {
    let x = &mut *u;
    *x = 42;

                      // Currently
                      // --- u: Active
                      //     |--- x: Active
                      //
                      // What happens if we reorder these two reads ?
    let _v = *x;      //  <--- (1)
    let _v = *u;      //  <--- (2)
                      //
                      // Answer: `x: Active` would be subjected to (2) a foreign read.
                      // If this made `x` become `Disabled`, then the following (1) child write would be UB.
                      // For reads to always be possible to reorder, it must hold that a read through a
                      // pointer never makes another pointer `Disabled`. Since the other pointer must not stay
                      // `Active`, `Frozen` is the solution.
}
```

> <span class="sbnote">
**[Note: Stacked Borrows]**
In Stacked Borrows mutable references are _not_ downgraded to shared references, they are
instead completely invalidated on a read access. This is undesirable since it invalidates
a standard optimization, but it is also required in Stacked Borrows otherwise other bigger problems
appear.
</span>

> <span class="tldr">
**[Summary]**
`Frozen` is a permission that represents immutable or no-longer-mutable
references. It is the permission that shared references are initialized to, and it
enables sharing read-only data.
<br>- `Frozen` allows child reads and forbids (UB) child writes,
<br>- `Frozen` is unaffected by foreign reads,
<br>- `Frozen` becomes `Disabled` on a foreign write.
<br>- `Active` becomes `Frozen` on a foreign read.
</span>

## `Reserve` until needed

There are several motivations for not making mutable references immediately `Active`
and for not performing a fake write upon creation:

- [two-phase borrows](https://rustc-dev-guide.rust-lang.org/borrow_check/two_phase_borrows.html)
  require that a mutable reference implicitly reborrowed in a function argument still allows
  read-only accesses until function entry;
- some functions such as `as_mut_ptr` require an `&mut` reference but do not actually
  mutate the data, so making the mere creation of an `&mut` a write access causes some
  read-only code to contain UB.

We model this by introducing a new state called `Reserved`, which allows
child and foreign reads until the reference is written to.

> <span class="tldr">
**[Summary]**
`Reserved` is the permission of a not-yet-mutable or two-phase-borrowed pointer.
<br>- `Reserved` becomes `Active` on the first child write,
<br>- `Reserved` otherwise behaves exactly like a `Frozen`: it allows child reads,
  is unaffected by foreign reads, and becomes `Disabled` on a foreign write.
</span>

This `Reserved` permission makes a lot of code allowed, including
some very common patterns of `unsafe` code, and even some safe code that we would have
needed to allow anyway and would have been much more difficult to handle were it not
for `Reserved`.

#### Example: easy two-phase borrow with `Reserved`

[Two-phase borrows](https://rustc-dev-guide.rust-lang.org/borrow_check/two_phase_borrows.html)
are the main use of `Reserved`.

```rust
//+ TB: NOT UB (standard two-phase borrow example)
//+ This is safe code that compiles, it MUST NOT BE UB.
fn push_len(v: &mut Vec<usize>) {
    v.push(v.len());
}
```

The above code desugars to approximately

```rust
//+ TB: NOT UB (standard two-phase borrow example -- desugared)
//+ This is (unsafe) desugaring of safe code, it would be PREFERABLY NOT UB.
fn push_len_desugared(v: &mut Vec<usize>) {
    let temp_vmut = &mut v;
    // --- Two-phase borrow begins ---

    let temp_vshr = &v;
                                        // At this point we have
                                        // --- v: Reserved
                                        //     |--- temp_vmut: Reserved
                                        //     |--- temp_vshr: Frozen
    let temp_len = Vec::len(temp_vshr);
    // This is a foreign read for `temp_vmut: Reserved` which is unaffected.
    // No write has occured since the beginning of the two-phase borrow.

    // --- Two-phase borrow becomes a true active mutable borrow. ---
    Vec::push(temp_vmut, temp_len);
                                        // Now a child write through `temp_vmut` finally occurs
                                        // --- v: Active
                                        //     |--- temp_vmut: Active
                                        //     |--- temp_vshr: Disabled
}
```

> <span class="sbnote">
**[Note: Stacked Borrows]**
Stacked Borrows has no direct equivalent of `Reserved`: in SB two-phase borrows
are raw pointers (much more permissive than `Reserved`) and standard mutable borrows
are `Unique` (much more strict than `Reserved`).
</span>

#### Example: stdlib test that passes thanks to `Reserved`

```rust
//+ TB: NOT UB (still `Reserved` at the time of `assert`)
//+ This is (almost) stdlib code, it would be PREFERABLY NOT UB.
fn mut_raw_then_mut_shr() {
    let mut x = 2;
    let xref = &mut x;
    let xmut = &mut *xref;
    let xshr = &*xref;
    assert_eq!(*xshr, 2); // At this point, `xmut: Reserved`. It allows the foreign read through `xshr: Frozen`.
    *xmut = 4;            // Now `xmut` becomes `Active`.
    assert_eq!(x, 4);     // And then a parent read through `x: Active` makes `xmut: Frozen`
}
```

#### Example: `copy_nonoverlapping`

```rust
//+ TB: NOT UB (Reserved interacts nicely with reborrow-and-offset)
//+ Common pattern, would be PREFERABLY NOT UB.
let data = &mut [0u8, 1u8];
unsafe {
    let raw_shr = data.as_ptr(); // implicitly reborrows an `&` reference, producing `Frozen`
    let raw_mut = data.as_mut_ptr().add(1); // implicitly reborrows an `&mut` reference, producing `Reserved`

                                            // At this point we have
                                            // --- data: Active|Active
                                            //     |--- raw_shr: Frozen|Frozen
                                            //     |--- raw_mut: Reserved|Reserved

    core::ptr::copy_nonoverlapping(raw_shr, raw_mut, 1);

                                            // The write affects only the second location,
                                            // no UB occurs and the borrows are now
                                            // --- data: Active|Active
                                            //     |--- raw_shr: Frozen|Disabled
                                            //     |--- raw_mut: Reserved|Active
}
```

In this example we call `data.as_ptr()`{.rust} followed by `data.as_mut_ptr()`{.rust}.
The opposite ordering (computing `raw_mut` then `raw_shr`) results in exactly the same tree
since both `Reserved` and `Frozen` tolerate the read-only reborrow of `as{_mut,}_ptr`.

> <span class="sbnote">
**[Note: Stacked Borrows]** Stacked Borrows does not allow both orderings: computing `raw_mut` second asserts
uniqueness and invalidates `raw_shr`.
More generally Stacked Borrows immediately asserts uniqueness upon creation of an `&mut`,
which has been reported to be [too strict](https://github.com/rust-lang/unsafe-code-guidelines/issues/133).
</span>

<!-- FIXME: sometimes needs less brutal context switching and reasoning skips -->

## Permitted optimizations

The model so far allows at least the following optimizations:

### Grouping together related writes

Unfortunately it is not always possible to reorder writes accesses with code that performs
reads, as the following example shows

```rs
let x = &mut *u; // `x: Reserved`
let yval = *y;   // Regardless of whether `x` and `y` alias, `x` is still `Reserved`
*x += 1;         // `x: Active`
                 // NO UB according to TB even if `x` and `y` alias.
                 // Therefore we can't _assume_ that `x` and `y` don't alias,
                 // the read and the write cannot be reordered unless we _know_
                 // through other means that they are disjoint.
```

> <span class="sbnote">
**[Note: Stacked Borrows]** Stacked Borrows allows the above optimization, at
the cost of a less homogeneous handling of mutable references (allowed for standard
reborrows but disallowed for two-phase borrows).
</span>

However in Tree Borrows we can still group together related writes if there are no child pointers.

```rs
//? Unoptimized
let x = &mut *u;  // `x: Reserved`, also `x` does not have child pointers
*x += 1;          // `x: Active`
let yval = *y;    // If `y` and `x` alias then `x: Disabled` otherwise `x: Active`
*x += 1;          // If `y` and `x` alias then UB Otherwise `x: Active`

// We can assume that `x` and `y` do not alias and group together the two increments

//? Optimized
let x = &mut *u;
*x += 2;
let yval = *y;
```

### Reordering any two reads

Reordering two read operations is a standard optimization and it obviously
does not change the behavior of the program, but we must take care that it
does not introduce additional UB.

> <span class="sbnote">
**[Note: Stacked Borrows]** Stacked Borrows suffers from this issue, where a read-only
access to a reference invalidates existing mutable references even for reading. While the original
purpose is to enable more optimizations, this results in existing optimizations
actually being forbidden because the optimized code exhibits UB.
</span>

For Tree Borrows, in defining the effects of read accesses we have ensured that
a read access never invalidates (causes to be UB) another read: permissions
that allow reading (`Reserved`, `Active`, and `Frozen`) and are subjected
to a foreign read result in permissions that still allow reading (`Reserved` and `Frozen`).
Therefore the model allows any reordering of any adjacent read operations.

This also includes the possibility of reordering reborrows with each other and
with reads, since (1) reborrows do not count as write accesses and (2) both
initial permissions (`Reserved` and `Frozen`) created after a reborrow tolerate
foreign reads. The `copy_nonoverlapping` example above is one such instance.

---

\[ [Prev](core.html) | [Up](index.html) | [Next](protectors.html) \]

---
