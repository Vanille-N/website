CFG = Makefile htmldef.sh
all: sync

sync: share
	remote send zamok www/ www

share:
	./make sharebuild
	./make sharefiles
	./make sharestruct

SHARE = $(shell find www/share -type d | tac)
sharestruct:
	@for f in $(SHARE); do \
		./make $$f/index-ls.html; \
		./make $$f/index-tree.html; \
		./make $$f/index.html; \
	done

FILES = $(shell find www/share -type f -not -name '*.html' | tac)
sharefiles: $(FILES:%=%.html)

subdirs.mk: $(FILES) Makefile subdirs.sh
	./subdirs.sh > $@

include subdirs.mk
%/index.html: %/index-ls.html %/index-tree.html %/extra.html struct.sh $(CFG)
	./struct.sh $(shell dirname $@)

%/index-ls.html: ls.sh $(CFG)
	./ls.sh $(shell dirname $@)

%/index-tree.html: tree.sh $(CFG)
	./tree.sh $(shell dirname $@)

%.html: % bat.sh $(CFG)
	./bat.sh $<

clean:
	find www/share \
		-name '*.html' \
		-and -not -name 'extra.html' \
		-exec rm {} +
	rm -f subdirs.mk share-update.mk

force:
	make clean
	make

.PHONY: sync share sharestruct sharefiles clean

include share-update.mk
share-update.mk: sharelist sync.sh
	./sync.sh > $@
