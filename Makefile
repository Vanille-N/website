CFG = Makefile run/htmldef.sh

MAKE = run/make
all: sync

sync: share pics
	remote push zamok www/ www

share:
	$(MAKE) sync.main
	#$(MAKE) sharebuild
	$(MAKE) sharefiles
	$(MAKE) sharestruct

pics:
	$(MAKE) sync.main
	#$(MAKE) sharebuild
	$(MAKE) sharefiles
	$(MAKE) pics.main
	$(MAKE) pics.tars

SHARE = $(shell find www/share -type d | tac)
sharestruct:
	@for f in $(SHARE); do \
		$(MAKE) $$f/index-ls.html; \
		$(MAKE) $$f/index-tree.html; \
		$(MAKE) $$f/index.html; \
	done

pics.mk: conf/pics.sh run/pics.sh run/macros-struct.sh
	conf/pics.sh
include pics.mk

sync.mk: conf/sync.sh run/macros-sync.sh run/macros-struct.sh
	conf/sync.sh
include sync.mk


FILES = $(shell find www/share -type f -not -name '*.html' | tac)
sharefiles: $(FILES:%=%.html)

subdirs.mk: $(FILES) Makefile run/subdirs.sh
	run/subdirs.sh > $@

include subdirs.mk
%/extra.html:
	touch $@
%/index.html: %/index-ls.html %/index-tree.html %/extra.html run/struct.sh $(CFG)
	run/struct.sh $(shell dirname $@)

%/index-ls.html: run/ls.sh $(CFG)
	run/ls.sh $(shell dirname $@)

%/index-tree.html: run/tree.sh $(CFG)
	run/tree.sh $(shell dirname $@)

%.html: % run/bat.sh $(CFG)
	run/bat.sh $<

clean:
	rm -rf www/share/*
	find www/pics \
		-name '*.jpg' \
		-exec rm {} +
	find www/pics \
		-name '*.tar' \
		-exec rm {} +
	rm -f subdirs.mk share-update.mk

force:
	make clean
	make

.PHONY: sync share sharestruct sharefiles clean pictures archives

#include share-update.mk
#share-update.mk: sharelist run/sync.sh
#	run/sync.sh > $@
