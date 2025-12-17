#import "/typ2html/_src/mod.typ": html, css

#let img-link(image, url, title, size: "20") = {
  link(url, {
    html.img(src: image, width: size, height: size, title: title)
  })
}

#let github-link(base, size: "20") = {
  img-link("_img/logos/github.svg", "https://github.com/" + base, base, size: size)
}

#let email-link(type: none, base, size: "20") = {
  let title = if type == none {
    base
  } else {
    type + ": " + base
  }
  img-link("_img/generic/mail.svg", "mailto:"+base, title, size: size)
}

#let url-default(url) = "https://" + url
#let url-local(url) = url
#let url-arxiv(doi) = "https://arxiv.org/abs/" + doi
#let url-github(path) = "https://github.com/" + path
