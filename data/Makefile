# Manager for the treebor blog

# Markdown sources
MDFILES = $(wildcard _src/*.md)

# Custom themes (syntax highlighting, html style, rust syntax definition)
CSS = style.css

# Figures (embedded but still dependencies)
FIGS = $(wildcard figs/*)

# Globally relevant files (rebuild everything on every change)
CONFIG = $(HLTHEME) $(CSS) Makefile $(FIGS)

# Build html from md
all: $(MDFILES:_src/%.md=%.html)

%.html: _src/%.md $(CONFIG)
	pandoc \
		--embed-resources --standalone \
		-f markdown -t html \
		$< -o $@ \
		-H $(CSS)

