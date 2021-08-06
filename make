#! /bin/bash

make "$1" |
grep -v --line-buffered 'make\[.*up to date' |
grep -v --line-buffered 'Entering' |
grep -v --line-buffered 'Leaving' || true
