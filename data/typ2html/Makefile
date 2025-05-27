TYPFILES = $(wildcard _src/*.typ)
TYPCFG = _src/xhtml.typ _src/excerpt.typ _src/css.typ

# Globally relevant files (rebuild everything on every change)
CONFIG = Makefile

all: $(TYPFILES:_src/%.typ=%.html)

%.html: _src/%.typ $(CONFIG) $(TYPCFG)
	typst c --root . --features html --format html $< $@

