all: local push

local: data/.target |www
	rsync -rhPL --exclude '.target' \
		data/.target/ www

push: local
	remote push zamok www/ www

data/.target: data
	cd $< && make

www:
	mkdir -p $@

clean:
	fd --unrestricted .target | xargs rm -rf

.PHONY: data/.target
