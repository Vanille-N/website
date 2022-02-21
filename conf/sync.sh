#! /bin/bash -i

. run/macros-sync.sh

from '/home/vanille'
into '/home/vanille/School/Crans/perso/www/share'

into++ 'util'
  from++ bin
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
    link bat 'pdfcat' pdfcat
    link bat 'texwatch' texwatch
  from-- bin
into-- util

into++ 'satge'
  from++ School/L3/dynamic-udg/redac
    link raw 'beamer.pdf' beamer/main.pdf
    link raw 'report.pdf' report/main.pdf
  from-- School/L3/dynamic-udg/redac
into-- satge

into++ 'config'
  from++ .env
    link bat 'alacritty.yml' alacritty/alacritty.yml
    link bat 'starship.toml' starship.toml
    link bat 'zathurarc' zathura/zathurarc
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

close
