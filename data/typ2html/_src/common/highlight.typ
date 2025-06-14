#import "/_src/mod.typ": html, css, js

// {style:
// Concretely this expands to <link rel="stylesheet" href="_assets/global.css">
#css.include-file("_assets/global.css")
// :style}

// {highlight:
// Unpacked the archive from https://highlightjs.org/download to _highlight/
#js.external("_highlight/highlight.min.js")
#css.include-file("_highlight/styles/base16/gruvbox-dark-soft.css")

// Copied from https://www.npmjs.com/package/@myriaddreamin/highlighter-typst
// the "cjs, js bundled, wasm bundled" script
#js.external("_highlight/highlight-typst.js")

// As soon as the scripts have loaded, highlight all code blocks.
#js.inline(```js
  const run = window.$typst$parserModule.then(() => {
    hljs.registerLanguage('typst', window.hljsTypst({}));
    hljs.highlightAll();
  });
```)
// :highlight}

