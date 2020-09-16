=begin comment
#==============================================================================
#
#   SQL actions in Raku Perl 6
#   Copyright (C) 2020  Anton Antonov
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
#
#   The actions are implemented for the grammar:
#
#     DataTransformationWorkflowGrammar::Spoken-tidyverse-command
#
#   in the file :
#
#     https://github.com/antononcube/ConversationalAgents/blob/master/EBNF/English/RakuPerl6/DataTransformationWorkflowsGrammar.pm6
#
#==============================================================================
=end comment

use v6;
use DSL::English::DataQueryWorkflows::Grammar;

unit module DSL::English::DataQueryWorkflows::Actions::SQL::Standard;

class DSL::English::DataQueryWorkflows::Actions::SQL::Standard {

	method TOP($/) { make 'SQL not implemented'; }
	# method TOP($/) { make $/.values[0].made; }

	# General
	method dataset-name($/) { make $/.Str; }
	method variable-name($/) { make $/.Str; }
	method list-separator($/) { make ','; }
	method variable-names-list($/) { make $<variable-name>>>.made.join(', '); }
	method quoted-variable-names-list($/) { make $<quoted-variable-name>>>.made.join(', '); }
	method integer-value($/) { make $/.Str; }
	method number-value($/) { make $/.Str; }
	method wl-expr($/) { make $/.Str.substr(1,*-1); }
	method quoted-variable-name($/) {  make $/.values[0].made; }
	method single-quoted-variable-name($/) { make '"' ~ $<variable-name>.made ~ '"'; }
	method double-quoted-variable-name($/) { make '"' ~ $<variable-name>.made ~ '"'; }

	# Trivial
	method trivial-parameter($/) { make $/.values[0].made; }
	method trivial-parameter-none($/) { make 'NA'; }
	method trivial-parameter-empty($/) { make 'c()'; }
	method trivial-parameter-automatic($/) { make 'NULL'; }
	method trivial-parameter-false($/) { make 'FALSE'; }
	method trivial-parameter-true($/) { make 'TRUE'; }

	# Load data
	method data-load-command($/) { make $/.values[0].made; }
	method load-data-table($/) { make '{ data(' ~ $<data-location-spec>.made ~ '); ' ~ $<data-location-spec>.made ~ ' }'; }
	method data-location-spec($/) { make '\'' ~ $/.Str ~ '\''; }
	method use-data-table($/) { make 'USE ' ~ $<variable-name>.made; }

	# Select command
	method select-command($/) { make 'select' => 'SELECT' ~ $<variable-names-list>.made; }

	# Filter commands
	method filter-command($/) { make 'where' => 'WHERE ' ~ $<filter-spec>.made ; }
	method filter-spec($/) { make $<predicates-list>.made; }

	# Mutate command
	method mutate-command($/) { make 'select' => 'select *, ' ~ $<assign-pairs-list>.made; }
	method assign-pairs-list($/) { make $<assign-pair>>>.made.join(', '); }
	method assign-pair($/) { make $<assign-pair-lhs>.made ~ ' AS ' ~ $<assign-pair-rhs>.made; }
	method assign-pair-lhs($/) { make $/.values[0].made; }
	method assign-pair-rhs($/) { make $/.values[0].made; }

	# Group command
	method group-command($/) { make 'group by' => 'GROUP BY ' ~ $<variable-names-list>.made; }

	# Ungroup command
	method ungroup-command($/) { make 'ungroup' => $/.values[0].made; }
	method ungroup-simple-command($/) { make 'Not implemented for SQL.'; }

	# Arrange command
	method arrange-command($/) { make $/.values[0].made; }
	method arrange-simple-spec($/) { make 'sort by' => $<variable-names-list>.made; }
	method arrange-command-ascending($/) { make 'SORT BY ' ~ $<arrange-simple-spec>.made; }
	method arrange-command-descending($/) { make 'SORT BY ' ~ $<arrange-simple-spec>.made ~ ' desc'; }

    # Rename columns command
    method rename-columns-command($/) { make 'rename' => $/.values[0].made; }
    method rename-columns-by-two-lists($/) {
        # I am not very comfortable with splitting the made string here, but it works.
        # Maybe it is better to no not join the elements in <variable-names-list>.
        # Note that here with subst we assume no single quotes are in <quoted-variable-names-list>.made .
        my @currentNames = $<current>.made.subst(:g, '"', '').split(', ');
        my @newNames = $<new>.made.subst(:g, '"', '').split(', ');

        if @currentNames.elems != @newNames.elems {
            note 'Same number of current and new column names are expected for column renaming.';
            make 'SELECT *';
        } else {
            my $pairs = do for @currentNames Z @newNames -> ($c, $n) { $n ~ ' = ' ~ $c };
            make 'SELECT ' ~ $pairs.join(', ');
        }
    }

    # Drop columns command
    method drop-columns-command($/) { make 'drop column' => $/.values[0].made; }
    method drop-columns-simple($/) {
        # Note that here we assume no single quotes are in <quoted-variable-names-list>.made .
        my $todropLocal = $<todrop>.made.subst(:g, '"', '');
        make 'ALTER TABLE obj DROP COLUMN ' ~ $todropLocal;
    }

	# Statistics command
	method statistics-command($/) { make 'statistics' => $/.values[0].made; }
	method count-command($/) { make 'select count(*)'; }
	method summarize-data($/) { make '( function(x) { print(summary(x)); x } )'; }
	method glimpse-data($/) { make 'dplyr::glimpse()'; }
	method summarize-all-command($/) { make 'dplyr::summarise_all(mean)'; }

	# Join command
	method join-command($/) { make 'join' => $/.values[0].made; }

	method join-by-spec($/) { make 'c(' ~ $/.values[0].made ~ ')'; }

	method full-join-spec($/)  {
      if $<join-by-spec> {
		  make 'full_join(' ~ $<dataset-name>.made ~ ', by = ' ~ $<join-by-spec>.made ~ ')';
      } else {
		  make 'full_join(' ~ $<dataset-name>.made ~ ')';
      }
	}

	method inner-join-spec($/)  {
		if $<join-by-spec> {
			make 'INNER JOIN ' ~ $<dataset-name>.made ~ ' ON ' ~ $<join-by-spec>.made;
		} else {
			make 'INNER JOIN ' ~ $<dataset-name>.made;
		}
	}

	method left-join-spec($/)  {
		if $<join-by-spec> {
			make 'left_join(' ~ $<dataset-name>.made ~ ', by = ' ~ $<join-by-spec>.made ~ ')';
		} else {
			make 'left_join(' ~ $<dataset-name>.made ~ ')';
		}
	}

	method right-join-spec($/)  {
		if $<join-by-spec> {
			make 'right_join(' ~ $<dataset-name>.made ~ ', by = ' ~ $<join-by-spec>.made ~ ')';
		} else {
			make 'right_join(' ~ $<dataset-name>.made ~ ')';
		}
	}

	method semi-join-spec($/)  {
		if $<join-by-spec> {
			make 'semi_join(' ~ $<dataset-name>.made ~ ', by = ' ~ $<join-by-spec>.made ~ ')';
		} else {
			make 'semi_join(' ~ $<dataset-name>.made ~ ')';
		}
	}

	# Cross tabulate command
	method cross-tabulation-command($/) { make $/.values[0].made; }
	method cross-tabulate-command($/) { $<cross-tabulation-formula>.made }
	method contingency-matrix-command($/) { $<cross-tabulation-formula>.made }
	method cross-tabulation-formula($/) {
		if $<values-variable-name> {
			make '(function(x) as.data.frame(xtabs( formula = ' ~ $<values-variable-name>.made ~ ' ~ ' ~ $<rows-variable-name>.made ~ ' + ' ~ $<columns-variable-name>.made ~ ', data = x ), stringsAsFactors=FALSE ))';
		} else {
			make '(function(x) as.data.frame(xtabs( formula = ~ ' ~ $<rows-variable-name>.made ~ ' + ' ~ $<columns-variable-name>.made ~ ', data = x ), stringsAsFactors=FALSE ))';
		}
	}
	method rows-variable-name($/) { make $<variable-name>.made; }
	method columns-variable-name($/) { make $<variable-name>.made; }
	method values-variable-name($/) { make $<variable-name>.made; }

    # Reshape command
    method reshape-command($/) { make $/.values[0].made; }

    # Pivot longer command
    method pivot-longer-command($/) { make 'pivot longer' => 'Not implemented for SQL'; }

    # Pivot wider command
    method pivot-wider-command($/) { make 'pivot wider' => 'Not implemented for SQL'; }

    # Pipeline command
    method pipeline-command($/) { make 'pipeline' => 'Not implemented for SQL'; }
}
