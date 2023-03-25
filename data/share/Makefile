# Manager for share
# The actual work is done by manage.py, so this Makefile is just the interface
# for higher-level invocations

all: |.target
	./manage.py

.target:
	mkdir -p $@

# Clean
clean:
	fd --unrestricted .target | xargs rm -rf

.PHONY: all
