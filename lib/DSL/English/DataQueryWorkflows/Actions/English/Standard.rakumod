=begin comment
#==============================================================================
#
#   Data Query Workflows English DSL actions in Raku (Perl 6)
#   Copyright (C) 2022  Anton Antonov
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
#   ʇǝu˙oǝʇsod@ǝqnɔuouoʇuɐ,
#   Windermere, Florida, USA.
#
#==============================================================================
#
#   For more details about Raku (Perl6) see https://raku.org/ .
#
#==============================================================================
=end comment

use v6.d;

use DSL::English::DataQueryWorkflows::Actions::English::Predicate;
use DSL::Shared::Actions::English::PipelineCommand;
use DSL::Shared::Actions::English::Standard::ListManagementCommand;

class DSL::English::DataQueryWorkflows::Actions::English::Standard
		does DSL::Shared::Actions::English::Standard::ListManagementCommand
		is DSL::Shared::Actions::English::PipelineCommand
        is DSL::English::DataQueryWorkflows::Actions::English::Predicate {

	has Str $.name = 'DSL-English-DataQueryWorkflows-English-Standard';

    # Top
    method TOP($/) { make $/.values[0].made; }

    # workflow-command-list
    method workflow-commands-list($/) { make $/.values>>.made.join(";\n"); }

    # workflow-command
    method workflow-command($/) { make $/.values[0].made; }

	# General
	method variable-names-list($/) { make $<variable-name>>>.made.join(', '); }
	method quoted-variable-names-list($/) { make $<quoted-variable-name>>>.made.join(', '); }
	method mixed-quoted-variable-names-list($/) { make $<mixed-quoted-variable-name>>>.made.join(', '); }

	# Column specs
    method column-specs-list($/) { make $<column-spec>>>.made.join(', '); }
    method column-spec($/) {  make $/.values[0].made; }
    method column-name-spec($/) { make '"' ~ $<mixed-quoted-variable-name>.made.subst(:g, '"', '') ~ '"'; }

	# Load data
	method data-load-command($/) { make $/.values[0].made; }
	method load-data-table($/) { make 'load the data table: ' ~ $<data-location-spec>.made; }
	method data-location-spec($/) {
		make $<regex-pattern-spec> ?? $<regex-pattern-spec>.made !! '"' ~ self.unquote($/.Str) ~ '"';
	}
	method use-data-table($/) { make 'use the data table: ' ~ $<mixed-quoted-variable-name>.made; }

	# Distinct command
	method distinct-command($/) { make $/.values[0].made; }
	method distinct-simple-command($/) { make 'unique rows'; }

	# Missing treatment command
	method missing-treatment-command($/) { make $/.values[0].made; }
	method drop-incomplete-cases-command($/) { make 'drop incomplete cases'; }
	method replace-missing-command($/) { make 'replace missing values with ' ~ $<replace-missing-rhs>.made; }
    method replace-missing-rhs($/) { make $/.values[0].made; }

	# Replace command
    method replace-command($/) { make 'replace ' ~ $<lhs>.made ~ ' с ' ~ $<rhs>.made ; }

	# Select command
	method select-command($/) { make $/.values[0].made; }
	method select-columns-simple($/) { make 'select the columns: ' ~ $/.values[0].made; }
	method select-columns-by-two-lists($/) { make 'select the columns ' ~ $<current>.made ~ ' and rename as ' ~ $<new>.made; }
    method select-columns-by-pairs($/) { make 'rename and select the columns with ' ~ $/.values[0].made; }

	# Filter commands
	method filter-command($/) { make 'filter with the predicate: ' ~ $<filter-spec>.made; }
	method filter-spec($/) { make $<predicates-list>.made; }

	# Mutate command
	method mutate-command($/) { make $/.values[0].made; }
	method mutate-by-two-lists($/) { make 'assign to the columns ' ~ $<current>.made ~ ' the values ' ~ $<new>.made; }
	method mutate-by-pairs($/) { make 'assign: ' ~ $/.values[0].made; }

    # Group command
    method group-command($/) { make $/.values[0].made; }
	method group-by-command($/) { make 'group by the columns: ' ~ $/.values[0]; }
	method group-map-command($/) { make 'apply to each group: ' ~ $/.values[0].made; }

	# Ungroup command
	method ungroup-command($/) { make $/.values[0].made; }
	method ungroup-simple-command($/) { make 'ungroup'; }

	# Arrange command
	method arrange-command($/) { make $/.values[0].made; }
	method arrange-simple-command($/) {
        make $<reverse-sort-phrase> || $<descending-phrase> ?? 'sort in descending order' !! 'sort';
    }
	method arrange-by-spec($/) { make $/.values[0].made; }
	method arrange-by-command-ascending($/) { make 'sort with the columns: ' ~ $<arrange-by-spec>.made; }
	method arrange-by-command-descending($/) { make 'sort in descending order with the columns: ' ~ $<arrange-by-spec>.made; }

    # Rename columns command
    method rename-columns-command($/) { make $/.values[0].made; }
    method rename-columns-by-two-lists($/) {
        make 'rename the columns ' ~ $<current>.made ~ ' as ' ~ $<new>.made;
    }
    method rename-columns-by-pairs($/) { make 'rename columns with ' ~ $/.values[0].made; }

    # Drop columns command
    method drop-columns-command($/) { make $/.values[0].made; }
    method drop-columns-simple($/) {
        make 'drop the columns ' ~ $<todrop>.made;
    }

	# Statistics command
	method statistics-command($/) { make $/.values[0].made; }
	method data-dimensions-command($/) { make 'show dimensions'; }
	method count-command($/) { make 'find the count(s)'; }
	method echo-count-command($/) { make 'show the count(s)'; }
	method data-summary-command($/) { make 'summarize the object'; }
	method glimpse-data($/) { make 'show glimpse of the object'; }

	# Summarize command
    method summarize-command($/) { make $/.values[0].made; }
	method summarize-by-pairs($/) { make 'summarize with the formulas: ' ~ $/.values[0].made; }
	method summarize-all-command($/) {
		if $<summarize-funcs-spec> {
			make 'apply to each columns the functions: ' ~ $<summarize-funcs-spec>.made;
		} else {
			make 'find the average values of all columns';
		}
	}
	method summarize-at-command($/) { make 'summarize the columns: ' ~ $<cols>.made ~ ' with the functions: ' ~ $<summarize-funcs-spec>.made; }
	method summarize-funcs-spec($/) { make $<variable-name-or-wl-expr-list>.made.join(', '); }

	# Join command
	method join-command($/) { make $/.values[0].made; }

	method join-by-spec($/) { make '(' ~ $/.values[0].made ~ ')'; }

	method full-join-spec($/)  {
		if $<join-by-spec> {
			make 'full join with ' ~ $<dataset-name>.made ~ ' by ' ~ $<join-by-spec>.made;
		} else {
			make 'full join with  ' ~ $<dataset-name>.made;
		}
	}

	method inner-join-spec($/)  {
		if $<join-by-spec> {
			make 'inner join with ' ~ $<dataset-name>.made ~ ' by ' ~ $<join-by-spec>.made;
		} else {
			make 'inner join with ' ~ $<dataset-name>.made;
		}
	}

	method left-join-spec($/)  {
		if $<join-by-spec> {
			make 'left join with ' ~ $<dataset-name>.made ~ ' by ' ~ $<join-by-spec>.made;
		} else {
			make 'left join with ' ~ $<dataset-name>.made;
		}
	}

	method right-join-spec($/)  {
		if $<join-by-spec> {
			make 'right join with ' ~ $<dataset-name>.made ~ ' by ' ~ $<join-by-spec>.made;
		} else {
			make 'right join with ' ~ $<dataset-name>.made;
		}
	}

	method semi-join-spec($/)  {
		if $<join-by-spec> {
			make 'semi-join with ' ~ $<dataset-name>.made ~ ' by ' ~ $<join-by-spec>.made;
		} else {
			make 'semi-join with ' ~ $<dataset-name>.made;
		}
	}

	# Cross tabulate command
	method cross-tabulation-command($/) { make $/.values[0].made; }
	method cross-tabulate-command($/) { $<cross-tabulation-formula>.made }
	method contingency-matrix-command($/) { $<cross-tabulation-formula>.made }
	method cross-tabulation-formula($/) { make $/.values[0].made; }
	method cross-tabulation-double-formula($/) {
		if $<values-variable-name> {
			make 'cross tabulate with rows from ' ~ $<rows-variable-name>.made ~ ', columns from ' ~ $<columns-variable-name>.made ~ ' and values from ' ~ $<values-variable-name>;
		} else {
			make 'cross tabulate with rows from ' ~ $<rows-variable-name>.made ~ ', columns from ' ~ $<columns-variable-name>.made;
		}
	}
	method cross-tabulation-single-formula($/) {
		if $<values-variable-name> {
			make 'cross tabulate with rows from  ' ~ $<rows-variable-name>.made ~ ' and values from ' ~ $<values-variable-name>;
		} else {
			make 'cross tabulate with rows from  ' ~ $<rows-variable-name>.made;
		}
	}
    method rows-variable-name($/) { make $/.values[0].made; }
    method columns-variable-name($/) { make $/.values[0].made; }
    method values-variable-name($/) { make $/.values[0].made; }

	# Reshape command
    method reshape-command($/) { make $/.values[0].made; }

	# Pivot longer command
    method pivot-longer-command($/) {
		if  $<pivot-longer-arguments-list> {
			make 'convert to long format ' ~ $<pivot-longer-arguments-list>.made;
		} else {
			make 'convert to long format';
		}
	}
    method pivot-longer-arguments-list($/) { make $<pivot-longer-argument>>>.made.join(', '); }
    method pivot-longer-argument($/) { make $/.values[0].made; }

    method pivot-longer-id-columns-spec($/) { make 'id columns ' ~ $/.values[0].made; }

    method pivot-longer-columns-spec($/) { make 'columns ' ~ $/.values[0].made; }

    method pivot-longer-variable-column-name-spec($/) { make 'variable column ' ~ $/.values[0].made; }

    method pivot-longer-value-column-name-spec($/) { make 'value column ' ~ $/.values[0].made; }

    # Pivot wider command
    method pivot-wider-command($/) { make 'conver to wider format ' ~ $<pivot-wider-arguments-list>.made; }
    method pivot-wider-arguments-list($/) { make $<pivot-wider-argument>>>.made.join(', '); }
    method pivot-wider-argument($/) { make $/.values[0].made; }

    method pivot-wider-id-columns-spec($/) { make 'id columns ' ~ $/.values[0].made; }

    method pivot-wider-variable-column-spec($/) { make 'variable column ' ~ $/.values[0].made; }

    method pivot-wider-value-column-spec($/) { make 'value column ' ~ $/.values[0].made; }

	# Separate string column command
	method separate-column-command($/) {
		my $intocols = map( { '"' ~ $_.subst(:g, '"', '') ~ '"' }, $<into>.made.split(', ') ).join(', ');

		if $<sep> {
			make 'separate the values of the column ' ~ $<col>.made ~ ' into the columns ' ~ $intocols ~ ', with separator ' ~ $<sep>.made;
		} else {
			make 'separate the values of the column ' ~ $<col>.made ~ ' into the columns ' ~ $intocols;
		}
	}
	method separator-spec($/) { make $/.values[0].made; }

	# Make dictionary command
    method make-dictionary-command($/) { make 'make dictionary from the column '  ~ $<keycol>.made ~' to the column ' ~ $<valcol>.made;}

    # Probably have to be in DSL::Shared::Actions .
    # Assign-pairs and as-pairs
	method assign-pairs-list($/) { make $<assign-pair>>>.made.join(', '); }
	method as-pairs-list($/)     { make $<as-pair>>>.made.join(', '); }
	method assign-pair($/) { make $<assign-pair-lhs>.made ~ ' = ' ~ $<assign-pair-rhs>.made; }
	method as-pair($/)     { make $<assign-pair-lhs>.made ~ ' = ' ~ $<assign-pair-rhs>.made; }
	method assign-pair-lhs($/) { make $/.values[0].made; }
	method assign-pair-rhs($/) {
        if $<mixed-quoted-variable-name> {
            make '"' ~ $/.values[0].made.subst(:g, '"', '') ~ '"';
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
    method take-pipeline-value($/) { make 'take object'; }
    method echo-pipeline-value($/) { make 'echo pipeline value'; }

    method echo-command($/) { make 'print the message: ' ~ $<echo-message-spec>.made; }
    method echo-message-spec($/) { make $/.values[0].made; }
    method echo-words-list($/) { make '"' ~ $<variable-name>>>.made.join(' ') ~ '"'; }
    method echo-variable($/) { make $/.Str; }
    method echo-text($/) { make $/.Str; }
}
