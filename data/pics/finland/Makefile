# Manager for the Finland picture module

DIRS = Feb Mar Apr May Jun
PICS = $(shell fd jpg)

# Lots of things to build:
# - replicate the folder structure
# - copy the pictures in both full size and miniature
# - archive the folders individually
all: .target/index.html \
	$(DIRS:%=.target/full/%/) $(DIRS:%=.target/mini/%/) \
	$(PICS:%=.target/full/%) $(PICS:%=.target/mini/%) \
	$(DIRS:%=.target/%.tar)

# Standalone file
.target/index.html: index.html |.target/
	cp $< $@

# Copy full size picture
.target/full/%.jpg: %.jpg |.target/full/
	cp $< $@

# Create miniature from full size
.target/mini/%.jpg: .target/full/%.jpg |.target/mini/
	convert '$<' -resize '5%' '$@'

# Archive folder
.target/%.tar: .target/full/%/
	/usr/bin/tar -cf '$@' '$<'

.target/:
	mkdir -p $@

.target/%/:
	mkdir -p $@

# Clean
clean:
	fd --unrestricted .target | xargs rm -rf

.PHONY: clean
