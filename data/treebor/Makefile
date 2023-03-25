MDFILES = $(wildcard src/*.md)
HLTHEME = conf/hl.theme
CSS = conf/style.css
SYN = conf/rust.xml
CONFIG = $(HLTHEME) $(CSS) $(SYN) Makefile

all: $(MDFILES:src/%.md=.target/%.html)

.target:
	mkdir -p $@

.target/%.html: src/%.md $(CONFIG) |.target
	pandoc \
		--syntax-definition $(SYN) \
		--highlight-style $(HLTHEME) \
		--embed-resources --standalone \
		-f markdown -t html \
		$< -o $@ \
		-H $(CSS)

clean:
	fd --unrestricted .target | xargs rm -rf

.PHONY: clean
