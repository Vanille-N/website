---
title: "Tree Borrows -- Introducing Protectors"
subtitle: A new aliasing model for Rust
author: Neven Villani
date: Jan. 2024
output: html_document
lang: en
---

\[ [Prev](shared.html) | [Up](index.html) | [Next](interiormut.html) \]

## Stronger aliasing constraints for function arguments

Within functions, the compiler generally knows less about the context and must
make more assumptions for useful optimizations to be possible. In particular, we
wish to be able to assume that references live until the end of the function, as
well as give reference and `Box` arguments to functions the LLVM attribute
[noalias](https://llvm.org/docs/LangRef.html#noalias), which is described as

> <span style="color:white"> noalias <br>
This indicates that memory locations accessed via pointer values based on the
argument are not also accessed, during the execution of the function, via
pointer values not based on the argument. This guarantee only holds for memory
locations that are modified, by any means, during the execution of the function.
</span>

Or in the language of Tree Borrows:

- a pointer based on the argument is a child pointer,
- a pointer not based on the argument is a foreign pointer,
- `noalias` requires that locations that are written to are not accessed through
  both foreign and child pointers,
- once the function has returned, this constraint is lifted.

To enforce this we add a notion of _protectors_: on function entry, each
reference or `Box` argument gets added a protector. This protector is removed on
function exit. As long as a protector is in place, the reference or `Box` must
adhere to additional rules, namely it must satisfy the requirements of
`noalias`. Additionally, references (but not `Box`) must be valid until the end
of the function.

## Required additions

### References should be dereferenceable for the entire function

References (both mutable and shared) must be at least readable for the entire
execution of the function. In Tree Borrows terms, this means that it must be UB
for any protected pointer to become `Disabled`, since `Disabled` means that the
pointer is not even readable anymore.

This aligns with the `noalias` requirements in that it prevents foreign writes
(foreign writes are what cause pointers to become `Disabled`) to locations that
have been read from, and it additionally allows using the `dereferenceable`
attribute on reference function arguments.

### `Box`es should be dereferencable until the function deallocates them

`Box<T>` must be at least readable unless and until the function `free`s its
backing allocation. In Tree Borrows terms this also means that it must be UB for
any protected `Box` to become `Disabled`.

This aligns with the `noalias` requirements in that it prevents foreign writes
to locations that have been read from, but it does *not* allow using the
`dereferencable` attribute (as a deallocated `Box` is no longer dereferencable).

### Child writes are incompatible with foreign reads

Detecting this takes two forms:

- if the child write occurs first, then a subsequent foreign read will cause an
  `Active` pointer to experience a foreign read. To make this UB, we declare
  that a protected `Active`'s behavior to foreign reads changes to become
  immediately `Disabled`, which will trigger the protector.
- if the foreign read occurs first, then it means that the protected pointer is
  still `Reserved` at that point. When a protected `Reserved` encounters a
  foreign read, it must not allow future child writes until at least the end of
  this function call. We model this by adding a boolean flag `conflicted` to
  `Reserved` that is initially `false`, becomes `true` if the tag is protected
  while a foreign read occurs, and triggers UB if it is `true` while the tag is
  still protected if we try to perform a foreign write.

> <span class="sbnote">
**[Note: Stacked Borrows]** This mostly aligns with the concept of protectors
from Stacked Borrows, except that in SB loss of permissions is indicated by
being popped from the stack, whereas in TB it takes the form of becoming
`Disabled`. Thus what triggers protectors in SB is popping a protected item, in
TB it is performing an invalid transition.
</span>

> <span class="tldr">
**[Summary]** A pointer passed as reference or `Box` argument to a function is
protected until the end of the function call. Protected pointers behave slightly
differently to add more guarantees:
<ul><li>Any protected pointer that becomes `Disabled` is UB (this includes all
three of `Reserved`, `Active`, and `Frozen` reacting to a foreign write, as well
as `Active` to a foreign read);</li>
<li>Protected `Reserved` pointers are not unchanged by foreign reads: an
internal `conflicted` flag is set that will temporarily forbid
activation.</li></ul>
</span>

### Protected tags emit an implicit read on function exit

The protector guarantees that at the end of the function call the pointer is
still readable. By inserting an implicit read on function exit, we make the
protector announce its presence, which will make other protected tags existing
at the same time experience a foreign read that will prevent their activation.

We do not apply this implicit read to children of the tag that just lost its
protector, this is only for foreign tags.

For `Box` protectors only, this implicit read is omitted if the `Box` was
deallocated during the execution of the function.

## New possible optimizations

With the addition of protectors, it is still possible to reorder accesses across
unknown code to move them towards a stronger access (a read towards a read, a
read towards a write, or a write towards a write). In addition there are now new
optimizations that are possible, but only in the presence of a protected
pointer.

### Delayed accesses

Since protected pointers can be assumed to be valid until the end of the
function, it is possible to delay an access to occur after arbitrary code, as
long as said arbitrary code does not own any child pointers.

```rs
extern fn opaque();

//? Unoptimized
fn convoluted_read(u: &u8) -> u8 {
    // u: Frozen
    let uval = *u;
    opaque();
    // If any write occured during `opaque` then `u` became `Disabled`
    // which is `UB` because `u` is protected. We can thus assume that `opaque`
    // does not write to the location of `u`.
    uval
}

//? Optimized
fn convoluted_read_opt(u: &u8) -> u8 {
    opaque();
    *u // One fewer local variable thanks to being able to assume that `*u` is unchanged
}
```

```rs
extern fn opaque();

//? Unoptimized
fn convoluted_write(u: &mut u8) -> u8 {
    // u: Reserved
    *u = 42;
    opaque();
    // If any read occured during `opaque` then `u` became `Frozen`
    // which is `UB` because `u` is protected. We can thus assume that `opaque`
    // does not read from the location of `u`.
    *u
}

//? Optimized
fn convoluted_write_opt(u: &mut u8) -> u8 {
    opaque();
    *u = 42;
    42
}
```


### Anticipated reads

Since references can be assumed to be dereferenceable on function entry,
we can also move read accesses up, even if they possibly never actually happen.

```rust
//? Unoptimized
fn iter_until(arg: &u8) {
    while condition() {
        // We can assume that
        // 1. `condition` and `step` do not modify `*arg`
        // 2. `arg` is dereferenceable even if `condition` does not terminate
        // 3. `arg` is dereferenceable even if the loop runs zero times
        step(*arg);
    }
}

//? Optimized
fn iter_until_opt(arg: &u8) -> u8 {
    let varg = *arg;
    while condition() {
        step(varg); // Removed the dereference
    }
}
```

### [Not always possible] Anticipated writes

However, if the function is not guaranteed to write (either because some code
might not terminate or because the write is conditional), then Tree Borrows does
not allow anticipated writes.

An example from [this thread](https://rust-lang.zulipchat.com/#narrow/stream/136281-t-opsem/topic/can.20.26mut.20just.20always.20be.20two-phase/near/307569740)
is not supported by Tree Borrows:

```rust
//? Unoptimized
pub fn foo(x: &mut u8, n: u8) {
    for i in 0..n {
        *x = i;
    }
}

//- Incorrectly optimized
pub fn foo_opt_invalid(x: &mut u8, n: u8) {
    let val = *x;
    // This optimization assumes that `x` is writeable, which was not necessarily
    // the case in the unoptimized version when `n == 0`.
    *x = n - 1;
    if unlikely(n == 0) {
        *x = val;
    }
}
```

More generally, writing to the location then later reverting the write still
counts as a write access and could introduce new UB to the program.

> <span class="sbnote">
**[Note: Stacked Borrows]** This is a loss of potential optimization compared to
Stacked Borrows, which does allow spurious writes, but it is necessary if we
want the previous `copy_nonoverlapping` example to be allowed.
</span>


---

\[ [Prev](shared.html) | [Up](index.html) | [Next](interiormut.html) \]

---
