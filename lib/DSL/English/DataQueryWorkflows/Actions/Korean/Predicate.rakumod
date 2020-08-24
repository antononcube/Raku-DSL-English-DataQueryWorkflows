
use v6;
use DSL::English::DataQueryWorkflows::Grammar;

unit module DSL::English::DataQueryWorkflows::Actions::Korean::Predicate;

class DSL::English::DataQueryWorkflows::Actions::Korean::Predicate {

  # Predicates
  method predicates-list($/) { make $<predicate>>>.made.join(', '); }
  method predicate($/) { make $/.values>>.made.join(' '); }
  method predicate-sum($/) { make map( { '(' ~ $_ ~ ')' }, $<predicate-product>>>.made ).join(' 또는 '); }
  method predicate-product($/) { make map( { '(' ~ $_ ~ ')' }, $<predicate-term>>>.made ).join(' 과 '); }
  method predicate-term($/) { make $/.values[0].made; }
  method predicate-group($/) { make '(' ~ $/<predicate-term>.made ~ ')'; }

  method predicate-simple($/) {
    if $<predicate-relation>.made eq '!in' {
      make $<lhs>.made ~ ' 속하지 않는 ' ~ $<rhs>.made;
    } elsif $<predicate-relation>.made eq 'like' {
      make $<rhs>.made ~ ' 비슷하다 ' ~ $<lhs>.made;
    } else {
      make $<lhs>.made ~ ' ' ~ $<predicate-relation>.made ~ ' ' ~ $<rhs>.made;
    }
  }
  method logical-connective($/) { make $/.values[0].made; }
  method and-operator($/) { make '과'; }
  method or-operator($/) { make '또는'; }
  method predicate-symbol($/) { make $/.Str; }
  method predicate-value($/) { make $/.values[0].made; }
  method predicate-relation($/) { make $/.values[0].made; }
  method equal-relation($/) { make '동일하다'; }
  method not-equal-relation($/) { make '같지 않다'; }
  method less-relation($/) { make '이하'; }
  method less-equal-relation($/) { make '작거나 같음'; }
  method greater-relation($/) { make '더 큰'; }
  method greater-equal-relation($/) { make '크거나 같음'; }
  method same-relation($/) { make '와 같다'; }
  method not-same-relation($/) { make '다음과 같지 않다'; }
  method in-relation($/) { make '속하다'; }
  method not-in-relation($/) { make '속하지 않는다'; }
  method like-relation($/) { make '비슷하다'; }

}

