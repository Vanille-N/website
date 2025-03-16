---
title: "Tree Borrows -- Core Model"
subtitle: A new aliasing model for Rust
author: Neven Villani
date: Mar. 2023
output: html_document
lang: en
---

\[ ------------ | [Up](index.html) | [Next](shared.html) \]

In this first part we establish the core model of Tree Borrows (TB), which for
now handles only code that has exclusively mutable references.
Later parts will add shared references, function calls, raw pointers, and
interior mutability.

---

## Preliminaries

### Purpose

Tree Borrows defines an _aliasing model_ for pointers and references, which sets
the limits on the aliasing assumptions that can be made. These assumptions include
guarantees such as "reading twice from the same `&`{.rust} reference returns the same value",
or "an `&mut` reference has exclusive access to the data it mutates".

These assumptions in turn allow some optimizations (e.g. if `&`{.rust} references are
immutable then the compiler can delete redundant reads), but they can be violated
by `unsafe`{.rust} code. This leads to many optimizations that are valid in safe
codebases but not in the presence of `unsafe`{.rust}.

Tree Borrows restores some of these assumptions by enforcing more restrictions
on runtime usage of `unsafe`{.rust} operations, which leads to the assumptions defined
by Tree Borrows (and the associated optimizations) to hold for both safe and `unsafe`{.rust}
code.

### Structure

In order to precisely define these assumptions, Tree Borrows models how a virtual
state machine evolves with each operation of the program, and if the state machine
reaches a forbidden configuration then the program is declared Undefined Behavior (UB).

Tree Borrows' state machine is based on the following core principles

1. **Tracking the permissions of each pointer.**
Each pointer carries information on which bytes of memory it is allowed to
access. UB occurs when an access is attempted through a pointer that does not
have sufficient permissions. This could occur because the access is out of range
or because the pointer has been invalidated which causes it to lose its permissions.
The list of permissions will be progressively completed as we show that different
kinds of pointers must behave differently.

2. **Updating permissions based on ancestry.**
The name of Tree Borrows comes from the tree structure that naturally appears
when we consider reborrows as creations of child pointers.
Indeed a tree structure is perfect for modeling the fact that if a pointer is
invalidated then all pointers reborrowed from it must also be invalidated.

In general we have full control over child pointers: we can determine
locally whether child pointers exist, and accesses through child pointers do
not invalidate the parent pointer. In contrast there can be an unknown amount
of non-child pointers, and accesses through them might occur in parallel.
This distinction is important for Tree Borrows, which handles differently
accesses through child or non-child pointers.

- An access through a child pointer is called a **child access**. Child accesses
require some permissions, and cause UB if and only if the permissions of the
pointer are insufficient.

- An access through a non-child pointer is called a **foreign access**.
Foreign accesses cause the pointer to lose permissions, and can cause UB if
the pointer in question is not allowed to lose permissions.

Each piece of code that we wish to accept or reject will determine how
exactly each permission should be updated for each kind of access and relative
position in the borrow tree. The precise behavior of Tree Borrows is thus parameterized
by the list of all permissions and how they should be updated.

> <span class="implnote">
**[Note: Implementation]** in the [Miri implementation](https://github.com/rust-lang/miri),
[tree.rs](https://github.com/rust-lang/miri/blob/master/src/borrow_tracker/tree_borrows/tree.rs)
defines the core structure of Tree Borrows which consists of tree traversals, while
[perms.rs](https://github.com/rust-lang/miri/blob/master/src/borrow_tracker/tree_borrows/perms.rs)
defines the more _ad hoc_ parts of the model, i.e. the list and behavior of permissions,
which are not `pub`{.rust}. Thus even at the implementation level there is a clear separation
between the high-level structure (propagation of foreign vs child accesses) and the details
(state machine of permissions).
</span>

> <span class="sbnote">
**[Note: Stacked Borrows]** compared to Stacked Borrows we gain heredity information (lossless parent-child
relationship) but lose chronological information (between two pointers both derived
from a same parent, Tree Borrows does not keep track of which one was created first).
In fact, this loss of chronological information enables optimizations that Stacked Borrows does
not, since it allows reordering reborrows.
</span>

### Access-based borrow tracking

Tree Borrows is characterized by the fact that it executes at **runtime** and is
**access-based**, as opposed to compile-time and scope-based.
The code is executed, and the model tracks updates to the state of borrows after
each _access_. Code that is never executed cannot produce UB.

Tree Borrows is in this sense more fine-grained than the Borrow Checker,
which rejects some examples where it is very obvious that no aliasing _actually_
occurs thanks to runtime conditional guards.

#### Example: faulty code is unreachable at runtime
```rust
//+ TB: NOT UB (aliasing code never executes)
//- Does not compile. error[E0499]: cannot borrow `*u` as mutable more than once at a time
fn unreachable_faulty(u: &mut u8) {
    if false {
        let x = &mut *u;
        let y = &mut *u;
        *x += 1;
        *y += 1;
    }
}
```

#### Example: aliasing never occurs thanks to conditional
```rust
//+ TB: NOT UB (in all possible executions, if `u` and `v` are disjoint then `x` and `y` are disjoint)
//- Does not compile. error[E0499]: cannot borrow `*v` as mutable more than once at a time
fn maybe_aliasing(u: &mut u8, v: &mut u8, b: bool) {
    let x = if b { &mut *u } else { &mut *v };
    let y = if b { &mut *v } else { &mut *u };
    *x += 1;
    *y += 1;
}
```

### Per-location tracking

Apart from some shared internal state at the allocation level, Tree Borrows
operates at the _location_ (byte) level. This allows finer management of permissions:
a single pointer might have permissions that allow mutable accesses on some
locations, but only read accesses on other locations.

This allows for different bytes of a single piece of data to be borrowed independently,
which permits separate references to different indexes of an array or to
different fields of a `struct`{.rust}: as long as the borrows are on disjoint parts
of memory (and even if it is impossible to guarantee at compile-time that those
parts are disjoint, but they happen to be at runtime) the behavior according to
Tree Borrows will generally be trivial in the sense that there is no aliasing
on each location.

### Unsafe

Tree Borrows also differs from the Borrow Checker in that it does not handle
`unsafe`{.rust} code any differently from safe code. Sometimes we will show code
that does not actually compile because it is rejected by the Borrow Checker.
This is to make the notations less heavy, and should any code fail to compile
you should assume that the following transformations are to be applied:

- wrap the entire code snippet in `unsafe`{.rust},
- perform a round trip to and from raw pointers on each reborrow.

These are no-ops from the point of view of Tree Borrows, but they trick
the Borrow Checker into losing track of the compile-time aliasing conflicts.

#### Example: the two following functions are identical for Tree Borrows
```rust
//- TB: UB (`x` and `y` alias)
//- Does not compile. error[E0499]: cannot borrow `*u` as mutable more than once at a time.
fn example_default(u: &mut u8) {
    let x = &mut *u;
    let y = &mut *u;
    *x += 1;
    *y += 1;
}
```

```rust
//- TB: UB (`x` and `y` alias)
//+ Compiles without errors.
fn example_fixed(u: &mut u8) { unsafe {
    let x = &mut *addr_of_mut!(*u);
    let y = &mut *addr_of_mut!(*u);
    *x += 1;
    *y += 1;
} }
```

using `std::ptr::addr_of_mut!`{.rust}.
The same trick works with `let x = &mut *(u as *mut u8)`{.rust}.

> <span class="tldr">
**[Summary]**
Each pointer on each byte of memory has a _permission_. This permission
dictates what accesses are allowed through this pointer and child pointers,
and evolves depending on the accesses performed by non-child pointers.
</span>

## The core model

> <span class="sbnote">
**[Note: Stacked Borrows]**
Write accesses to mutable references follow a stack discipline, which Stacked Borrows
already handles without any issues. Here we reframe and justify similar rules for the tree setting.
</span>

The essential assumptions that we wish to make concerning mutable references are
the following

```rust
//? Unoptimized
let x = &mut *u;
*x = 36; // This write is immediately overwritten, but optimizing it away requires assuming
         // that no other pointer has read permissions on the location.
*x = 42;

//? Optimized
let x = &mut *u;
*x = 42;
```

```rust
//? Unoptimized
let x = &mut *u;
*x = 42;
let xval = *x; // This read is expected to yield the value just written, but it requires
               // assuming that no other pointer has write permissions on the location.

//? Optimized
let x = &mut *u;
*x = 42;
let xval = 42;
```

Code that violates these assumptions is code that alternates writes between
two sources, which Tree Borrows detects using the `Active` and `Disabled` permissions:

- an `Active` pointer is a live mutable reference
- a `Disabled` pointer is a dead reference

### `Active` and `Disabled`: tracking exclusive mutable access

Guaranteeing that mutable references have exclusive access means that the
lifetimes of mutable references must be disjoint. This is easy to check: when
the lifetime of a new mutable reference begins, the old ones must no longer be `Active`.
Equivalently when an access occurs that activates a mutable reference, we kill other mutable references.

```rust
//+ TB: NOT UB (the mutable references properly have exclusive access for disjoint lifetimes)
fn refmut_disjoint(u: &mut u8) {
    let x = &mut *u;
    *x = 42;
    // ----- lifetimes of `x` and `y` properly disjoint -----
    let y = &mut *u;
    *y = 36;
}
```

```rust
//- TB: UB (the lifetimes of mutable references intersect)
fn refmut_intersecting(u: &mut u8) {
    let x = &mut *u;
    let y = &mut *u;
    // ----- lifetimes of `x` and `y` intersect -----
    *x = 42;
    *y = 36;
}
```

```rust
//+ TB: NOT UB (properly nested reborrow)
fn refmut_nested(u: &mut u8) {
    let x = &mut *u;
    {
        // `y` is a properly nested reborrow of `x`
        let y = &mut *x;
        *y = 36;
    }
    *x = 42;
}
```

> <span class="tldr">
**[Summary]**
Proper nesting of child lifetimes and disjointness of sibling lifetimes
are enforced by the `Active` and `Disabled` permissions:
<br>- `Active` is a live mutable reference, `Disabled` is a dead mutable reference;
<br>- all write accesses must be done through an `Active` pointer,
attempting to write through `Disabled` is UB;
<br>- a foreign write turns any existing `Active` permissions into `Disabled`.
</span>

#### Example: how TB detects an improperly nested reborrow

```rust
//- TB: UB (improperly nested reborrow)
fn refmut_nested(u: &mut u8) {
    let x = &mut *u;
    *x = 42;
                          // Created a new reborrow `x` child of `u`
                          // --- u: Active
                          //     |--- x: Active
                          // (`u` is unchanged by the child write through `x`)
    let y = &mut *x;
    *y = 36;
                          // Created a new reborrow `y` child of `x`
                          // --- u: Active
                          //     |--- x: Active
                          //          |--- y: Active
                          // (`u` is unchanged by the child write through `y`)
                          // (`x` is unchanged by the child write through `y`)
    *x = 42;
                          // Write access
                          // --- u: Active
                          //     |--- x: Active
                          //          |--- y: Disabled
                          // (`u` is unchanged by the child write through `x`)
                          // (`y` is disabled by the foreign write through `x`)
    *y = 36;
                          // Attempted write through a pointer that is `Disabled`.
                          // This is UB.
}
```

#### Example: how TB detects intersecting lifetimes

```rust
//- TB: UB (the lifetimes of mutable references intersect)
fn refmut_intersecting(u: &mut u8) {
    let x = &mut *u;
    *x = 42;
                          // Created a new reborrow `x` child of `u`
                          // --- u: Active
                          //     |--- x: Active
                          // (`u` is unchanged by the child write through `x`)

    let y = &mut *u;
    *y = 36;
                          // Created a new reborrow `y` child of `u`
                          // --- u: Active
                          //     |--- x: Disabled
                          //     |--- y: Active
                          // (`u` is unchanged by the child write through `y`)
                          // (`x` is disabled by the foreign write through `y`)

    *x = 42;
                          // Attempted write through a pointer that is `Disabled`.
                          // This is UB.
    *y = 36;
}
```

> <span class="sbnote">
**[Note: Stacked Borrows]**
In Stacked Borrows terms, an `Active` is a `Unique` that is still in the stack,
and a `Disabled` is an item that was popped. So far since the tree is limited to a single `Active`
path, trimming all the `Disabled` branches results in a stack-like tree that directly
matches the stack that Stacked Borrows would have at the same point of the execution.
</span>

---

\[ ------------ | [Up](index.html) | [Next](shared.html) \]

---

