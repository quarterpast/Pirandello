require! stream.Readable

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
			each next,arr
			end!

	@empty = ->Stream.of!

	to-readable: ->
		out = new process.EventEmitter
		#out.resume = ->
		@generator do
			(chunk)-> console.log chunk; out.emit \data chunk
			-> out.emit \end

		new Readable! .wrap out

	to-string: -> "[object Stream]"