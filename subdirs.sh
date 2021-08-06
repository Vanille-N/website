#! /bin/bash

# Autogen dependencies for index-ls.html and index-tree.html
#   index-ls.html depends on direct directory contents
#   index-tree.html depends on recursive subfiles

for dir in $(find www/share -type d); do
    echo "# handling $dir"
    echo "$dir/index-ls.html: $(ls "$dir" | sed '/html/d' | sed "s,^,$dir/," | tr '\n' ' ')"
    echo "$dir/index-tree.html: $(find "$dir" | sed '/html/d' | tr '\n' ' ')"
    echo 
done
