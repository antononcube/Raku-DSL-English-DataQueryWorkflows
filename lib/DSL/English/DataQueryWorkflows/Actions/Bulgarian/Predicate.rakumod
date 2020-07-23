
use v6;
use DSL::English::DataQueryWorkflows::Grammar;

unit module DSL::English::DataQueryWorkflows::Actions::Bulgarian::Predicate;

class DSL::English::DataQueryWorkflows::Actions::Bulgarian::Predicate {

  # Predicates
  method predicates-list($/) { make $<predicate>>>.made.join(', '); }
  method predicate($/) { make $/.values>>.made.join(' '); }
  method predicate-sum($/) { make map( { '(' ~ $_ ~ ')' }, $<predicate-product>>>.made ).join(' или '); }
  method predicate-product($/) { make map( { '(' ~ $_ ~ ')' }, $<predicate-term>>>.made ).join(' и '); }
  method predicate-term($/) { make $/.values[0].made; }
  method predicate-group($/) { make '(' ~ $/<predicate-term>.made ~ ')'; }

  #method predicate($/) { make 'obj.' ~ $<variable-name>.made ~ ' .' ~ $<predicate-symbol>.made ~ ' ' ~ $<predicate-value>.made; }

  method predicate-simple($/) {
    if $<predicate-relation>.made eq '!in' {
      make '' ~ $<lhs>.made ~ ' не принадлежи на ' ~ $<rhs>.made ~ ')';
    } elsif $<predicate-relation>.made eq 'like' {
      make $<rhs>.made ~ ' наподобява ' ~ $<lhs>.made ~ ')';
    } else {
      make 'obj.' ~ $<lhs>.made ~ ' ' ~ $<predicate-relation>.made ~ ' ' ~ $<rhs>.made;
    }
  }
  method logical-connective($/) { make $/.values[0].made; }
  method and-operator($/) { make 'и'; }
  method or-operator($/) { make 'или'; }
  method predicate-symbol($/) { make $/.Str; }
  method predicate-value($/) { make $/.values[0].made; }
  method predicate-relation($/) { make $/.values[0].made; }
  method equal-relation($/) { make 'се равнява на'; }
  method not-equal-relation($/) { make 'не се равнява на'; }
  method less-relation($/) { make 'по-малко'; }
  method less-equal-relation($/) { make 'по-малко или равно'; }
  method greater-relation($/) { make 'по-голямо'; }
  method greater-equal-relation($/) { make 'по-голямо или равно'; }
  method same-relation($/) { make 'е едно и също с'; }
  method not-same-relation($/) { make 'не е едно и също с'; }
  method in-relation($/) { make 'принадлежи'; }
  method not-in-relation($/) { make 'не принадлежи'; }
  method like-relation($/) { make 'наподобява'; }

}

