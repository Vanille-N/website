MDFILES = $(wildcard src/*.md)
HLTHEME = conf/hl.theme
CSS = conf/style.css
SYN = conf/rust.xml
CONFIG = $(HLTHEME) $(CSS) $(SYN) Makefile

all: $(MDFILES:src/%.md=%.html)

%.html: src/%.md $(CONFIG)
	pandoc \
		--syntax-definition $(SYN) \
		--highlight-style $(HLTHEME) \
		--embed-resources --standalone \
		-f markdown -t html \
		$< -o $@ \
		-H $(CSS)

push:
	make all
	cd ../../ && make

edit:
	rg '[a-z]+.html' src/index.md --only-matching | \
		sed 's,html,md,' | \
		sed 's,^,src/,' | \
		xargs -o vim src/index.md

show-fix:
	rg 'FIXME' src/

fix:
	rg 'FIXME' --files-with-matches src/ | \
		xargs -o vim '+/FIXME'

.PHONY: clean push edit fix
