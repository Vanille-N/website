MODULES = share better-pbm-viewer treebor pics
STANDALONE = index.html style.css

all: $(MODULES:%=.target/%) $(STANDALONE:%=.target/%) |.target

$(MODULES:%=%/.target): %/.target: %
	cd $< && make

$(MODULES:%=.target/%): .target/%: %/.target |.target
	ln -srf "$<" "$@"

$(STANDALONE:%=.target/%): .target/%: % |.target
	cp $< $@

.target:
	mkdir -p $@

clean:
	fd --unrestricted '.target' | xargs rm -rf

.PHONY: clean $(MODULES:%=%/.target)
