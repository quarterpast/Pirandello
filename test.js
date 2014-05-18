var laws = require('laws');
var σ = require('./lib');

[[ 'monoid'      , 'leftIdentity'  ]
,[ 'monoid'      , 'rightIdentity' ]
,[ 'semigroup'   , 'associativity' ]
,[ 'functor'     , 'identity'      ]
,[ 'functor'     , 'composition'   ]
,[ 'applicative' , 'identity'      ]
,[ 'applicative' , 'composition'   ]
,[ 'applicative' , 'homomorphism'  ]
,[ 'applicative' , 'interchange'   ]
,[ 'chain'       , 'associativity' ]
,[ 'monad'       , 'leftIdentity'  ]
,[ 'monad'       , 'rightIdentity' ]
].map(function(l) {
	var test = laws[l[0]][l[1]](σ).asTest({verbose: true});
	return function() {
		console.log(l.join(' '));
		test();
	};
}).forEach(function(t) { t() });

