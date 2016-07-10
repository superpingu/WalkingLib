all:
	coffee -o lib/ -c src/

watch:
	coffee -o lib/ -cw src/

clean:
	rm -rf lib/

test:
	mocha -c --compilers coffee:coffee-script/register

link:
	npm link walkingdriver

.PHONY: all watch clean test link
