require! "./".Stream

rand-string = (n)->
	[String.from-char-code Math.floor 256*Math.random! for to n].join ''

gen-strings = (l, f)->
	for to 1000
		strs = for to l => (rand-string 1000)
		f ...strs

fold = (i,f,a)->
	| empty a   => i
	| otherwise => fold (f i, head a), f, tail a

empty = (.length is 0)
head = (.0)
tail = (.slice 1)

eq = (a,b)->
	as = []
	bs = []

	ended = false
	end = ->
		if ended
			console.assert (fold "" (++), as) is (fold "" (++), bs)
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