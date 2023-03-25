#! /bin/bash -i

. run/pics.sh

from /home/nash/my/Documents/Pictures
into /home/nash/my/School/Crans/perso/www/pics

from++ espoo-2022
  into++ finland
    ###   February   ###
    into++ Feb
      for name in bath-1 bath-2 bay grass island path sea sign; do
        img 5 jpg "18-${name}" "2022-02-18_${name}"
      done
      img 2 jpg "18-panorama" "2022-02-18_panorama"
      for name in beakers bird forest island lake small snow spider tree; do
        img 5 jpg "19-${name}" "2022-02-19_${name}"
      done
      for name in 20_dawn 22_snow 23_cs-building 23_espoo-skyline 23_skiers 26_trees 28_night; do
        img 5 jpg "${name/_/-}" "2022-02-${name}"
      done
      img 2 jpg "22-panorama-tapiola" "2022-02-22_panorama-tapiola"
    into-- Feb
    tar Feb
    ###   March   ###
    into++ Mar
      for name in 04_elevator 06_ducks 09_forbidden; do
        img 5 jpg "${name/_/-}" "2022-03-${name}"
      done
    into-- Mar
    tar Mar
    ###   April   ###
    into++ Apr
      for name in 01_linus 01_park 01_streets 01_tram 05_fog 12_grass 13_forest 13_plants 14_geese 19_delivery; do
        img 5 jpg "${name/_/-}" "2022-04-${name}"
      done
      for name in bunker bunkers-2 cannon capitol-crowd carriage-cap-wide-2 carriage-cap \
                  crane-confetti crane-low crane-wide crane crowd-1 crowd-2 crowd-3 crowd-4 crowd-after \
                  guns lake launcher-1 map-1 medals pavillon pier plaza-crowd-1 \
                  plaza-empty stalin statue-after statue-before stone-gate tank-1; do
        img 5 jpg "30-${name}" "2022-04-30_${name}"
      done
      img 4 jpg "30-plaza-crowd-3" "2022-04-30_plaza-crowd-3"
    into-- Apr
    tar Apr
    into++ May
      for name in harbor-1 picnic-caps; do
        img 5 jpg "01-${name}" "2022-05-01_${name}"
      done
      for name in 08_leaves 12_flowers 27_plants-2; do
        img 5 jpg "${name/_/-}" "2022-05-${name}"
      done
    into-- May
    tar May
    into++ Jun
      for name in cathedral church library painting-cloud plaza-tanks \
                  plaza-tanks-2 sculpture-plastic staircase tank-1 tanks-close \
                  trucks-close tubes; do
        img 5 jpg "03-${name}" "2022-06-03_${name}"
      done
      for name in band lined-up plaza-complete plaza-tanks-behind; do
        img 5 jpg "04-${name}" "2022-06-04_${name}"
      done
      for num in {1..6}; do
        img 5 jpg "04-march-${num}" "2022-06-04_march-${num}"
      done
      for name in forest-panorama lake-1 lake-2 lake-3 path plank trees-sky; do
        img 5 jpg "05-${name}" "2022-06-05_${name}"
      done
    into-- Jun
    tar Jun
  into-- finland
from-- espoo-2022

close
