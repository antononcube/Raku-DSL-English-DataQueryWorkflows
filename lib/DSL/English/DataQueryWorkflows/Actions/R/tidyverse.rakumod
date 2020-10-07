=begin comment
#==============================================================================
#
#   Data Query Workflows R-tidyverse actions in Raku (Perl 6)
#   Copyright (C) 2018, 2020  Anton Antonov
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
#   For more details about Raku (Perl6) see https://raku.org/ .
#
#==============================================================================
#
#   The actions are implemented for the grammar:
#
#     DataTransformationWorkflowGrammar::Spoken-dplyr-command
#
#   in the file :
#
#     https://github.com/antononcube/ConversationalAgents/blob/master/EBNF/English/RakuPerl6/DataTransformationWorkflowsGrammar.pm6
#
#==============================================================================
=end comment

use v6;
use DSL::English::DataQueryWorkflows::Grammar;
use DSL::Shared::Actions::R::PredicateSpecification;
use DSL::Shared::Actions::English::R::PipelineCommand;

unit module DSL::English::DataQueryWorkflows::Actions::R::tidyverse;

class DSL::English::DataQueryWorkflows::Actions::R::tidyverse
        is DSL::Shared::Actions::R::PredicateSpecification
		is DSL::Shared::Actions::English::R::PipelineCommand {

	has Str $.name = 'DSL-English-DataQueryWorkflows-R-tidyverse';

	method TOP($/) { make $/.values[0].made; }

	# General
	method variable-names-list($/) { make $<variable-name>>>.made.join(', '); }
	method quoted-variable-names-list($/) { make $<quoted-variable-name>>>.made.join(', '); }
	method mixed-quoted-variable-names-list($/) { make $<mixed-quoted-variable-name>>>.made.join(', '); }

	# Column specs
    method column-specs-list($/) { make $<column-spec>>>.made.join(', '); }
    method column-spec($/) {  make $/.values[0].made; }
    method column-name-spec($/) { make $<mixed-quoted-variable-name>.made.subst(:g, '"', ''); }

	# Load data
	method data-load-command($/) { make $/.values[0].made; }
	method load-data-table($/) { make '{ data(' ~ $<data-location-spec>.made ~ '); ' ~ $<data-location-spec>.made ~ ' }'; }
	method data-location-spec($/) { make '\'' ~ $/.Str ~ '\''; }
	method use-data-table($/) { make $<variable-name>.made; }

	# Distinct command
	method distinct-command($/) { make $/.values[0].made; }
	method distinct-simple-command($/) { make 'dplyr::distinct()'; }

	# Missing treatment command
	method missing-treatment-command($/) { make $/.values[0].made; }
	method drop-incomplete-cases-command($/) { make 'na.omit()'; }
	method replace-missing-command($/) { make 'tidyr::replace_na( ' ~ $<replace-missing-rhs>.made ~ ' )'; }
    method replace-missing-rhs($/) { make $/.values[0].made; }

	# Select command
	method select-command($/) { make $/.values[0].made; }
	method select-columns-simple($/) { make 'dplyr::select(' ~ $/.values[0].made ~ ')'; }
	method select-columns-by-two-lists($/) {
		# I am not very comfortable with splitting the made string here, but it works.
        # Maybe it is better to no not join the elements in <variable-names-list>.
        # Note that here with subst we assume no single quotes are in <mixed-quoted-variable-names-list>.made .
        my @currentNames = $<current>.made.subst(:g, '"', '').split(', ');
        my @newNames = $<new>.made.subst(:g, '"', '').split(', ');

        if @currentNames.elems != @newNames.elems {
            note 'Same number of current and new column names are expected for column selection with renaming.';
            make 'dplyr::mutate()';
        } else {
            my $pairs = do for @currentNames Z @newNames -> ($c, $n) { $n ~ ' = ' ~ $c };
            make 'dplyr::select( ' ~ $pairs.join(', ') ~ ' )';
        }
    }
    method select-columns-by-pairs($/) { make 'dplyr::select(' ~ $<as-pairs-list>.made ~ ')'; }

	# Filter commands
	method filter-command($/) { make 'dplyr::filter(' ~ $<filter-spec>.made ~ ')'; }
	method filter-spec($/) { make $<predicates-list>.made; }
	
	# Mutate command
	method mutate-command($/) { make $/.values[0].made; }
    method mutate-by-two-lists($/) {
		my @currentNames = $<current>.made.subst(:g, '"', '').split(', ');
        my @newNames = $<new>.made.subst(:g, '"', '').split(', ');

        if @currentNames.elems != @newNames.elems {
            note 'Same number of current and new column names are expected for mutation by two lists.';
            make 'dplyr::mutate()';
        } else {
            my $pairs = do for @currentNames Z @newNames -> ($c, $n) { $n ~ ' = ' ~ $c };
            make 'dplyr::mutate(' ~ $pairs.join(', ') ~ ')';
        }
	}
	method mutate-by-pairs($/) { make 'dplyr::mutate(' ~ $/.values[0].made ~ ')'; }

    # Group command
    method group-command($/) { make $/.values[0].made; }
	method group-by-command($/) { make 'dplyr::group_by(' ~ $/.values[0].made ~ ')'; }
	method group-map-command($/) { make 'dplyr::group_map( ' ~ $/.values[0].made ~ ' )'; }

	# Ungroup command
	method ungroup-command($/) { make $/.values[0].made; }
	method ungroup-simple-command($/) { make 'ungroup() %>% as.data.frame(stringsAsFactors=FALSE)'; }
	
	# Arrange command
	method arrange-command($/) { make $/.values[0].made; }
	method arrange-simple-command($/) {
		make $<reverse-sort-phrase> || $<descending> ?? 'dplyr::arrange(desc(.))' !! 'dplyr::arrange()';
	}
	method arrange-by-spec($/) { make $/.values[0].made; }
	method arrange-by-command-ascending($/) { make 'dplyr::arrange(' ~ $<arrange-by-spec>.made ~ ')'; }
	method arrange-by-command-descending($/) { make 'dplyr::arrange(desc(' ~ $<arrange-by-spec>.made ~ '))'; }

    # Rename columns command
    method rename-columns-command($/) { make $/.values[0].made; }
    method rename-columns-by-two-lists($/) {
        # I am not very comfortable with splitting the made string here, but it works.
        # Maybe it is better to no not join the elements in <variable-names-list>.
        # Note that here with subst we assume no single quotes are in <mixed-quoted-variable-names-list>.made .
        my @currentNames = $<current>.made.subst(:g, '"', '').split(', ');
        my @newNames = $<new>.made.subst(:g, '"', '').split(', ');

        if @currentNames.elems != @newNames.elems {
            note 'Same number of current and new column names are expected for column renaming.';
            make 'dplyr::rename()';
        } else {
            my $pairs = do for @currentNames Z @newNames -> ($c, $n) { $n ~ ' = ' ~ $c };
            make 'dplyr::rename(' ~ $pairs.join(', ') ~ ')';
        }
    }
    method rename-columns-by-pairs($/) { make 'dplyr::rename(' ~ $<as-pairs-list>.made ~ ')'; }

    # Drop columns command
    method drop-columns-command($/) { make $/.values[0].made; }
    method drop-columns-simple($/) {
        # Note that here we assume no single quotes are in <mixed-quoted-variable-names-list>.made .
        my @todrop = $<todrop>.made.subst(:g, '"', '').split(', ');
        make 'dplyr::mutate( ' ~ map( { $_ ~ '= NULL' }, @todrop ).join(', ') ~ ' )';
    }

	# Statistics command
	method statistics-command($/) { make $/.values[0].made; }
	method data-dimensions-command($/) { make '( function(x) { print(dim(x)); x } )'; }
	method count-command($/) { make 'dplyr::count()'; }
	method data-summary-command($/) { make '( function(x) { print(summary(x)); x } )'; }
	method glimpse-data($/) { make 'dplyr::glimpse()'; }

	# Summarize command
    method summarize-command($/) { make $/.values[0].made; }
	method summarize-by-pairs($/) { make 'dplyr::summarize(' ~ $/.values[0].made ~ ')'; }
	method summarize-all-command($/) {
		if $<summarize-funcs-spec> {
			make 'dplyr::summarise_all( .funs = ' ~ $<summarize-funcs-spec>.made ~ ' )';
		} else {
			make 'dplyr::summarise_all(mean)';
		}
	}
	method summarize-at-command($/) {
		my $cols = 'c(' ~ map( { '"' ~ $_ ~ '"' }, $<cols>.made.split(', ') ).join(', ') ~ ')';
		if $<summarize-funcs-spec> {
			make 'dplyr::summarise_at( .vars = ' ~ $cols ~ ', ' ~ '.funs = ' ~ $<summarize-funcs-spec>.made ~ ' )';
		} else {
			make 'dplyr::summarise_at( .vars = ' ~ $cols ~ ', .funs = c( Min = function(.) min(., na.rm = T), Max = function(.) max(., na.rm = T), Mean = function(.) mean(., na.rm = T), Median = function(.) median(., na.rm = T), Sum = function(.) sum(., na.rm = T) ) )';
		}
	}
	method summarize-funcs-spec($/) { make 'c(' ~ map( { $_ ~ ' = ' ~ $_ }, $<variable-name-or-wl-expr-list>.made ).join(', ') ~ ')'; }
	
	# Join command
	method join-command($/) { make $/.values[0].made; }
	
	method join-by-spec($/) {
		if $<mixed-quoted-variable-names-list> {
			make 'c(' ~ map( { '"' ~ $_ ~ '"'}, $/.values[0].made.subst(:g, '"', '').split(', ') ).join(', ') ~ ')';
		} else {
			make $/.values[0].made;
		}
	}

	method full-join-spec($/)  {
      if $<join-by-spec> {
		  make 'dplyr::full_join(' ~ $<dataset-name>.made ~ ', by = ' ~ $<join-by-spec>.made ~ ')';
      } else {
		  make 'dplyr::full_join(' ~ $<dataset-name>.made ~ ')';
      }
	}
	
	method inner-join-spec($/)  {
		if $<join-by-spec> {
			make 'dplyr::inner_join(' ~ $<dataset-name>.made ~ ', by = ' ~ $<join-by-spec>.made ~ ')';
		} else {
			make 'dplyr::inner_join(' ~ $<dataset-name>.made ~ ')';
		}
	}
	
	method left-join-spec($/)  {
		if $<join-by-spec> {
			make 'dplyr::left_join(' ~ $<dataset-name>.made ~ ', by = ' ~ $<join-by-spec>.made ~ ')';
		} else {
			make 'dplyr::left_join(' ~ $<dataset-name>.made ~ ')';
		}
	}
	
	method right-join-spec($/)  {
		if $<join-by-spec> {
			make 'dplyr::right_join(' ~ $<dataset-name>.made ~ ', by = ' ~ $<join-by-spec>.made ~ ')';
		} else {
			make 'dplyr::right_join(' ~ $<dataset-name>.made ~ ')';
		}
	}
	
	method semi-join-spec($/)  {
		if $<join-by-spec> {
			make 'dplyr::semi_join(' ~ $<dataset-name>.made ~ ', by = ' ~ $<join-by-spec>.made ~ ')';
		} else {
			make 'dplyr::semi_join(' ~ $<dataset-name>.made ~ ')';
		}
	}
	
	# Cross tabulate command
	method cross-tabulation-command($/) { make $/.values[0].made; }
	method cross-tabulate-command($/) { $<cross-tabulation-formula>.made }
	method contingency-matrix-command($/) { $<cross-tabulation-formula>.made }
	method cross-tabulation-formula($/) { make $/.values[0].made; }
	method cross-tabulation-double-formula($/) {
		if $<values-variable-name> {
			make '(function(x) as.data.frame(xtabs( formula = ' ~ $<values-variable-name>.made ~ ' ~ ' ~ $<rows-variable-name>.made ~ ' + ' ~ $<columns-variable-name>.made ~ ', data = x ), stringsAsFactors=FALSE ))';
		} else {
			make '(function(x) as.data.frame(xtabs( formula = ~ ' ~ $<rows-variable-name>.made ~ ' + ' ~ $<columns-variable-name>.made ~ ', data = x ), stringsAsFactors=FALSE ))';
		}
	}
	method cross-tabulation-single-formula($/) {
		if $<values-variable-name> {
			make '(function(x) as.data.frame(xtabs( formula = ' ~ $<values-variable-name>.made ~ ' ~ ' ~ $<rows-variable-name>.made ~ ', data = x ), stringsAsFactors=FALSE ))';
		} else {
			make '(function(x) as.data.frame(xtabs( formula = ~ ' ~ $<rows-variable-name>.made ~ ', data = x ), stringsAsFactors=FALSE ))';
		}
	}
    method rows-variable-name($/) { make $/.values[0].made.subst(:g, '"', ''); }
    method columns-variable-name($/) { make $/.values[0].made.subst(:g, '"', ''); }
    method values-variable-name($/) { make $/.values[0].made.subst(:g, '"', ''); }

    # Reshape command
    method reshape-command($/) { make $/.values[0].made; }

    # Pivot longer command
    method pivot-longer-command($/) {
		if $<pivot-longer-arguments-list> {
			make 'tidyr::pivot_longer( ' ~ $<pivot-longer-arguments-list>.made ~ ' )';
		} else {
			make 'dplyr::mutate_all(.funs = as.character) %>% tidyr::pivot_longer( cols = -1, names_to = "Variable", values_to = "Value")';
		}
	}
    method pivot-longer-arguments-list($/) { make $<pivot-longer-argument>>>.made.join(', '); }
    method pivot-longer-argument($/) { make $/.values[0].made; }

	method pivot-longer-id-columns-spec($/) {
		warn 'The R-tidyverse function tidyr::pivot_longer does not use identifier columns.';
		make '';
	}

    method pivot-longer-columns-spec($/) { make 'cols = c( ' ~ $/.values[0].made ~ ' )'; }

    method pivot-longer-variable-column-name-spec($/) { make 'names_to = ' ~ $/.values[0].made; }

    method pivot-longer-value-column-name-spec($/) { make 'values_to = ' ~ $/.values[0].made; }

    # Pivot wider command
    method pivot-wider-command($/) { make 'tidyr::pivot_wider(' ~ $<pivot-wider-arguments-list>.made ~ ' )'; }
    method pivot-wider-arguments-list($/) { make $<pivot-wider-argument>>>.made.join(', '); }
    method pivot-wider-argument($/) { make $/.values[0].made; }

    method pivot-wider-id-columns-spec($/) { make 'id_cols = c( ' ~ $/.values[0].made ~ ' )'; }

    method pivot-wider-variable-column-spec($/) { make 'names_from = ' ~ $/.values[0].made; }

    method pivot-wider-value-column-spec($/) { make 'values_from = ' ~ $/.values[0].made; }

	# Separate string column command
	method separate-column-command($/) {
		my $intocols = map( { '"' ~ $_.subst(:g, '"', '') ~ '"' }, $<into>.made.split(', ') ).join(', ');
		if $<sep> {
			make 'tidyr::separate( col = ' ~ $<col>.made ~ ', into = c(' ~ $intocols ~ '), sep = ' ~ $<sep>.made ~ ' )';
		} else {
			make 'tidyr::separate( col = ' ~ $<col>.made ~ ', into = c(' ~ $intocols ~ ') )';
		}
	}
	method separator-spec($/) { make $/.values[0].made; }

	# Make dictionary command
    method make-dictionary-command($/) { make 'dplyr::select( ' ~ $<keycol>.made ~', ' ~ $<valcol>.made ~ ' )';}

	# Probably have to be in DSL::Shared::Actions .
    # Assign-pairs and as-pairs
	method assign-pairs-list($/) { make $<assign-pair>>>.made.join(', '); }
	method as-pairs-list($/)     { make $<as-pair>>>.made.join(', '); }
	method assign-pair($/) { make $<assign-pair-lhs>.made ~ ' = ' ~ $<assign-pair-rhs>.made; }
	method as-pair($/)     { make $<assign-pair-lhs>.made ~ ' = ' ~ $<assign-pair-rhs>.made; }
	method assign-pair-lhs($/) { make $/.values[0].made.subst(:g, '"', ''); }
	method assign-pair-rhs($/) {
        if $<mixed-quoted-variable-name> {
            make $/.values[0].made.subst(:g, '"', '');
        } else {
            make $/.values[0].made
        }
    }

	# Correspondence pairs
    method key-pairs-list($/) { make $<key-pair>>>.made.join(', '); }
    method key-pair($/) { make $<key-pair-lhs>.made ~ ' = ' ~ $<key-pair-rhs>.made; }
    method key-pair-lhs($/) { make '"' ~ $/.values[0].made.subst(:g, '"', '') ~ '"'; }
    method key-pair-rhs($/) { make '"' ~ $/.values[0].made.subst(:g, '"', '') ~ '"'; }

    # Pipeline command
    method pipeline-command($/) { make $/.values[0].made; }
    method take-pipeline-value($/) { make 'as.data.frame()'; }
    method echo-pipeline-value($/) { make '(function(x) { print(x); x})'; }

    method echo-command($/) { make '(function(x){ print( ' ~ $<echo-message-spec>.made ~ ' ); x })'; }
    method echo-message-spec($/) { make $/.values[0].made; }
    method echo-words-list($/) { make '"' ~ $<variable-name>>>.made.join(' ') ~ '"'; }
    method echo-variable($/) { make $/.Str; }
    method echo-text($/) { make $/.Str; }
}
