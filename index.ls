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