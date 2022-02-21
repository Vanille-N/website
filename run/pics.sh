#! /bin/bash

TARS=()

TARGET=pics.mk

. run/macros-struct.sh

img() {
    local size="$1"
    local ext="$2"
    local i="$3.$ext"
    local f="$4.$ext"
    local pfrom="$( path "${FROM[@]}" )"
    local pinto="$( path "${INTO[@]}" )"
    #mkdir -p "$pinto"
    echo "linking '$pinto/$i' to '$pfrom/$f'"
    build "$pinto/$i: $pfrom/$f |$pinto"
    build "\tcp '\$<' '\$@'"
    build "$pinto/mini-$i: $pinto/$i"
    build "\tconvert '\$<' -resize '$size%' '\$@'"
    RULES+=( "$pinto/mini-$i" )
}

tar() {
    local f="$1"
    local p="$( path "${INTO[@]}" )"
    build "$p/$f.tar: $p/$f"
    build "\trm -f '\$@'"
    build "\t/usr/bin/tar -cf '\$@' --exclude='*/mini-*' '\$<'"
    TARS+=( "$p/$f.tar" )
}

close() {
    build "pics.main: \\"
    for rule in "${RULES[@]}"; do
        build "\t$rule \\"
    done
    build "#"
    build "pics.tars: \\"
    for rule in "${TARS[@]}"; do
        build "\t$rule \\"
    done
    build "#"
    build ".PHONY: pics.main pics.tars \\"
    for rule in "${PHONY[@]}"; do
        build "\t$rule \\"
    done
    build "#"
}


