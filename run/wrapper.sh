#! /usr/bin/env bash

VIRTPATH=()
virtcd() {
  local chan="$1"
  local dir="$2"
  VIRTPATH[$chan]+="$dir/"
}
virtpath() {
  local chan="$1"
  echo "${VIRTPATH[$chan]}"
}

this="$( realpath "$0" )"

virtcd in "$1"
echo "wrapper at $( virtpath in )"
ls "$( virtpath in)"

recurse() {
  "$this" "$(virtpath in)/$1"
}

copy() {
  echo "copy"
}

exec() {
  cd "$(virtpath in)"
  "$1"
  cd -
}

source "$(virtpath in)/manage"
