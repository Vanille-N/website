#! /bin/bash

# Build structured tree of html refs

DIR="$1"
SHORT="${DIR/www/}"
INDEX="$DIR/index-ls.html"
ROOT="$( echo "$SHORT" | sed -E 's,[a-zA-Z0-9]+,..,g ; s,^,../,' )"
: > "$INDEX"

. htmldef.sh

# Print `ls` command
echo "\
$(bold "$(green '$')") \
$(yellow "$(bold "exa") -Flah") \
$(bold "$(blue "$SHORT")") \
" >> "$INDEX"

echo "$(style "line-height:1.1")
" >> "$INDEX"

# `ls` contents
exa -lahF --color=always "$DIR" |
ansi_cvt >> "$INDEX"
sed -i '/.html/d' "$INDEX" # Filter out `index.html` + `file.txt.html` lines
# Move <underline> span inside so that it has the right color
sed -Ei 's,<span class="underline"><([^>]+)>,<\1><span class="underline">,g' "$INDEX"
# 'fi' ligature makes 'Name' too much to the left
sed -Ei "s,($(re_span "Name")), \\1," "$INDEX"

# Navigation links (.. / /share)
echo "\


$NAVIGATION

" >> "$INDEX"

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

# Insert hrefs to files & subdirs
for f in $( /bin/ls "$DIR" ); do
    # Skip html files
    if [[ "$f" =~ .*html ]]; then
        continue
    fi
    # Text file foo.bar has link to foo.bar.html which contains `bat`ed contents
    # Other files are directly linked
    sed -Ei \
        "s,($(re_span "$f")),$(href "$(getlink "$DIR" "$f")" "$(span_class "reset" '\1')")," \
        "$INDEX"
done

