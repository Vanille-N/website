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
all: $(MDFILES:src/%.md=%.html)

%.html: src/%.md $(CONFIG)
	pandoc \
		--syntax-definition $(SYN) \
		--highlight-style $(HLTHEME) \
		--embed-resources --standalone \
		-f markdown -t html \
		$< -o $@ \
		-H $(CSS)

