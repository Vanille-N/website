#! /bin/bash

# Configuration & wrappers for mkbat + mkstruct

# Header: title, stylesheet, color codes, open ANSI block
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

# Wrapper around ansi2html for uniformized conversion
# --body-only: header is in www/colorcodes.css
ansi_cvt() {
    ansi2html --bg=dark --body-only 2>/tmp/ansi2html.log
}

# Safe manual ANSI formatting
span_class() { echo -n "<span class=\"$1\">$2</span>"; }
bold() { span_class 'bold' "$1"; }
yellow() { span_class 'f3' "$1"; }
green() { span_class 'f2' "$1"; }
blue() { span_class 'f4' "$1"; }

# Some  more html wrappers
style() { echo -n "<span style=\"$1\">"; }
href() { echo -n "<a href=\"$1\">$2</a>"; }

# Regex to select an item _and_ all formatting around
re_span() { echo -n "(<span[^>]*>)*$1(</span>)*"; }

# links:  .  ..  /  /share
NAVIGATION="\
$(style "line-height:1.1")\
     $(href "./index.html" "$(blue "$(bold ".")")")\
          $(href "../index.html" "$(blue "$(bold "..")")")\
          $(href "$ROOT/index.html" "$(blue "$(bold "/")")")\
          $(href "$ROOT/share/index.html" "$(blue "$(bold "/share")")")\
</span>"

# Footer: ref to github, close ANSI block
FOOTER="\
$(style "font-size:70%")
Powered by $(href "https://github.com/Vanille-N/website" 'Vanille-N/website')
</span></pre></body>
"
