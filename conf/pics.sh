#! /bin/bash -i

. run/pics.sh

from /home/vanille/Documents/Pictures
into /home/vanille/School/Crans/perso/www/pics

from++ espoo-2022
  into++ finland
    into++ Feb
      for name in bath-1 bath-2 bay grass island path sea sign; do
          img 5 jpg "18-${name}" "2022-02-18_${name}"
      done
      img 2 jpg "18-panorama" "2022-02-18_panorama"
      for name in beakers bird forest island lake small snow spider tree; do
          img 5 jpg "19-${name}" "2022-02-19_${name}"
      done
    into-- Feb
    tar Feb
  into-- finland
from-- espoo-2022

close
