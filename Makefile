all: index.js

%.js: %.ls
	node_modules/.bin/lsc -pc $(LS_OPTS) "$<" > "$@"

clean:
	rm -f index.js

.PHONY: test
test: all
	node_modules/.bin/lsc test.ls