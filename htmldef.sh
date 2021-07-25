#! /bin/bash

HEADER="\
<head>
    <meta charset=\"utf-8\">
    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">
    <title>vanille :: $SHORT</title>
    <link rel=\"stylesheet\" type=\"text/css\" href=\"$ROOT/style.css\">
    <link rel=\"stylesheet\" type=\"text/css\" href=\"$ROOT/colorcodes.css\">
</head>

<body class=\"f9 b9\">
    <pre>
"

ansi_cvt() { ansi2html --bg=dark --body-only; }
span_class() { echo -n "<span class=\"$1\">$2</span>"; }
bold() { span_class 'bold' "$1"; }
yellow() { span_class 'f3' "$1"; }
green() { span_class 'f2' "$1"; }
blue() { span_class 'f4' "$1"; }

style() { echo -n "<span style=\"$1\">"; }

href() { echo -n "<a href=\"$1\">$2</a>"; }

re_span() { echo -n "(<span[^>]*>)*$1(</span>)*"; }
