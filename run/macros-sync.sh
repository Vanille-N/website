#! /bin/bash

TARGET=sync.mk

. run/macros-struct.sh

link() {
    local mode="$1"
    local i="$2"
    local f="$3"
    local pinto="$( path "${INTO[@]}" )"
    local pfrom="$( path "${FROM[@]}" )"
    echo "linking '$pinto/$i' to '$pfrom/$f'"
    build "$pinto/$i: $pfrom/$f |$pinto"
    build "\tcp '\$<' '\$@'"
    RULES+=( "$pinto/$i" )
    if [ $mode == 'bat' ]; then
        build "$pinto/$i.html: $pinto/$i"
        build "\trun/bat.sh '\$<'"
        RULES+=( "$pinto/$i.html" )
    fi
}

close() {
    build "sync.main: \\"
    for rule in "${RULES[@]}"; do
        build "\t$rule \\"
    done
    build "#"
    build ".PHONY: sync.main \\"
    for rule in "${PHONY[@]}"; do
        build "\t$rule \\"
    done
    build "#"
}

extra() {
    local dir="$( path "${INTO[@]}" )"
    echo "$1" >> "$dir/extra.html"
    echo "printing to $dir/extra.html"
}
