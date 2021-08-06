CFG = Makefile htmldef.sh

all: sync

sync: sharestruct
	remote send zamok www/ www

share: sharestruct sharefiles

SHARE = $(shell find www/share -type d)
sharestruct: $(SHARE:%=%/index.html) \
	$(SHARE:%=%/index-tree.html) \
	$(SHARE:%=%/index-ls.html)

FILES = $(shell find www/share -type f -not -name '*.html')
sharefiles: $(FILES:%=%.html)

#subdirs.mk: $(FILES) Makefile
#	: > subdirs.mk
#	for d in $$(find www/share -type d); do\
#		echo "$$d/index.html: $$(find $$d/ | tr '\n' ' ')" >> subdirs.mk; \
#	done

#include subdirs.mk
%/index.html: % %/index-ls.html %/index-tree.html struct.sh $(CFG)
	./struct.sh $<

%/index-ls.html: % $(FILES) ls.sh $(CFG)
	./ls.sh $<

%/index-tree.html: % $(SHARE) tree.sh $(CFG)
	./tree.sh $<

%.html: % bat.sh $(CFG)
	./bat.sh $<

clean:
	find www/share \
		-name '*.html' \
		-and -not -name 'extra.html' \
		-exec rm {} +

.PHONY: sync share sharestruct sharefiles clean

include share-update.mk
share-update.mk: sharelist sync.sh
	./sync.sh > $@
