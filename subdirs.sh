#! /bin/bash

for dir in $(find www/share -type d); do
    echo "# handling $dir"
    echo "$dir/index-ls.html: $(ls "$dir" | sed '/html/d' | sed "s,^,$dir/," | tr '\n' ' ')"
    echo "$dir/index-tree.html: $(find "$dir" | sed '/html/d' | tr '\n' ' ')"
    echo 
done
