# Manager for data

# Modules are the different services
# They eventually appear as direct children of perso.crans.org/vanille/
MODULES = share better-pbm-viewer treebor treebor.0 pics ijo-pona
STANDALONE = index.html style.css

all: $(MODULES:%=.target/%) $(STANDALONE:%=.target/%) |.target

# Build a module by invoking its make
$(MODULES:%=%/.target): %/.target: %
	cd $< && make

# Once a module is built, link module/.target with .target/module
$(MODULES:%=.target/%): .target/%: %/.target |.target
	ln -srf "$<" "$@"

.target:
	mkdir -p $@

# Directly copy the standalone files
$(STANDALONE:%=.target/%): .target/%: % |.target
	cp $< $@

# Clean
clean:
	fd --unrestricted '.target' | xargs rm -rf

.PHONY: clean $(MODULES:%=%/.target)
