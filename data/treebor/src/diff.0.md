---
title: "Tree Borrows -- Diff for 2023-10-20"
subtitle: A new aliasing model for Rust
author: Neven Villani
date: Oct. 2023
output: html_document
lang: en
---

\[ ------------ | [Up](index.html) | ------------ \]

In the process of trying to formalize the rules of Tree Borrows to prove that they do indeed provide the optimizations
we claim, we discovered some issues and attempted to fix them.

This document is an explanation of what issues we found, and how we solved them.

If you are already familiar with the old [Tree Borrows](https://perso.crans.org/vanille/treebor.0) model and want
to have a quick update on what changed since the last time Tree Borrows was fully explained, you're in the right
place. If you are new to Tree Borrows you should consider reading directly the
[updated model](https://perso.crans.org/vanille/treebor) so that you don't waste time learning about things that
were later changed.

---

# The problem

Recall that one crucial requirement of a valid optimization is that it must not introduce
UB in a program that didn't already contain UB, because from there any behavior could emerge from a source
program without any UB. The two issues that I will show here are instances of this, where inserting a
spurious read introduces additional UB in the target program.

## Spurious reads blocked by `[P]Reserved -> [P]Frozen`

Here is the same example as in [the PR that found the issue](https://github.com/rust-lang/miri/pull/3054):

```rust
// Aliased piece of data.
let mut data = 0;

// Thread 1 that accesses the data.
// It doesn't do anything visible, but internally this emits several TB operations:
// `x` is retagged as protected `Frozen`, an implicit read is inserted on reborrow,
// and then the protector is removed.
fn f1(x: &u8) {}
let _ = thread::spawn(|| {
    f1(&data)
};

// Thread 2 that accesses the data.
// It does a much more visible thing which is to write to `y`, but the interesting
// part of its behavior is actually invisible here.
// For a short period of time, `y` is protected `Reserved`, which you may
// remember (https://perso.crans.org/vanille/treebor.0/protectors.html)
// is affected by foreign reads and becomes `Frozen`.
fn f2(y: &mut u8) -> &mut u8 { &mut *y }
let _ = thread::spawn(|| {
    let y = f2(&mut data);
    *y = 42;
});
```

A possible interleaving of the above code would be
```rust
1: retag x (&, protect)    // x: [P]Frozen
2: retag y (&mut, protect) // x: [P]Frozen      y: [P]Reserved
1: return f1               // x:    Frozen      y: [P]Reserved
2: return f2               // x:    Frozen      y:    Reserved
2: write y                 // x:    Disabled    y:    Active
```
which doesn't exhibit any UB. No problem so far.

However if at this point we try to insert a spurious read, it might become
```rust
1: retag x (&, protect)    // x: [P]Frozen
2: retag y (&mut, protect) // x: [P]Frozen      y: [P]Reserved
1: spurious read x         // x: [P]Frozen      y: [P]Frozen       <- inserted
1: return f1               // x:    Frozen      y: [P]Frozen
2: return f2               // x:    Frozen      y:    Frozen
2: write y                 // attempted write through Frozen: UB
```
Now this interleaving is UB! The optimization is thus invalid.

This is a big deal since we have always promised that
[tree borrows would allow spurious reads](https://perso.crans.org/vanille/treebor.0/protectors.html)!
This is thus a model-breaking issue that has to be fixed.

We don't really care about there being UB in this example, it would be nice if there weren't any,
but what absolutely must not happen is UB in the target without UB in the source.

## A word on how we found the issue

Because Tree Borrows tracks permissions with independent per-tag finite state machines,
we can do [exhaustive testing](https://github.com/rust-lang/miri/pull/3054/files#diff-e58ce10647404fb1de369b1fc21f786f6e02a84fdb26460001ea3864e7dee10f)
that some properties are satisfied, and in this case we found that the exhaustive tests for spurious
reads flagged this kind of example as invalid which led us to analyse the problem more closely.

These same exhaustive tests should give you a reasonable confidence that the fix I will now propose
is actually correct, because it passes all the exhaustive tests that we threw at it.

## Another problematic interleaving

The following interleaving is *also* problematic for orthogonal reasons:
```rust
1: retag x (&, protect)     // x: [P]Frozen
2: retag y (&mut, protect)  // x: [P]Frozen       y: [P]Reserved
1: ret x                    // x:    Frozen       y: [P]Reserved
2: write y                  // x:    Disabled     y: [P]Active 
2: ret y                    // x:    Disabled     y:    Active
```
no UB there, but if we again introduce a spurious read through `x` then
```rust
1: retag x (&, protect)     // x: [P]Frozen
2: retag y (&mut, protect)  // x: [P]Frozen       y: [P]Reserved
1: spurious read x          // x: [P]Frozen       y: [P]Frozen      <- inserted
1: ret x                    // x:    Frozen       y: [P]Frozen
2: write y                  // attempted write through Frozen: UB
2: ret y
```
we get UB. The spurious read is thus once again invalid.
This program must absolutely be UB in the target because inserting a spurious
read makes it violates the rules of `noalias`:
In the source, the protector on `y` had never been subjected
to any visible effect from the existence of `x`, since `x` was reborrowed
before `y` even existed! To fix this example we must make the source UB.

# Solution outline

We thus observe two issues with the current model

1. **A foreign read should not have effects beyond function boundaries**,
   the transition `[P]Reserved -> [P]Frozen` is much too restrictive because
   it forever prevents this tag from being activated.
2. **Protectors merely existing at the same time should have some effect**,
   so far protectors only influence the behavior when accesses occur but we have
   shown that protectors even existing at the same time is problematic, because
   protectors enable spurious reads.

Our solution to these two problems consists of

1. **Introducing more variants of `Reserved`**, we add a new boolean flag to `Reserved`
   that records whether this tag can be activated on this location, but we ensure
   that this flag has no effect after function exit.
2. **Removing a protector emits a read**, in some sense Protectors "announce" their
   existence on creation through the implicit read, now they will also announce
   their end so that no matter the interleaving two protectors that exist simultaneously
   will have an effect on each other.


# Implementation details

## 1. More fine-grained `Reserved`

We change `Reserved` to
```rust
Reserved {
    ty_is_freeze: bool, // interior mutability
    conflicted: bool, // new flag
}
```

Initially `conflicted: false`, and the transitions that change are
```rust
// Foreign Read
// Formerly this would Freeze. Now we just set the `conflicted` flag instead, which is a temporary
// change because the rest of the transitions only look at `conflicted` if the tag is also protected.
    Reserved { ty_is_freeze, .. } if protected => Reserved { ty_is_freeze, conflicted: true }

// Child Write
// Formerly a `Reserved` could always be activated. Now we need it to not be both protected and `conflicted`.
// This implements the fact that a child write is temporarily blocked when a foreign read occurs first.
    Reserved { conflicted: true, .. } if protected => return None // i.e. trigger UB
```

It should now be clear that indeed this `conflicted` flag has no effect once the protector is gone,
and we show how it solves the first of our two problematic interleavings.

```rust
1: retag x (&, protect)    // x: [P]Frozen
2: retag y (&mut, protect) // x: [P]Frozen      y: [P]Reserved
1: spurious read x         // x: [P]Frozen      y: [P]Reserved(conflicted)       <- changed from Frozen
1: return f1               // x:    Frozen      y: [P]Reserved(conflicted)
2: return f2               // x:    Frozen      y:    Reserved
2: write y                 // x:    Disabled    y:    Active                     <- activation succeeds, no more UB
```
(Actually `y` is still technically `Reserved(conflicted)` after function exit, but the `conflicted`
flag is not read and thus has no consequence)

We have successfully removed UB from the target, and we can insert spurious reads in this interleaving again!

## 2. Read on function exit

Let's now tackle the second problematic interleaving.
As said above, we will make protectors announce their end by emitting an implicit read on function exit
through all tags formerly protected by this function call.

### Why this is acceptable and necessary

We know that the tag must be readable, because the protector would have been triggered already
if the tag had stopped being readable.

By performing an actual read, we ensure that spurious reads are possible since any interleaving
that would be UB because of a spurious read would already be UB because of either the read-on-reborrow
or the read-on-exit.

### The other features of the protector are still required

This implicit read is not necessarily reachable, so it alone isn't enough to guarantee that if the
tag is invalidated UB will be triggered. We still need protectors to ensure that the tag has not been
made `Disabled`, and the implicit read on its own is not enough to guarantee that.

Instead the purpose of the implicit read is to inform _other tags_ of the existence of this protector.
By emitting a read access when the protector ends, we ensure that no matter the interleaving of retags
and function exits, protectors whose existence overlap will "alert" each other.

```
Case 1:
   <---------------->
                          <-------------------->
   The two protectors do not overlap, they may independently write
   and perform spurious reads. There is trivially no issue here.

Case 2:
                            |read
   <------------------------>
               <------------------------------->
               |read
   Both tags have been affected by a read from the other protected tag,
   a write through either will be UB, thus allowing the other to do
   spurious reads.

Case 3:
   <------------------------------------------->
                <----------------->
                |read             |read
   The longer-lived protector cannot write because of the two implicit reads,
   allowing the shorter-lived one to perform spurious reads. The latter still
   cannot ever write because it would invalidate the first through the already
   existing protector behavior.
```

### Several traps not to fall into

1. It used to be possible to create tags initially `Active`, this is problematic
   because an `Active` existing without a write access negates all our efforts on
   `Reserved`. We no longer ever create `Active` tags other than the root of the allocation.

2. The read on function exit must be performed only for initialized locations, otherwise
   there would obviously be issues if we attempted an implicit read to unreadable locations,
   and it needs to occur on *all* initialized locations (including those that were initialized
   late), otherwise the same issues will appear again on lazily initialized locations.

3. The read on function exit must not be visible to child pointers, otherwise we could no
   longer write code such as this one:
   ```rs
   fn write_zero_and_reborrow(x: &mut i32) -> &mut i32 {
       // x is protected
       let y = &mut *x; // y is a child of x
       *y = 0; // y is now Active
       y
   } // make sure that the implicit read through `x` doesn't freeze `y` !
   ```



\[ ------------ | [Up](index.html) | ------------ \]

---

