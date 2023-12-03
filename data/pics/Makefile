# Manager for pics
# Modules are the direct children of perso.crans.org/vanille/pics/

# FIXME: disabled under NixOS rebuild.
MODULES = #finland

all: $(MODULES:%=.target/%) |.target

# Build a module my invoking its make
%/.target: %
	cd $< && make

# Once a module is built, link module/.target with .target/module
$(MODULES:%=.target/%): .target/%: %/.target |.target
	ln -srf "$<" "$@"

.target:
	mkdir -p $@

# Clean
clean:
	fd --unrestricted .target | xargs rm -rf

.PHONY: clean $(MODULES:%=.target/%)
