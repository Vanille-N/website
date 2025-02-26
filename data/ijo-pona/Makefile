.target:
	mkdir -p $@

SRC = $(wildcard *.html) $(wildcard *.css) sitelen-seli-kiwen.ttf

all: $(SRC) |.target
	rm -rf .target/*
	cp -r $(SRC) .target/

