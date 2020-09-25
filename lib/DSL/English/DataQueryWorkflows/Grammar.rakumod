=begin comment
#==============================================================================
#
#   Data transformation workflows grammar in Raku Perl 6
#   Copyright (C) 2018  Anton Antonov
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#   Written by Anton Antonov,
#   antononcube @ gmai l . c om,
#   Windermere, Florida, USA.
#
#==============================================================================
#
#   For more details about Raku Perl6 see https://perl6.org/ .
#
#==============================================================================
=end comment

use v6;

use DSL::Shared::Roles::English::CommonParts;
use DSL::Shared::Roles::English::PipelineCommand;
use DSL::Shared::Roles::PredicateSpecification;
use DSL::Shared::Roles::ErrorHandling;

use DSL::English::DataQueryWorkflows::Grammar::DataQueryPhrases;

grammar DSL::English::DataQueryWorkflows::Grammar
        does DSL::Shared::Roles::ErrorHandling
        does DSL::English::DataQueryWorkflows::Grammar::DataQueryPhrases
        does DSL::Shared::Roles::PredicateSpecification {
    # TOP
    rule TOP {
        <pipeline-command> |
        <data-load-command> |
        <distinct-command> |
        <missing-treatment-command> |
        <rename-columns-command> |
        <select-command> |
        <filter-command> |
        <mutate-command> |
        <group-command> |
        <ungroup-command> |
        <arrange-command> |
        <drop-columns-command> |
        <statistics-command> |
        <join-command> |
        <reshape-command> |
        <cross-tabulation-command> }

    # Column specs
    rule column-specs-list { <column-spec>+ % <list-separator> }
    rule column-spec { <column-name-spec> | <wl-expr> }
    rule column-name-spec { <mixed-quoted-variable-name> }

    # Load data
    rule data-load-command { <load-data-table> | <use-data-table> }
    rule data-location-spec { <dataset-name> }
    rule load-data-table { <.load-data-directive> <data-location-spec> }
    rule use-data-table { [ <.use-verb> | <.using-preposition> ] <.the-determiner>? <.data>? <variable-name> }

    # Distinct command
    rule distinct-command { <distinct-simple-command> }
    rule distinct-simple-command {
        <keep-only-phrase>? [ <distinct-adjective> | <unique-adjective> ] [ <values-noun> | <records-phrase> ]? <only-adverb>? |
        <delete-directive> [ <duplicate-adjective> | <duplicates-noun> ] [ <values-noun> | <records-phrase> ]? }

    # Missing treatment command
    rule missing-treatment-command { <drop-incomplete-cases-command> | <replace-missing-command> }
    rule drop-incomplete-cases-command {
        <keep-only-phrase> <complete-cases-phrase> |
        <omit-directive> <missing-values-phrase>? |
        <delete-directive> <missing-values-phrase> }
    rule replace-missing-command { <.replace-verb> <.missing-values-phrase> <.with-preposition> <replace-missing-rhs> }
    rule replace-missing-rhs { <number-value> | <mixed-quoted-variable-name> | <wl-expr> }

    # Rename columns
    rule rename-columns-command { <rename-columns-by-pairs> | <rename-columns-by-two-lists> }
    rule rename-columns-by-two-lists { <.rename-directive> <.the-determiner>? [ <.columns> | <.variable-noun> | <.variables-noun> ]?
                                 <current=.column-specs-list>
                                 [ <.to-preposition> | <.into-preposition> | <.as-preposition> ]
                                 <new=.column-specs-list> }
    rule rename-columns-by-pairs { <.rename-directive> [ <as-pairs-list> | <assign-pairs-list> ] }

    # Select command
    rule select-command { <select-columns-by-pairs> | <select-columns-by-two-lists> | <select-columns-simple> }
    rule select-opening-phrase { <select> <the-determiner>? [ <variables-noun> | <variable-noun> | <columns> ]? }
    rule select-columns-simple { <.select-opening-phrase> <column-specs-list> }
    rule select-columns-by-two-lists { <.select-opening-phrase> <current=.column-specs-list> <.as-preposition> <new=.column-specs-list> }
    rule select-columns-by-pairs { <.select-verb> [ <as-pairs-list> | <assign-pairs-list> ] }

    # Filter command
    rule filter-command { <filter> <.the-determiner>? <.rows>? [ <.for-which-phrase>? | <.by-preposition> ] <filter-spec> }
    rule filter-spec { <predicates-list> }

    # Mutate command
    rule mutate-command { [ <.mutate> | <.assign-verb> | <.transform-verb> ] <.by-preposition>? <assign-pairs-list> }

    # Group command
    rule group-command { <group-by> <variable-names-list> }

    # Ungroup command
    rule ungroup-command { <ungroup-simple-command> }
    rule ungroup-simple-command { <ungroup-verb> | <combine-verb> }

    # Arrange command
    rule arrange-command { <arrange-by-command-descending> | <arrange-by-command-ascending> | <arrange-simple-command> }
    rule arrange-simple-command { <.arrange-directive> [ <ascending> | <descending> ] | <reverse-sort-phrase> }
    rule arrange-command-filler { <by-preposition> <the-determiner>? [ <variables-noun> | <variable-noun> ]? }
    rule arrange-by-spec { <.by-preposition>? <.the-determiner>? [ <.variables-noun> | <.variable-noun> ]? <mixed-quoted-variable-names-list> }
    rule arrange-by-command-ascending {
        <.arrange-directive> <.ascending>? <arrange-by-spec> |
        <.arrange-by-phrase> <arrange-by-spec> <.ascending> }
    rule arrange-by-command-descending {
        <.arrange-directive> <.descending> <arrange-by-spec> |
        <.arrange-by-phrase> <arrange-by-spec> <.descending> |
        <.reverse-sort-phrase> <arrange-by-spec> }

    # Drop columns
    rule drop-columns-command { <drop-columns-simple> }
    rule drop-columns-simple { <.delete-directive> <.the-determiner>? [ <.columns> | <.variable-noun> | <.variables-noun> ]? <todrop=.column-specs-list> }

    # Statistics command
    rule statistics-command { <count-command> | <glimpse-data> | <summarize-all-command> | <summarize-at-command> | <summarize-data> }
    rule count-command { <compute-directive> <.the-determiner>? [ <count-verb> | <counts-noun> ] | <count-verb> }
    rule glimpse-data { <.display-directive>? <.a-determiner>? <.glimpse-verb> <.at-preposition>? <.the-determiner>? <data>  }
    rule summarize-data { [ <summarize-verb> | <summarise-verb> | <summary> ] <data>? | <display-directive> <data>? <summary> }
    rule summarize-all-command { [ <.summarize-verb> | <.summarise-verb> ] <.them-pronoun>? <.all-determiner>? <.data>? [ <.with-preposition> <.functions>? <summarize-funcs-spec> ] }
    rule summarize-at-command { [ <.summarize-verb> | <.summarise-verb> ] <.the-determiner>? <.columns> <cols=.mixed-quoted-variable-names-list> [ <.with-preposition> <.the-determiner>? <.functions>? <summarize-funcs-spec> ]? }
    rule summarize-funcs-spec { <variable-name-or-wl-expr-list> }

    # Join command
    rule join-command { <inner-join-spec> | <left-join-spec> | <right-join-spec> | <semi-join-spec> | <full-join-spec> }
    rule join-by-spec { <key-pairs-list> | <mixed-quoted-variable-names-list> | <wl-expr> }
    rule full-join-spec  { <.full-adjective>  <.join-noun> <.with-preposition>? <dataset-name> [ [ <.by-preposition> | <.using-preposition> | <.on-preposition> ] <join-by-spec> ]? }
    rule inner-join-spec { <.inner-adjective> <.join-noun> <.with-preposition>? <dataset-name> [ [ <.by-preposition> | <.using-preposition> | <.on-preposition> ] <join-by-spec> ]? }
    rule left-join-spec  { <.left-adjective>  <.join-noun> <.with-preposition>? <dataset-name> [ [ <.by-preposition> | <.using-preposition> | <.on-preposition> ] <join-by-spec> ]? }
    rule right-join-spec { <.right-adjective> <.join-noun> <.with-preposition>? <dataset-name> [ [ <.by-preposition> | <.using-preposition> | <.on-preposition> ] <join-by-spec> ]? }
    rule semi-join-spec  { <.semi-adjective>  <.join-noun> <.with-preposition>? <dataset-name> [ [ <.by-preposition> | <.using-preposition> | <.on-preposition> ] <join-by-spec> ]? }

    # Cross tabulate command
    rule cross-tabulate-command { <cross-tabulate-command> | <contingency-matrix-command> }
    rule cross-tabulation-command { <.cross-tabulate-phrase> <cross-tabulation-formula> }
    rule contingency-matrix-command { <.create-directive> [ <.the-determiner> | <.a-determiner>]? <.contingency-matrix-phrase> [ <.using-preposition> | <.with-formula-phrase> ] <cross-tabulation-formula> }
    rule cross-tabulation-formula { <cross-tabulation-double-formula> | <cross-tabulation-single-formula> }
    rule cross-tabulation-double-formula { <.variable-noun>? <rows-variable-name> [ <.list-separator-symbol> | <.with-preposition> ] <.variable-noun>? <columns-variable-name> [ <.over-preposition> <values-variable-name> ]? }
    rule cross-tabulation-single-formula { <.variable-noun>? <rows-variable-name> [ <.over-preposition> <values-variable-name> ]? }
    rule rows-variable-name { <column-spec> }
    rule columns-variable-name { <column-spec> }
    rule values-variable-name { <column-spec> }

    # Reshape command
    rule reshape-command { <pivot-longer-command> | <pivot-wider-command> | <make-dictionary-command> }

    # To long form command
    rule pivot-longer-command {
        :my Int $*COLS = 0;
        :my Int $*IDCOLS = 0;
        :my Int $*VARTO = 0;
        :my Int $*VALTO = 0;
        <.convert-verb>? <.to-long-form-phrase> <.filler-separator> <pivot-longer-arguments-list> }

    regex pivot-longer-arguments-list { <pivot-longer-argument>+ % [ [ <list-separator> | <ws> ] <filler-separator>? ] }
    regex pivot-longer-argument { <pivot-longer-id-columns-spec> | <pivot-longer-columns-spec> | <pivot-longer-variable-column-name-spec> | <pivot-longer-value-column-name-spec> }

    rule filler-separator { <and-conjunction>? [ <with-preposition> | <using-preposition> | <for-preposition> ] }

    rule pivot-longer-id-columns-spec { <?{$*IDCOLS == 0}> <.the-determiner>? <.pivot-id-columns-phrase> <column-specs-list> {$*IDCOLS == 1} }

    rule pivot-longer-columns-spec { <?{$*COLS == 0}> <.the-determiner>? <.pivot-columns-phrase> <column-specs-list> {$*COLS = 1} }

    rule pivot-longer-variable-column-name-spec { <?{$*VARTO == 0}> <.the-determiner>? <.variable-column-name-phrase> <column-spec> {$*VARTO == 0} }

    rule pivot-longer-value-column-name-spec { <?{$*VALTO == 0}> <.the-determiner>? <.value-column-name-phrase> <column-spec> <?{$*VALTO == 0}> }

    # To wider form command
    rule pivot-wider-command { <.convert-verb>? <.to-wide-form-phrase>  <.filler-separator> <pivot-wider-arguments-list> }
    regex pivot-wider-arguments-list { <pivot-wider-argument>+ % [ [ <list-separator> | <ws> ] <filler-separator>? ] }
    regex pivot-wider-argument { <pivot-wider-id-columns-spec> | <pivot-wider-variable-column-spec> | <pivot-wider-value-column-spec> }

    # Same as <pivot-longer-columns-spec>
    rule pivot-wider-id-columns-spec { <.the-determiner>? <.id-columns-phrase> <column-specs-list> }

    # Same as <pivot-longer-variable-column-name-spec>
    rule pivot-wider-variable-column-spec { <.the-determiner>? <.variable-column-phrase> <column-spec> }

    # Same as <pivot-longer-value-column-name-spec>
    rule pivot-wider-value-column-spec { <.the-determiner>? <.value-column-phrase> <column-spec> }

    # Make dictionary command
    rule make-dictionary-command { <.create-directive> <.dictionary-phrase> <.make-dictionary-filler>? <keycol=.column-spec> <.dictionary-relation-symbol> <valcol=.column-spec> }
    rule make-dictionary-filler { [ <for-preposition> | <using-preposition> | <mapping-noun> ] <the-determiner>? <columns>? | <mapping-noun> | <from-preposition> }
    rule dictionary-relation-symbol { <.to-preposition> | <.as-preposition> | <.key-to-symbol> | <.equal-symbol> }

    # Probably have to be in DSL::Shared::Roles .
    # Assign-pairs and as-pairs
    rule assign-pair { <assign-pair-lhs> [ <.assign-to-symbol> ] <assign-pair-rhs> }
    rule as-pair     { <assign-pair-rhs> <.as-preposition>   <assign-pair-lhs> }
    rule assign-pairs-list { <assign-pair>+ % <.list-separator> }
    rule as-pairs-list     { <as-pair>+     % <.list-separator> }
    rule assign-pair-lhs { <mixed-quoted-variable-name> }
    rule assign-pair-rhs { <mixed-quoted-variable-name> | <wl-expr> }

    # Correspondence pairs
    rule key-pairs-list { <key-pair>+ % <.list-separator> }
    rule key-pair { <key-pair-lhs>  [ <.equal-symbol> | <.equal2-symbol> | <.key-to-symbol> | <.equal-relation> ] <key-pair-rhs> }
    rule key-pair-lhs { <mixed-quoted-variable-name> }
    rule key-pair-rhs { <mixed-quoted-variable-name> }
}
