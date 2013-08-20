require! {
	"./index.js".Stream
	stream.Writable
}

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
drop-until = (f,a)-->
	| f head a  => a
	| otherwise => drop-until f, tail a
unlines = (.join "\n")
lines = (.split "\n")

id = ->it

assertions = 0
success = 0
fail = 0
error = 0

log-assert-or-exception = (e, at, bt)->
	if e.name == /AssertionError/
		console.error if at?
			stack = e.stack |> lines |> drop-until (== /at eq/) |> unlines
			""""#{at.substr 0 10}"… expected to be "#{bt.substr 0 10}"…
			#{stack}
			"""
		else e.stack
		fail++
	else
		console.error e.stack
		error++

	return e

assert = (cond,msg)->
	assertions++
	try
		console.assert cond,msg
		success++
	catch =>
		log-assert-or-exception e


class AssertStream extends Writable
	idx: 0
	(@test)-> super!
	_write: (chunk, encoding, callback)->
		assertions++
		callback try
			console.assert do
				(chunk.to-string encoding) is (@test[@idx].to-string encoding)
				"#chunk expected to be #{@test[@idx++]}"
			success++
			null
		catch
			log-assert-or-exception e

class SlowAssertStream extends AssertStream
	high-water-mark: 500
	->
		super ...
		@set-max-listeners Infinity
	_write: (chunk, encoding, callback)->
		super chunk, encoding, (...args)->
			set-timeout ->
				callback ...args
			, Math.random! * 10

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
			catch
				log-assert-or-exception e, at, bt
		else ended := true

	a.generator as~push, end
	b.generator bs~push, end

gen-strings 2, :concat (a,b)->
	sta = Stream.of a
	stb = Stream.of b
	stc = Stream.of (a + b)
	(sta ++ stb) `eq` stc

gen-strings 3, :assoc (a,b,c)->
	sta = Stream.of a
	stb = Stream.of b
	stc = Stream.of c

	(sta ++ (stb ++ stc)) `eq` ((sta ++ stb) ++ stc)

gen-strings 1, :ident (a)->
	sta = Stream.of a
	e = Stream.empty!

	(sta ++ e) `eq` (e ++ sta)
	(sta ++ e) `eq` sta
	sta `eq` (sta ++ e)

gen-strings 1, :take (a)->
	n = 10
	sta = Stream.of a .to-charstream! .take n
	sts = Stream.of a.slice 0 n

	sts `eq` sta

gen-strings 1, :drop (a)->
	n = 10
	sta = Stream.of a .to-charstream! .drop n
	sts = Stream.of a.slice n

	sts `eq` sta


gen-strings 1, :right-monad-identity (a)->
	sta = Stream.of a

	(sta.chain Stream.of) `eq` sta

gen-strings 1, :left-monad-identity (a)->
	f = (a)-> Stream.of a.length

	(Stream.of a .chain f) `eq` f a

gen-strings 1, :chain-assoc (a)->
	f = (a)-> Stream.of a.length
	g = (b)-> Stream.of b * 10

	sta = Stream.of a

	(sta.chain f .chain g) `eq` (sta.chain (x)-> (f x).chain g)

gen-strings 1, :applicative-identity (a)->
	sta = Stream.of a
	(Stream.of id .ap sta) `eq` sta

gen-strings 1, :applicative-composition (a)->
	u = Stream.of (a)-> a.length
	v = Stream.of (b)-> a * 10
	w = Stream.of a

	(Stream.of (<<) .ap u .ap v .ap w) `eq` u.ap (v.ap w)

gen-strings 1, :homomorphism (a)->
	f = (a)-> a.length
	(Stream.of f .ap Stream.of a) `eq` Stream.of f a

gen-strings 1, :interchange (a)->
	u = Stream.of (a)-> a.length
	(u.ap Stream.of a) `eq` (Stream.of (<| a) .ap u)

gen-strings 1, :functor-indentity (a)->
	u = Stream.of a
	(u.map id) `eq` u

gen-strings 1, :functor-composition (a)->
	f = (a)-> a.length
	g = (b)-> b * 10
	u = Stream.of a

	(u.map g . f) `eq` (u.map f).map g

gen-strings 1, :pipe (a)->
	sta = Stream.of a .to-charstream!

	sta.pipe new AssertStream a

gen-strings 50, :slow-pipe (...arr)->
	sta = Stream.from-array arr

	sta.pipe new SlowAssertStream arr