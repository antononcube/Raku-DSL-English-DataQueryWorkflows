
use v6.d;
use DSL::General::DataQueryWorkflows::Grammar;

class DSL::General::DataQueryWorkflows::Actions::English::Predicate {

  # Predicates
  method predicates-list($/) { make $<predicate>>>.made.join(', '); }
  method predicate($/) { make $/.values>>.made.join(' '); }
  method predicate-sum($/) { make map( { '(' ~ $_ ~ ')' }, $<predicate-product>>>.made ).join(' или '); }
  method predicate-product($/) { make map( { '(' ~ $_ ~ ')' }, $<predicate-term>>>.made ).join(' и '); }
  method predicate-term($/) { make $/.values[0].made; }
  method predicate-group($/) { make '(' ~ $/<predicate-term>.made ~ ')'; }

  method predicate-simple($/) {
    if $<predicate-relation>.made eq '!in' {
      make $<lhs>.made ~ ' does not belong to ' ~ $<rhs>.made;
    } elsif $<predicate-relation>.made eq 'like' {
      make $<rhs>.made ~ ' is like ' ~ $<lhs>.made;
    } else {
      make $<lhs>.made ~ ' ' ~ $<predicate-relation>.made ~ ' ' ~ $<rhs>.made;
    }
  }
  method logical-connective($/) { make $/.values[0].made; }
  method and-operator($/) { make 'and'; }
  method or-operator($/) { make 'or'; }
  method predicate-symbol($/) { make $/.Str; }
  method predicate-value($/) { make $/.values[0].made; }
  method predicate-relation($/) { make $/.values[0].made; }
  method equal-relation($/) { make 'is equal to'; }
  method not-equal-relation($/) { make 'is not equal to'; }
  method less-relation($/) { make 'less than'; }
  method less-equal-relation($/) { make 'less or equal than'; }
  method greater-relation($/) { make 'greater than'; }
  method greater-equal-relation($/) { make 'greater or equal than'; }
  method same-relation($/) { make 'is the same as'; }
  method not-same-relation($/) { make 'is not the same as'; }
  method in-relation($/) { make 'belogns'; }
  method not-in-relation($/) { make 'does not belong'; }
  method like-relation($/) { make 'is similar to'; }

}

