#! /usr/bin/env bash

recurse() {
  pushd "$1"
  source manage
  popd
}

recurse data
