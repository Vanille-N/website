# Manager for the treebor blog

# Markdown sources
MDFILES = $(wildcard src/*.md)

# Custom themes (syntax highlighting, html style, rust syntax definition)
HLTHEME = conf/hl.theme
CSS = conf/style.css
SYN = conf/rust.xml

# Figures (embedded but still dependencies)
FIGS = $(wildcard figs/*)

# Globally relevant files (rebuild everything on every change)
CONFIG = $(HLTHEME) $(CSS) $(SYN) Makefile $(FIGS)

# Build html from md
all: $(MDFILES:src/%.md=.target/%.html) .target/aux

.target:
	mkdir -p $@

.target/aux: aux/*
	rm -rf .target/aux
	cp -r aux .target/aux

.target/%.html: src/%.md $(CONFIG) |.target
	pandoc \
		--syntax-definition $(SYN) \
		--highlight-style $(HLTHEME) \
		--embed-resources --standalone \
		-f markdown -t html \
		$< -o $@ \
		-H $(CSS)

# Clean
clean:
	fd --unrestricted .target | xargs rm -rf

.PHONY: clean
