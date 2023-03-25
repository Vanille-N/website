# Root Makefile

all: local push

# Build www by extracting .data/target
local: data/.target |www
	rsync -rhPL --exclude '.target' \
		data/.target/ www

www:
	mkdir -p $@

data/.target: data
	cd $< && make

# Sync with zamok.crans.org
# Dependency: `remote`
push: local
	remote push zamok www/ www

# Clean
clean:
	fd --unrestricted .target | xargs rm -rf

.PHONY: data/.target
