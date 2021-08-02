CFG = Makefile htmldef.sh

all: sync

sync: sharestruct
	remote send zamok www/ www

share: sharestruct sharefiles

SHARE = $(shell find www/share -type d)
sharestruct: $(SHARE:%=%/index.html)

FILES = $(shell find www/share -type f -not -name '*.html')
sharefiles: $(FILES:%=%.html)

#subdirs.mk: $(FILES) Makefile
#	: > subdirs.mk
#	for d in $$(find www/share -type d); do\
#		echo "$$d/index.html: $$(find $$d/ | tr '\n' ' ')" >> subdirs.mk; \
#	done

#include subdirs.mk
%/index.html: % %/index-ls.html %/index-tree.html mkstruct $(CFG)
	./mkstruct $<

%/index-ls.html: % $(FILES) mkls $(CFG)
	./mkls $<

%/index-tree.html: % $(SHARE) mktree $(CFG)
	./mktree $<

%.html: % mkbat $(CFG)
	./mkbat $<

clean:
	find www/share \
		-name '*.html' \
		-and -not -name 'extra.html' \
		-exec rm {} +

.PHONY: sync share sharestruct sharefiles clean
