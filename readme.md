# Pirandello
![](http://images4.wikia.nocookie.net/__cb20100628073138/mirrorsedge/images/2/2c/PKlogo.jpg)

A better Stream abstraction for node.js. ```npm install pirandello```

# Use
## Creating
There's a bunch of ways to create a Stream.

### ```Stream.of```
Creates a stream that sends a single value and ends.
```javascript
Stream.of("hello world")
//> hello world
```

### ```Stream.empty```
Just ends immediately.

### ```Stream.fromArray```
Sends each item in the array, then ends.
```javascript
Stream.fromArray(["hello ","world"])
//> hello world
```
### ```Stream.fromReadable```
Takes a node Readable stream and sends it one data chunk at a time.
```javascript
Stream.fromReadable(fs.createReadStream('data.txt'))
```

### ```new Stream```
To construct your own Streams, call the constructor (```new``` is optional) with a function that takes two arguments. Each argument is a function: call the first one with an object to send it over the stream, call the second one to end the stream. From the implementation of ```fromArray```:

```javascript
Stream.fromArray = function(arr) {
	return Stream(function(next,end) {
		arr.forEach(next)
		end()
	})
}
```

## Modifying
Pirandello Streams are immutable; the methods below return a new stream. Streams are a [fantasy-land](https://github.com/puffnfresh/fantasy-land) MonadPlus.

### ```Stream::concat```
Returns a new stream that sends the contents of the current stream followed by the contents of the other stream.
```javascript
Stream.of("hello ").concat(Stream.of("world"))
//> hello world
```
### ```Stream::chain```
Takes a function that operates on each chunk and should return a new Stream. Useful for concatenating lists.
```javascript
function read(f) {
	return Stream.fromReadable(fs.createReadStream(f));
}

Stream.fromArray(process.argv).chain(read).pipe(process.stdout)
```

### ```Stream::map```
Maps over the chunk.
```
Stream.fromArray(["hello ","world"]).map(function(s) {return s.toUpperCase()})
//> HELLO WORLD
```

### ```Stream::ap```
Applies a stream of functions to a stream of inputs, returns a stream of outputs.
```javascript
Stream.fromArray([
	function(s) { return s.toUpperCase(); },
	function(s) { return s.toLowerCase(); },
	function(s) { return s.substr(0,5); }
]).ap(Stream.of("Hello World "))
//> HELLO WORLD hello world Hello
```

### ```Stream::toCharstream```
Converts a Stream of strings into a Stream of individual characters.

### ```Stream::take```
Given a number, returns a stream of the first *n* chunks. Useful with ```toCharstream```.

```javascript
Stream.of("hello world").toCharstream().take(5)
//> hello
```

### ```Stream::drop```
Given a number, returns a stream without the first *n* chunks. Useful with ```toCharstream```.

```javascript
Stream.of("hello world").toCharstream().drop(6)
//> world
```

## Consuming
### ```Stream::pipe```
Mostly compatible with ```Readable::pipe```, sends every chunk to the destination Writable.

### ```Stream::generator```
When you really need low-level chunk functionality (maybe you're extending Pirandello? Good for you!), ```generator``` is what you want. It is, in fact, the function passed in when the Stream is instantiated; call it with two arguments, one function to deal with each chunk, and one which is called at the end. FUrom the implementation of ```pipe```:

```javascript
Stream.prototype.pipe = function(dest) {
	this.generator(
		function(chunk) { dest.write(chunk) }
		function() { dest.end() }
	)
}
```

# Why?
I [tried](https://github/quarterto/fantasy-streams) to make Readables look nice, I [really did](http://blog.153.io/post/58243405460/fantasy-streams). The API is ugly, and the abstraction is leaky. Here's to a fresh start.

# Licence
[MIT](licence.md)
