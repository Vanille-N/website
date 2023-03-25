MODULES = finland

all: $(MODULES:%=.target/%) |.target

%/.target: %
	cd $< && make

.target/%: %/.target |.target
	ln -srf "$<" "$@"

.target:
	mkdir -p $@

clean:
	fd --unrestricted .target | xargs rm -rf

.PHONY: clean
