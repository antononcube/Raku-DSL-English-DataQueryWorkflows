use v6;

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
  method and-operator:sym<English>($/) { make 'и'; }
  method or-operator:sym<English>($/) { make 'или'; }
  method predicate-symbol($/) { make $/.Str; }
  method predicate-value($/) { make $/.values[0].made; }
  method predicate-relation($/) { make $/.values[0].made; }
  method equal-relation:sym<English>($/) { make 'равно'; }
  method not-equal-relation:sym<English>($/) { make 'не равно'; }
  method less-relation:sym<English>($/) { make 'меньше'; }
  method less-equal-relation:sym<English>($/) { make 'меньше или равно'; }
  method greater-relation:sym<English>($/) { make 'больше'; }
  method greater-equal-relation:sym<English>($/) { make 'больше или равно'; }
  method same-relation:sym<English>($/) { make 'то же самое с'; }
  method not-same-relation:sym<English>($/) { make 'не то же самое с'; }
  method in-relation:sym<English>($/) { make 'принадлежит к'; }
  method not-in-relation:sym<English>($/) { make 'не принадлежит к'; }
  method like-relation:sym<English>($/) { make 'похож на'; }
  method like-start-relation:sym<English>($/) { make 'начинается с'; }
  method like-end-relation:sym<English>($/) { make 'заканчивается с'; }
  method like-contains-relation:sym<English>($/) { make 'содержит'; }
  method match-relation:sym<English>($/) { make 'соответствует на'; }
}

