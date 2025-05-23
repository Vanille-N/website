build:
  ./run/manage.sh

watch:
  watch ./run/manage.sh

push:
  rsync -rhP data/ vanille@zamok.crans.org:~/www/


