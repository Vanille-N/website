// This is a trick to declare content at most once.
// We use `state` to store the elements that were already declared,
// so that we know which ones not to include twice.
#let declared = state("declared", (:))
#let once(label, content) = {
  context {
    let decls = declared.get()
    if not decls.at(label, default: false) {
      // Run this code only if not declared yet.
      content // Declare.
      declared.update(decls => {
        decls.insert(label, true) // Record in the state as declared.
        decls
      })
    }
  }
}

