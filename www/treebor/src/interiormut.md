---
title: "Tree Borrows -- Dealing with Cells"
subtitle: A new aliasing model for Rust
author: Neven Villani
date: Mar. 2023
output: html_document
lang: en
---

\[ [Prev](protectors.html) | [Up](index.html) | [Next](range.html) \]

## Why interior mutable types need special attention

There are several ways in which interior mutable types break some of the assumptions
made so far.

#### Example: mutation is possible through an `&` reference

```rust
//+ This is safe code that compiles, it MUST NOT BE UB.
fn set(u: &Cell<u8>) {
    u.set(42); // This performs a write access, but the parent is a `&` which should be `Frozen`
}
```

#### Example: mutation is allowed during a two-phase borrow

The complete version of this code is available as a
[miri test case](https://github.com/rust-lang/miri/blob/master/tests/pass/tree-borrows/2phase-interiormut.rs)

```rust
//+ This is safe code that compiles, it MUST NOT BE UB.
fn mutation_during_two_phase(u: &mut Cell<u8>) {
    let x = &u;
    u.something({ // Start a two-phase borrow of `u`
        // Several foreign accesses (both reads and writes) to the location
        // being reborrowed. The two-phase borrow of `u` must not be invalidated at any point.
        u.set(3);
        x.set(4);
        u.get() + x.get()
    });
}
```

## Additions to the model

The above two examples would be UB if interior mutable references were treated regularly,
because an `&` reference of a type with interior mutability allows things that a `Frozen` does
not.
In Tree Borrows we choose the following

- shared reborrows of interior mutable types are treated like raw pointers, that is
  accesses through an interior mutable `&` reference are counted as accesses through
  the parent reference;
- `Reserved` pointers with interior mutability are unaffected by foreign writes
  in addition to being normally unaffected by foreign reads.

Just like raw pointers, shared reborrows of types with interior mutability are invalidated
when their parent reference is invalidated. This lets us mix together alternating
writes from shared interior mutable references from the same level, i.e. that
were derived from the same reference.

In order to still preserve some guarantees, the following aspects are unchanged
from how normal references behave:

- when under a protector, interior mutable `Reserved` no longer allow foreign reads;
- interior mutable `Reserved` still become `Active` upon a child write, so that
  `&mut Cell<_>` is properly unique.


# Complete summary

With this the model is complete, and we summarize it with the following automaton:

![](automaton.svg)

**When creating a new pointer `z` from an existing `y`**

- if `z` is a `Unpin` mutable reference
    - perform the effects of a read access through `y`
    - add a new child of `y` in the tree
    - give it the permissions `Reserved`
    - keep track of whether it has interior mutability or not as `ty_is_freeze`
- if `z` is a non-interior-mutable shared reference
    - perform the effects of a read access through `y`
    - add a new child of `y` in the tree
    - give it the permissions `Frozen`
- otherwise give `z` the same tag as `y`, they are indistinguishable from now on

**When reading through a pointer `y`**

- for all ancestors `x` of `y` (including `y`), this is a child read
    - assert that `x` is readable (i.e. is `Frozen` or `Reserved` or `Active`)
    - otherwise (if `x` is `Disabled`) this is UB
- for all non-ancestors `z` of `y` (excluding `y`), this is a foreign read
    - turn `Active` into `Frozen`; this is UB if `z` is protected
    - if `z` is protected, turn `Reserved` into `Frozen`

**When writing through a pointer `y`**

- for all ancestors `x` of `y` (including `y`), this is a child write
    - turn `Reserved` into `Active`
    - it is UB to encounter `Disabled` or `Frozen`
- for all non-ancestors `z` of `y` (excluding `y`), this is a foreign write
    - if `z` is protected this is always UB; otherwise
    - if `z` is `Reserved` and has interior mutability it is unchanged; otherwise
    - turn `Reserved` and `Active` and `Frozen` into `Disabled`


---

\[ [Prev](protectors.html) | [Up](index.html) | [Next](range.html) \]

---
