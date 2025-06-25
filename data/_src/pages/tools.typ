#import "/typ2html/_src/mod.typ": html, css
#import "/_src/utils/mod.typ": global, header

#global.style("")
#header.navbar-website("tools")

A curated list of lesser-known software I strongly recommend.

#let link-generic(base) = "https://" + base
#let link-arch(base) = link-generic("wiki.archlinux.org/title/" + base)
#let link-github(base) = link-generic("github.com/" + base)
#let link-crates(base) = link-generic("crates.io/crates/" + base)

#let interpret-link(key, val) = {
  let as-url = (
    main: link-generic,
    arch: link-arch,
    github: link-github,
    crate: link-crates,
  )
  let as-icon = (
    main: "_img/generic/home.svg",
    arch: "_img/logos/arch.svg",
    github: "_img/logos/github.svg",
    crate: "_img/logos/crates.png",
  )
  html.a(href: as-url.at(key)(val), {
    html.img(src: as-icon.at(key), width: "15px", height: "15px")
  })
}

#let badge(name, img: "", what: [], links: (:)) = {
  html.div(class: "badge", {
    html.div(class: "badge-left", {
      html.img(src: "_img/" + img, width: "64px", height: "64px")
      html.div(class: "badge-title", { name })
      html.div(class: "badge-links", {
        for (key, val) in links {
          interpret-link(key, val)
        }
      })
    })
    html.div(class: "badge-right", {
      what
    })
  })
}

#css.elems((
  ".badge-grid": (
    display: "grid",
    grid-template-columns: "repeat(auto-fill, minmax(250px, 1fr))",
    gap: "0.8rem",
  ),
  ".badge": (
    background: "var(--black)",
    border-radius: "2px",
    padding: "0.7rem",
    display: "flex",
    flex-direction: "row",
    align-items: "center",
    transition: "0.2s",
    color: "var(--lt-purple)",
  ),
  ".badge:hover": (
    border-radius: "2px 2px 60px 2px",
    background: "var(--white)",
    color: "var(--black)",
  ),
  ".badge-title": (
    font-size: "1.2rem",
    font-weight: "bold",
    margin-bottom: "0.5rem",
    text-align: "center",
  ),
  ".badge-left": (
    width: "350px",
    display: "flex",
    align-items: "center",
    flex-direction: "column",
  ),
  ".badge-right": (
    flex-grow: 1,
    width: "500px",
    font-size: "10pt",
    color: "var(--black)",
    padding: "1mm",
  ),
  ".badge-links": (
    display: "flex",
    flex-wrap: "wrap",
    justify-content: "center",
    gap: "0.2rem",
  ),
  ".badge-links a": (
    background: "var(--dk-gray0)",
    padding: "0.1rem 0.5rem",
    border-radius: "8px",
    transition: "background 0.2s",
  ),
  ".badge-links a:hover": (
    background: "var(--dk-gray2)",
  ),
))

#html.div(class: "badge-grid", {
  badge([i3], img: "logos/i3.svg",
    what: [i3 is a tiling window manager,
      which means it's convenient to use without a mouse,
      it's very customizable, and it optimizes the use of screen space],
    links: (
      main: "i3wm.org",
      arch: "I3",
    ),
  )

  badge([Typst], img: "lang/typst.png",
    what: [Typst is a language that primarily compiles to PDF,
      in the style of LaTeX but better.
      This website is generated entirely in Typst!],
    links: (
      main: "typst.app",
      github: "typst/typst",
      crate: "typst",
    ),
  )

  badge([starship], img: "logos/starship.png",
    what: [Starship is a shell prompt (everything before the `$` in your terminal),
      with many customization options.],
    links: (
      main: "starship.rs",
      github: "starship/starship",
      crate: "starship",
    ),
  )

  badge([Freetube], img: "logos/freetube.png",
    what: [Freetube is an open source Youtube client.
      No ads, integrated download button, no login needed.
      Occasionally breaks when Youtube changes its API.],
    links: (
      main: "freetubeapp.io",
    ),
  )

  badge([bat], img: "logos/bat.svg",
    what: [If you find `cat` too bland when viewing source code,
      use `bat` instead. Includes line numbering and syntax highlighting.],
    links: (
      github: "sharkdp/bat",
      crate: "bat", 
    ),
  )

  badge([ripgrep], img: "logos/crates.png",
    what: [Same as `grep`, but with better defaults and excellent performance.],
    links: (
      github: "BurntSushi/ripgrep",
      crate: "ripgrep",
    ),
  )

  badge([tealdeer], img: "logos/tealdeer.png",
    what: [Short man pages with examples.
      Ideal when you forgot the arguments for `tar`
      but don't want to go through a thousand-page long `man`.],
    links: (
      github: "dbrgn/tealdeer",
      crate: "tealdeer",
    ),
  )

  badge([mpv], img: "logos/mpv.png",
    what: [Minimalist music and video player,
      with keybindings.],
    links: (
      main: "mpv.io",
      arch: "mpv",
    ),
  )

  badge([skim], img: "logos/skim.png",
    what: [Fuzzy file finder, entirely in the terminal.
      Great at filtering through large amounts of files when
      you have only a vague idea of the filename you saved them under.],
    links: (
      github: "lotabout/skim",
      crate: "skim",
    ),
  )

  badge([fd], img: "logos/crates.png",
    what: [An alternative to `find`, much easier to use.
      Perfect when you know parts of the
      name of a file and want to know its location.],
    links: (
      github: "sharkdp/fd",
      crate: "fd-find",
    ),
  )

  badge([zathura], img: "logos/zathura.png",
    what: [Zathura is a lightweight PDF viewer with vim-like bindings and integrated dark mode],
    links: (
      main: "pwmt.org/projects/zathura",
      arch: "zathura",
    ),
  )

  badge([hyperfine], img: "logos/crates.png",
    what: [A comprehensive benchmarking tool.
      Automatically handles the number of iterations,
      computes the average and standard deviation, etc.],
    links: (
      github: "sharkdp/hyperfine",
      crate: "hyperfine",
    ),
  )

  badge([tokei], img: "logos/crates.png",
    what: [Quick way to count lines of code in a project,
      broken down by language.],
    links: (
      github: "XAMPPRocky/tokei",
      crate: "tokei",
    ),
  )
})

