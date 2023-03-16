MDFILES = $(wildcard *.md)

all: $(MDFILES:.md=.html)

%.html: %.md style.css Makefile
	pandoc \
		--highlight-style breezedark \
		--embed-resources --standalone \
		-f markdown -t html \
		$< -o $@ \
		-H style.css

.PHONY: clean
