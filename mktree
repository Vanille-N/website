#! /bin/bash

# Build structured tree of html refs

DIR="$1"
SHORT="${DIR/www/}"
INDEX="$DIR/index-tree.html"
ROOT="$( echo "$SHORT" | sed -E 's,[a-zA-Z0-9]+,..,g ; s,^,../,' )"
: > "$INDEX"

. htmldef.sh

getlink() {
    local link
    case "$(file "$1/$2")" in
        (*text*|*Unicode*|*ASCII*)
            link="$f.html"
            ;;
        (*directory*)
            link="$f/index.html"
            ;;
        (*)
            link="$f"
            ;;
    esac
    echo -n "$link"
}

# Show `tree` command
echo "\
$(bold "$(green '$')") $(yellow "$(bold "tree") -Ca") $(bold "$(blue "$SHORT")")
" >> "$INDEX"

style "line-height:1" >> "$INDEX"

# Write `tree` contents
cd www
tree -aC "${DIR/www\//}" -I '*html' |
sed 's,share,/share,' |
ansi_cvt >> "${INDEX/www\//}"
cd -

# Insert hrefs in tree
for f in $(
    cd "$DIR" &>/dev/null;
    find . -not -name '*.html';
    cd - &>/dev/null
); do
    if [[ "$f" = '.' ]]; then
        continue
    fi
    sed -Ei \
        "0,/─.*$(basename "$f")/s,─ ($(re_span "$(basename "$f")")),─ $(href "$(getlink "$DIR" "$f")" "$(span_class "reset" "\1")")," \
        "$INDEX"
done

echo "\

$(style "font-size:85%")
" >> "$INDEX"

cat "$DIR/extra.html" 2>/dev/null >> "$INDEX"

echo "\
</span>
" >> "$INDEX"
