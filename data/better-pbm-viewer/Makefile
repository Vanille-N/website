# Manager for better-pbm-viewer
# Pretty trivial

ICO = favicon.ico
INDEX = index.html

all: .target/$(ICO) .target/$(INDEX)

.target:
	mkdir -p $@

.target/%: % |.target
	cp $< $@
