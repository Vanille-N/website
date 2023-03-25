all: |.target
	./manage.py

.target:
	mkdir -p $@

clean:
	fd --unrestricted .target | xargs rm -rf

.PHONY: all
