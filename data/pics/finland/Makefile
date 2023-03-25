DIRS = Feb Mar Apr May Jun
PICS = $(shell fd jpg)

all: .target/index.html \
	$(DIRS:%=.target/full/%/) $(DIRS:%=.target/mini/%/) \
	$(PICS:%=.target/full/%) $(PICS:%=.target/mini/%) \
	$(DIRS:%=.target/%.tar)

.target/index.html: index.html |.target/
	cp $< $@

.target/full/%.jpg: %.jpg |.target/full/
	cp $< $@

.target/mini/%.jpg: .target/full/%.jpg |.target/mini/
	convert '$<' -resize '5%' '$@'

.target/%.tar: .target/full/%/
	/usr/bin/tar -cf '$@' '$<'

.target/:
	mkdir -p $@

.target/%/:
	mkdir -p $@

clean:
	fd --unrestricted .target | xargs rm -rf

.PHONY: clean
