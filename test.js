var laws = require('laws');
var σ = require('./lib');

[laws.monoid.leftIdentity,
 laws.monoid.rightIdentity,
 laws.semigroup.associativity,
 laws.functor.identity,
 laws.functor.composition,
 laws.applicative.identity,
 laws.applicative.composition,
 laws.applicative.homomorphism,
 laws.applicative.interchange,
 laws.chain.associativity,
 laws.monad.leftIdentity,
 laws.monad.rightIdentity].forEach(function(l) { l(σ).asTest()() });

