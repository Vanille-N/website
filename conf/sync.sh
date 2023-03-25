#! /bin/bash -i

. run/macros-sync.sh

from '/home/nash'
into '/home/nash/my/School/Crans/perso/www/share'

into++ 'util'
  from++ .bin
    into++ 'opn'
      link bat 'opn-core' opn-core
      link bat 'opn-wrap' opn-wrap
      extra '<code>opn</code> is an easily customizable skeleton for an <code>xdg-open</code>'
      extra 'equivalent.'
      extra ''
      extra '<code>opn-core</code> is the key component which routes files to programs depending'
      extra 'on their mimetypes.'
      extra ''
      extra 'To add a new type or change the associated program, simply create a new line in the'
      extra '<code>case</code> block.'
    into-- opn
    #link bat 'pdfcat' pdfcat
    #link bat 'texwatch' texwatch
  from-- .bin
into-- util

from++ 'my'
  into++ 'satge'
    into++ 'l3'
      from++ School/L3/dynamic-udg/redac
        link raw 'beamer.pdf' beamer/main.pdf
        link raw 'report.pdf' report/main.pdf
      from-- School/L3/dynamic-udg/redac
    into-- l3
    into++ 'm1'
      from++ School/M1/mending_volume
        link raw 'beamer.pdf' 3-BEAMER/main.pdf
        link raw 'paper.pdf' 1-arxiv/main.pdf
      from-- School/M1/mending_volume
    into-- m1
  into-- satge

  into++ 'config'
    from++ .env
      #ink bat 'alacritty.yml' alacritty/alacritty.yml
      #ink bat 'starship.toml' starship.toml
      #link bat 'zathurarc' zathura/zathurarc
    from-- .env
  into-- config

  into++ 'compverif'
    from++ School/M1/Compiling
      link raw 'report.pdf' report/main.pdf
      link raw 'beamer.pdf' presentation/main.pdf
    from-- School/M1/Compiling
  into-- compverif

  into++ 'categories'
    link raw 'beamer.pdf' School/M1/rustbelt/main.pdf
  into-- categories

  into++ 'crans'
    link raw 'bilantech-23.pdf' School/Crans/bilantech-23/bilan.pdf
  into-- crans
from-- my

close
