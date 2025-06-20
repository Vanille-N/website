#import "/typ2html/_src/mod.typ": html, css

#let img-link(image, url, title, size: "20") = {
  link(url, {
    html.img(src: image, width: size, height: size, title: title)
  })
}

#let github-link(base) = {
  img-link("_img/github.svg", "https://github.com/" + base, base)
}

#let email-link(base) = {
  img-link("_img/mail.svg", "", base)
}


#let url-default(url) = "https://" + url
#let url-local(url) = url
#let url-arxiv(doi) = "https://arxiv.org/abs/" + doi
