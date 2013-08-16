export class Stream
	(@generator)~>

	#map :: Stream a -> (a -> b) -> Steam b
	map: (f)->
		@chain (c)->
			Stream.of f c

	#chain :: Stream a -> (a -> Stream b) -> Steam b
	chain: (f)->
		Stream (next,end)~>
			@generator do
				(chunk)~> (f chunk).generator next, (->)
				end

	#ap :: Stream (a -> b) -> Stream a -> Stream b
	ap: (o)->
		@chain (f)->
			o.map f

	# concat :: Stream a -> Stream a -> Stream a
	concat: (other)->
		Stream (next,end)~>
			@generator next, -> other.generator next, end

	@from-readable = (readable)->
		Stream (next, end)->
			readable.on \data next
			readable.on \end  end

	@of = (obj)->
		Stream (next,end)->
			next obj if obj?
			end!

	@from-array = (arr)->
		Stream (next,end)->
			arr.for-each next
			end!

	@empty = -> Stream.of!

	pipe: (dest, options = {end:true})->
		@generator do
			dest~write
			-> dest.end! unless dest._isStdio or not options.end

	to-string: -> "[object Stream]"

	take: (n)->
		taken = 0
		@chain (chunk)->
			| taken >= n => Stream.empty!
			| otherwise => taken++; Stream.of chunk

	drop: (n)->
		dropped = 0
		@chain (chunk)->
			| dropped < n => dropped++; Stream.empty!
			| otherwise    => Stream.of chunk

	to-charstream: ->
		@chain (str)->
			Stream.from-array str.split ''

	scanl: (acc, f)->
		Stream (next,end)~>
			@generator do
				(chunk)-> next acc := f acc,chunk
				end

	scanl1: (f)->
		Stream (next,end)~>
			init = true
			var acc
			@generator do
				(chunk)->
					next acc := if init
						init := false
						chunk
					else f acc,chunk
				end

	scan: ::scanl
	scan1: ::scanl1

	foldl: (acc,f)->
		Stream (next,end)~>
			@generator do
				(chunk)-> acc := f acc,chunk
				->
					next acc
					end!

	foldl1: (f)->
		Stream (next,end)~>
			init = true
			var acc
			@generator do
				(chunk)->
					acc := if init
						init := false
						chunk
					else f acc,chunk
				->
					next acc
					end!

	fold: ::foldl
	fold1: ::foldl1

	length: ->
		@map -> 1
		.foldl 0,(+)

	zip-with-index: ->
		i = 0
		@map (c)-> [c, i++]