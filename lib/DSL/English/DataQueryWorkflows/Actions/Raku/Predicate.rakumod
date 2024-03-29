
use v6;
use DSL::English::DataQueryWorkflows::Grammar;

unit module DSL::English::DataQueryWorkflows::Actions::Raku::Predicate;

class DSL::English::DataQueryWorkflows::Actions::Raku::Predicate {

  # Predicates
  method predicates-list($/) { make $<predicate>>>.made.join(', '); }
  method predicate($/) { make $/.values>>.made.join(' '); }
  method predicate-sum($/) { make $<predicate-product>>>.made.join(' or '); }
  method predicate-product($/) { make $<predicate-term>>>.made.join(' and '); }
  method predicate-term($/) { make $/.values[0].made; }
  method predicate-group($/) { make '(' ~ $/<predicate-term>.made ~ ')'; }

  method predicate-simple($/) {
    if $<predicate-relation>.made eq 'like' {
      make  $<lhs>.made ~ ' ~~ ' ~ $<rhs>.made;
    } else {
      make '$_{' ~ $<lhs>.made ~ '} ' ~ $<predicate-relation>.made ~ ' ' ~ $<rhs>.made;
    }
  }
  method logical-connective($/) { make $/.values[0].made; }
  method and-operator($/) { make 'and'; }
  method or-operator($/) { make 'or'; }
  method predicate-symbol($/) { make $/.Str; }
  method predicate-value($/) { make $/.values[0].made; }
  method predicate-relation($/) { make $/.values[0].made; }
  method equal-relation($/) { make 'eq'; }
  method not-equal-relation($/) { make '!eq'; }
  method less-relation($/) { make '<'; }
  method less-equal-relation($/) { make '<='; }
  method greater-relation($/) { make '>'; }
  method greater-equal-relation($/) { make '>='; }
  method same-relation($/) { make 'eqv'; }
  method not-same-relation($/) { make '!='; }
  method in-relation($/) { make '(elem)'; }
  method not-in-relation($/) { make '!(elem)'; }
  method like-relation($/) { make '~~'; }

}

