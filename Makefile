all:
	coffee -o lib/ -c src/

watch:
	coffee -o lib/ -cw src/

clean:
	rm -rf lib/

test:
	mocha -c --compilers coffee:coffee-script/register

link:
	mkdir -p node_modules/
	ln -s /usr/local/lib/node_modules/walkingdriver/ node_modules/

.PHONY: all watch clean test link
