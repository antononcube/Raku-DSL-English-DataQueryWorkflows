
use v6.d;

use DSL::English::DataQueryWorkflows::Grammar;

class DSL::English::DataQueryWorkflows::Actions::Spanish::Predicate {

  # Predicates
  method predicates-list($/) { make $<predicate>>>.made.join(', '); }
  method predicate($/) { make $/.values>>.made.join(' '); }
  method predicate-sum($/) { make map( { '(' ~ $_ ~ ')' }, $<predicate-product>>>.made ).join(' o '); }
  method predicate-product($/) { make map( { '(' ~ $_ ~ ')' }, $<predicate-term>>>.made ).join(' y '); }
  method predicate-term($/) { make $/.values[0].made; }
  method predicate-group($/) { make '(' ~ $/<predicate-term>.made ~ ')'; }

  #method predicate($/) { make 'obj.' ~ $<variable-name>.made ~ ' .' ~ $<predicate-symbol>.made ~ ' ' ~ $<predicate-value>.made; }

  method predicate-simple($/) {
    if $<predicate-relation>.made eq '!in' {
      make $<lhs>.made ~ ' no pertenece al ' ~ $<rhs>.made;
    } elsif $<predicate-relation>.made eq 'like' {
      make $<rhs>.made ~ ' se asemeja ' ~ $<lhs>.made;
    } else {
      make $<lhs>.made ~ ' ' ~ $<predicate-relation>.made ~ ' ' ~ $<rhs>.made;
    }
  }
  method logical-connective($/) { make $/.values[0].made; }
  method and-operator($/) { make 'y'; }
  method or-operator($/) { make 'o'; }
  method predicate-symbol($/) { make $/.Str; }
  method predicate-value($/) { make $/.values[0].made; }
  method predicate-relation($/) { make $/.values[0].made; }
  method equal-relation($/) { make 'es igual'; }
  method not-equal-relation($/) { make 'no igual a '; }
  method less-relation($/) { make 'menos'; }
  method less-equal-relation($/) { make 'menos que o igual a'; }
  method greater-relation($/) { make 'más grande'; }
  method greater-equal-relation($/) { make 'más grande o igual'; }
  method same-relation($/) { make 'es lo mismo con'; }
  method not-same-relation($/) { make 'no es lo mismo con'; }
  method in-relation($/) { make 'pertenece a'; }
  method not-in-relation($/) { make 'no pertenece'; }
  method like-relation($/) { make 'se asemeja'; }
  method like-start-relation($/) { make 'comienza como'; }
  method like-end-relation($/) { make 'termina como'; }
  method like-contains-relation($/) { make 'contiene'; }
  method match-relation($/) { make 'coincide con'; }

}

