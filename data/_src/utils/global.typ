#import "/_src/lib/mod.typ": xhtml, css
#import "pona.typ"

#let style(prefix) = {
  // Color definitions
  css.elem(":root", (
    "--black": "#1d2021",
    "--dk-gray0": "#282828",
    "--dk-gray1": "#3c3836",
    "--dk-gray2": "#504945",
    "--dk-gray3": "#665c54",
    "--dk-gray4": "#7c6f64",
    "--gray": "#928374",
    "--white": "#fbf1c7",
    "--lt-gray0": "#ebdbb2",
    "--lt-gray1": "#d5c4a1",
    "--lt-gray2": "#bdae93",
    "--lt-gray3": "#a89984",
    "--dk-red": "#cc241d",
    "--dk-green": "#98971a",
    "--dk-yellow": "#d79921",
    "--dk-blue": "#458588",
    "--dk-purple": "#b16286",
    "--dk-aqua": "#689d6a",
    "--dk-orange": "#d65d0e",
    "--lt-red": "#fb4934",
    "--lt-green": "#b8bb26",
    "--lt-yellow": "#fabd2f",
    "--lt-blue": "#83a598",
    "--lt-purple": "#d3869b",
    "--lt-aqua": "#8ec07c",
    "--lt-orange": "#fe8019",
  ))
  // Global configuration
  css.elems((
    html: (
      background-color: "var(--black)",
    ),
    body: (
      margin: "40px auto",
      max-width: "1200px",
      line-height: 1.5,
      font-size: "18px",
      font-weight: 350,
      color: "#fbf1c7",
      background: "var(--dk-gray0)",
      padding: "5mm 10px 10cm 10px",
    ),
    "h1,h2,h3": (
      line-weight: 1.2,
      color: "var(--lt-green)",
    ),
    h1: ( font-weight: 800 ),
    h2: ( font-weight: 700 ),
    h3: ( font-weight: 600 ),
    a: ( color: "var(--dk-aqua)" ),
    "a:visited": ( color: "var(--lt-purple)" ),
  ))
  // TODO: migrate this
  xhtml.link(rel: "stylesheet", href: prefix + "_assets/pona.css")
  // Navigation bar
  css.elems((
    ".topnav": (
      background-color: "var(--dk-gray1)",
      overflow: "hidden",
      border-radius: "10px",
    ),
    ".topnav a": (
      float: "left",
      color: "var(--dk-green)",
      text-align: "center",
      padding: "14px 16px",
      text-decoration: "none",
      font-size: "17px",
      border: "1px solid var(--black)",
    ),
    ".topnav a:hover": (
      background-color: "var(--dk-gray2)",
      color: "var(--lt-green)",
      transition: "0.2s",
    ),
    ".topnav a.active": (
      background-color: "var(--lt-green)",
      color: "var(--black)",
    ),
  ))
  // "Under construction" banner
  // TODO: phase it out
  css.elems((
    ".alert": (
      background-color: "var(--lt-red)",
      text-align: "center",
      color: "var(--black)",
      padding: "7px",
    )
  ))
}

