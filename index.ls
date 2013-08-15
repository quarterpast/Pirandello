require! stream.Readable

export class Stream
	(@generator)~>

	#map :: Stream a -> (a -> b) -> Steam b
	map: (f)->
		@chain (c)->
			Stream.of f c

	#chain :: Stream a -> (a -> Stream b) -> Steam b
	chain: (f)->
		Stream (next)~>
			@generator (chunk)~>
				(f chunk).generator next

	#ap :: Stream (a -> b) -> Stream a -> Stream b
	ap: (o)->
		@chain (f)->
			o.map f

	# concat :: Stream a -> Stream a -> Stream a
	concat: (o)->
		Stream (next)~>
			@generator (chunk)->
				console.log chunk
				if chunk?
					next that
				else
					o.generator next

	@from-readable = (readable)->
		Stream (next)->
			readable.on \data next
			readable.on \end -> next null

	@of = (obj)->
		Stream (next)->
			next obj if obj?
			next null

	@from-array = (arr)->
		Stream (`each` arr)

	@empty = ->
		Stream.of!

	to-readable: ->
		out = new process.EventEmitter
		@generator (chunk)->
			if chunk?
				out.emit \data that
			else out.emit \end

		new Readable! .wrap out

	to-string: -> "[object Stream]"