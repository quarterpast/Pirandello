SJS_OPTS = -m adt/macros -m sparkler/macros -m lambda-chop/macros -r

all: lib/index.js

lib/%.js: src/%.js
	@mkdir -p ${@D}
	node_modules/.bin/sjs $(SJS_OPTS) $< -o $@

run: all
	node --harmony-generators s.js

clean:
	rm -rf lib

.PHONY: run clean
