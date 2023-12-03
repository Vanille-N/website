---
title: "Tree Borrows -- Ranges"
subtitle: A new aliasing model for Rust
author: Neven Villani
date: Mar. 2023
output: html_document
lang: en
---

\[ [Prev](interiormut.html) | [Up](index.html) | ----------- \]

The model is complete for one-byte allocations, but we have not yet talked about
allocations that contain several locations. The first step to this is to observe
that the tree of pointers is the same for an entire allocation since the parent-child
relationship is global, and only the permissions have to be managed on a per-location
basis. When an access is performed, pointers have their permissions updated only
on the affected locations, so pointers performing accesses on disjoint ranges of
memory do not cause aliasing UB.

Since the range on which an access is performed is known, the remaining difficulty
is to determine the range on which a reborrow should be performed and which locations
the pointer should receive permissions on. These difficulties were noted in

- [Issue #276: handling `extern type`](https://github.com/rust-lang/unsafe-code-guidelines/issues/276)
- [Issue #134: range of raw pointers is too strict](https://github.com/rust-lang/unsafe-code-guidelines/issues/134)

These boil down to an issue of knowing on what range a pointer can be used.
Reborrowing immediately for the entire allocation is much too strict, since
we need the following code to be accepted:

```rust
//+ TB: NOT UB (Disjoint mutable references)
//+ This is safe code that compiles, it MUST NOT BE UB.
fn main() {
    let mut t = (0, 0);
    // `t.0` and `t.1` belong to the same allocation, but it is allowed
    // to take a mutable reference to each. Thus reborrowing `t.0` MUST NOT
    // reborrow all of `t`.
    inc_both(&mut t.0, &mut t.1);
}

fn inc_both(u: &mut u8, v: &mut u8) {
    *u += 1;
    *v += 1;
}
```

But on the other hand we would also like to be able to, among other things

- use a `*mut T` to access an entire array of `T`;
- access locations with the `add` method on pointers, which could offset the pointer
  beyond the range it was reborrowed on;
- have some guarantees for `extern type`s, the size of which is unknown.

All of these involve using a pointer out of the bounds of its reborrow
(but still within the bounds of its allocation), so in order to allow these
Tree Borrows must have some tolerance with regards to using a pointer
outside of the range it was reborrowed for.
Tree Borrows' solution is to not reborrow for the locations outside the range,
but to maintain enough information so that whenever the location is accessed
through a pointer for which it is out of range it can be initialized with a delay
and receive the permissions it would have had if it had been reborrowed from the start.

> <span class="implnote">
**[Note: Implementation]** This delayed initialization outside of the known reborrowed
range is indicated by the `initialized` boolean field of each memory location for each pointer
</span>

If such a location becomes `Disabled` it will not trigger a possible protector because
it has never been accessed through a child pointer. We write these not yet initialized
locations with `?`: they have the same transitions as the initialized versions,
and they become initialized on the first child access.
Here are examples of how this applies.

#### Example: write to offset pointer

```rust
//+ TB: NOT UB (Delayed initialization)
//+ Common pattern, it would be PREFERABLY NOT UB.
let val = [1u8, 2];
                                     // --- val: [Active, Active]
let ptr = &val[0] as *const u8;
                                     // --- val: [Active, Active]
                                     //     |--- ptr: [Frozen, Frozen?]
let _val = unsafe { *ptr.add(1) };
                                     // --- val: [Active, Active]
                                     //     |--- ptr: [Frozen, Frozen]
```

#### Example: write to disjoint fields

```rust
//+ TB: NOT UB (Disjoint mutable references)
//+ This is safe code that compiles, it MUST NOT BE UB.
fn main() {
    let mut t = (0, 0);
    inc_both(&mut t.0, &mut t.1);
}

fn inc_both(u: &mut u8, v: &mut u8) {
              // ---t: [Active, Active]
              //    |--- u: [Reserved, Reserved?] (protected)
              //    |--- v: [Reserved?, Reserved] (protected)
    *u += 1;
              // ---t: [Active, Active]
              //    |--- u: [Active, Reserved?] (protected)
              //    |--- v: [Disabled?, Reserved] (protected)
    *v += 1;
              // ---t: [Active, Active]
              //    |--- u: [Active, Disabled?] (protected)
              //    |--- v: [Disabled?, Active] (protected)
}
```

> <span class="sbnote">
**[Note: Stacked Borrows]** Stacked Borrows has no such mechanism, and the
"`&array[0] as *const _` + `ptr.add(_)`" pattern has been the cause of UB according to SB
in common crates including `rand` and `hashbrown`.
</span>

> <span class="tldr">
**[Summary]**
Tree Borrows includes some delayed initialization of permissions outside of the range
of a pointer. This permits using raw pointers outside of their initial range while
still providing aliasing guarantees on all bytes.
</span>

---

\[ [Prev](interiormut.html) | [Up](index.html) | ----------- \]

---
