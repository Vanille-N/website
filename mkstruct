#! /bin/bash

# Build structured tree of html refs

DIR="$1"
SHORT="${DIR/www/}"
INDEX="$DIR/index.html"
INDEX_LS="$DIR/index-ls.html"
INDEX_TREE="$DIR/index-tree.html"
ROOT="$( echo "$SHORT" | sed -E 's,[a-zA-Z0-9]+,..,g ; s,^,../,' )"
: > "$INDEX"

. htmldef.sh
echo "$HEADER" >> "$INDEX"
cat "$INDEX_LS" <(echo) "$INDEX_TREE" >> "$INDEX"

echo "\

$FOOTER" >> "$INDEX"
