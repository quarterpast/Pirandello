SJS_OPTS = -m adt-simple/macros -m sparkler/macros -m lambda-chop/macros

all: lib/index.js

lib/%.js: src/%.js
	@mkdir -p ${@D}
	node_modules/.bin/sjs $(SJS_OPTS) $< -o $@

test: all
	node test.js

clean:
	rm -rf lib

.PHONY: test clean
