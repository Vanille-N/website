#! /bin/bash

# Colorful display of text files

FILE="$1"
SHORT="${FILE/www/}"
HTML="$FILE.html"
ROOT="$( dirname "$SHORT" | sed -E 's,[a-zA-Z0-9]+,..,g ; s,^,../,' )"
: > "$HTML"

. htmldef.sh
echo "$HEADER" >> "$HTML"

# Print `bat` command
echo "\
$(bold "$(green '$')") $(yellow "$(bold "bat")") $(bold "$(blue "$SHORT")")
" >> "$HTML"

style "font-size:75%; line-height:1.1" >> "$HTML"

bat --style=grid --color=always "$FILE" |
ansi_cvt >> "$HTML"

echo "\
</span></span>
$NAVIGATION

$FOOTER" >> "$HTML"