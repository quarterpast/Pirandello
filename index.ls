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

	@empty = ->Stream.of!

	pipe: (dest, options = {end:true})->
		@generator do
			dest~write
			-> dest.end! unless dest._isStdio or not options.end

	to-string: -> "[object Stream]"

	take: (n)->
		taken = 0
		Stream (next,end)~>
			@generator do
				(chunk)->
					if taken < n
						next chunk
						taken++
					else end!
				-> if taken <= n then end!

	drop: (n)->
		dropped = 0
		Stream (next,end)~>
			@generator do
				(chunk)->
					if dropped >= n
						next chunk
					dropped++
				end

	to-charstream: ->
		@chain (str)->
			Stream.from-array str.split ''