require! "./".Stream

rand-string = (n)->
	[String.from-char-code Math.floor 256*Math.random! for to n].join ''

gen-strings = (l, f)->
	for to 1000
		strs = for to l => (rand-string 1000)
		f ...strs

process.on \exit ->
	console.log "#assertions assertions, #fail failures, #error errors"

fold = (i,f,a)->
	| empty a   => i
	| otherwise => fold (f i, head a), f, tail a

empty = (.length is 0)
head = (.0)
tail = (.slice 1)

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
		at = (fold "" (++), as)
		bt = (fold "" (++), bs)
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
