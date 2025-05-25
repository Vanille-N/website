TYPCFG = _src/common.typ _src/utils.typ _src/xhtml.typ _src/pona.typ
TYPFILES = $(wildcard _src/*.typ)
TYPBASE = $(TYPFILES:_src/%.typ=%)

# Custom themes (syntax highlighting, html style, rust syntax definition)
CSS = _assets/style.css

# Globally relevant files (rebuild everything on every change)
CONFIG = $(CSS) Makefile

# Build html from md
all: $(TYPFILES:_src/%.typ=%.html)

%.html: _src/%.typ $(CONFIG) $(TYPCFG)
	typst c --root . --features html --format html $< $@

watch-all:
	for line in $(TYPBASE); do \
		echo "$$line"; \
	done | \
	parallel --line-buffer \
		--tag typst watch --root . --features html --no-serve --format html _src/{}.typ {}.html

.PHONY: watch-all
