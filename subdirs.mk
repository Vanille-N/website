# handling www/share
www/share/index-ls.html: www/share/config www/share/satge www/share/util 
www/share/index-tree.html: www/share www/share/util www/share/util/opn www/share/util/opn/opn-core www/share/util/opn/opn-wrap www/share/util/texwatch www/share/util/pdfcat www/share/config www/share/config/zathurarc www/share/config/starship.toml www/share/config/setup.txt www/share/config/kitty www/share/config/kitty/kitty.conf www/share/config/kitty/theme.conf www/share/satge www/share/satge/beamer.pdf www/share/satge/report.pdf 

# handling www/share/util
www/share/util/index-ls.html: www/share/util/opn www/share/util/pdfcat www/share/util/texwatch 
www/share/util/index-tree.html: www/share/util www/share/util/opn www/share/util/opn/opn-core www/share/util/opn/opn-wrap www/share/util/texwatch www/share/util/pdfcat 

# handling www/share/util/opn
www/share/util/opn/index-ls.html: www/share/util/opn/opn-core www/share/util/opn/opn-wrap 
www/share/util/opn/index-tree.html: www/share/util/opn www/share/util/opn/opn-core www/share/util/opn/opn-wrap 

# handling www/share/config
www/share/config/index-ls.html: www/share/config/kitty www/share/config/setup.txt www/share/config/starship.toml www/share/config/zathurarc 
www/share/config/index-tree.html: www/share/config www/share/config/zathurarc www/share/config/starship.toml www/share/config/setup.txt www/share/config/kitty www/share/config/kitty/kitty.conf www/share/config/kitty/theme.conf 

# handling www/share/config/kitty
www/share/config/kitty/index-ls.html: www/share/config/kitty/kitty.conf www/share/config/kitty/theme.conf 
www/share/config/kitty/index-tree.html: www/share/config/kitty www/share/config/kitty/kitty.conf www/share/config/kitty/theme.conf 

# handling www/share/satge
www/share/satge/index-ls.html: www/share/satge/beamer.pdf www/share/satge/report.pdf 
www/share/satge/index-tree.html: www/share/satge www/share/satge/beamer.pdf www/share/satge/report.pdf 

