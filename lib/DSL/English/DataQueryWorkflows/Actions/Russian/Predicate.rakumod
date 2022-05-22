use v6.d;

use DSL::English::DataQueryWorkflows::Grammar;

unit module DSL::English::DataQueryWorkflows::Actions::Russian::Predicate;

class DSL::English::DataQueryWorkflows::Actions::Russian::Predicate {

  # Predicates
  method predicates-list($/) { make $<predicate>>>.made.join(', '); }
  method predicate($/) { make $/.values>>.made.join(' '); }
  method predicate-sum($/) { make map( { '(' ~ $_ ~ ')' }, $<predicate-product>>>.made ).join(' или '); }
  method predicate-product($/) { make map( { '(' ~ $_ ~ ')' }, $<predicate-term>>>.made ).join(' и '); }
  method predicate-term($/) { make $/.values[0].made; }
  method predicate-group($/) { make '(' ~ $/<predicate-term>.made ~ ')'; }

  method predicate-simple($/) {
    if $<predicate-relation>.made eq '!in' {
      make $<lhs>.made ~ ' не принадлежит ' ~ $<rhs>.made;
    } elsif $<predicate-relation>.made eq 'like' {
      make $<rhs>.made ~ ' похож ' ~ $<lhs>.made;
    } else {
      make $<lhs>.made ~ ' ' ~ $<predicate-relation>.made ~ ' ' ~ $<rhs>.made;
    }
  }
  method logical-connective($/) { make $/.values[0].made; }
  method and-operator($/) { make 'и'; }
  method or-operator($/) { make 'или'; }
  method predicate-symbol($/) { make $/.Str; }
  method predicate-value($/) { make $/.values[0].made; }
  method predicate-relation($/) { make $/.values[0].made; }
  method equal-relation($/) { make 'равно'; }
  method not-equal-relation($/) { make 'не равно'; }
  method less-relation($/) { make 'меньше'; }
  method less-equal-relation($/) { make 'меньше или равно'; }
  method greater-relation($/) { make 'больше'; }
  method greater-equal-relation($/) { make 'больше или равно'; }
  method same-relation($/) { make 'то же самое с'; }
  method not-same-relation($/) { make 'не то же самое с'; }
  method in-relation($/) { make 'принадлежит к'; }
  method not-in-relation($/) { make 'не принадлежит к'; }
  method like-relation($/) { make 'похож на'; }
  method like-start-relation($/) { make 'начинается с'; }
  method like-end-relation($/) { make 'заканчивается с'; }
  method like-contains-relation($/) { make 'содержит'; }
  method match-relation($/) { make 'соответствует на'; }
}

