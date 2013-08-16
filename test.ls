require! "./index.js".Stream

rand-string = (n)->
	[String.from-char-code Math.floor 256*Math.random! for til n].join ''

gen-strings = (l, f)->
	for to 1000
		strs = for til l => (rand-string 1000)
		f ...strs

process.on \exit ->
	console.log "#assertions assertions, #fail failures, #error errors"
	process.exit 1 if error or fail

fold = (i,f,a)->
	| empty a   => i
	| otherwise => fold (f i, head a), f, tail a

empty = (.length is 0)
head = (.0)
tail = (.slice 1)

id = ->it

assertions = 0
success = 0
fail = 0
error = 0

eq = (a,b)->
	as = []
	bs = []

	assertions++

	ended = false
	end = ->
		at = (fold "" (+), as)
		bt = (fold "" (+), bs)
		if ended
			try
				console.assert at is bt
				success++
			catch e
				if e.name == /AssertionError/
					console.error "#at expected to be #bt"
					fail++
				else
					console.log e.stack
					error++
		else ended := true

	a.generator as~push, end
	b.generator bs~push, end

gen-strings 2 (a,b)->
	sta = Stream.of a
	stb = Stream.of b
	stc = Stream.of (a + b)
	(sta ++ stb) `eq` stc

gen-strings 3 (a,b,c)->
	sta = Stream.of a
	stb = Stream.of b
	stc = Stream.of c

	(sta ++ (stb ++ stc)) `eq` ((sta ++ stb) ++ stc)

gen-strings 1 (a)->
	sta = Stream.of a
	e = Stream.empty!

	(sta ++ e) `eq` (e ++ sta)
	(sta ++ e) `eq` sta
	sta `eq` (sta ++ e)

gen-strings 1 (a)->
	n = 10
	sta = Stream.of a .to-charstream! .take n
	sts = Stream.of a.slice 0 n

	sts `eq` sta

gen-strings 1 (a)->
	n = 10
	sta = Stream.of a .to-charstream! .drop n
	sts = Stream.of a.slice n

	sts `eq` sta


gen-strings 1 (a)->
	sta = Stream.of a

	(sta.chain Stream.of) `eq` sta

gen-strings 1 (a)->
	f = (a)-> Stream.of a.length

	(Stream.of a .chain f) `eq` f a

gen-strings 1 (a)->
	f = (a)-> Stream.of a.length
	g = (b)-> Stream.of b * 10

	sta = Stream.of a

	(sta.chain f .chain g) `eq` (sta.chain (x)-> (f x).chain g)

gen-strings 1 (a)->
	sta = Stream.of a
	(Stream.of id .ap sta) `eq` sta

gen-strings 1 (a)->
	u = Stream.of (a)-> a.length
	v = Stream.of (b)-> a * 10
	w = Stream.of a

	(Stream.of (<<) .ap u .ap v .ap w) `eq` u.ap (v.ap w)

gen-strings 1 (a)->
	f = (a)-> a.length
	(Stream.of f .ap Stream.of a) `eq` Stream.of f a

gen-strings 1 (a)->
	u = Stream.of (a)-> a.length
	(u.ap Stream.of a) `eq` (Stream.of (<| a) .ap u)

gen-strings 1 (a)->
	u = Stream.of a
	(u.map id) `eq` u

gen-strings 1 (a)->
	f = (a)-> a.length
	g = (b)-> b * 10
	u = Stream.of a

	(u.map g . f) `eq` (u.map f).map g
