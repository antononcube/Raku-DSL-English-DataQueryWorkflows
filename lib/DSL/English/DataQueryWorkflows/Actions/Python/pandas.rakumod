=begin comment
#==============================================================================
#
#   Data Query Workflows Python-pandas actions in Raku (Perl 6)
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
#   For more details about Raku (Perl6) see https://raku.org/ .
#
#==============================================================================
=end comment

use v6;
use DSL::English::DataQueryWorkflows::Grammar;
use DSL::Shared::Actions::Python::PredicateSpecification;
use DSL::Shared::Actions::English::Python::PipelineCommand;

unit module DSL::English::DataQueryWorkflows::Actions::Python::pandas;

class DSL::English::DataQueryWorkflows::Actions::Python::pandas
        is DSL::Shared::Actions::Python::PredicateSpecification
		is DSL::Shared::Actions::English::Python::PipelineCommand {

	method TOP($/) { make $/.values[0].made; }

    # Overriding Predicate::predicate-simple -- wrapping the lhs variable specs with 'obj[...]'.
	method predicate-simple($/) {
		if $<predicate-relation>.made eq '%!in%' {
			make '!( obj[' ~ $<lhs>.made ~ '] %in% ' ~ $<rhs>.made ~ ')';
		} elsif $<predicate-relation>.made eq 'like' {
			make 'grepl( pattern = ' ~ $<rhs>.made ~ ', x = obj$' ~ $<lhs>.made ~ ')';
		} else {
			make 'obj[' ~ $<lhs>.made ~ '] ' ~ $<predicate-relation>.made ~ ' ' ~ $<rhs>.made;
		}
	}

	# General
	method variable-names-list($/) { make $<variable-name>>>.made.join(', '); }
	method quoted-variable-names-list($/) { make $<quoted-variable-name>>>.made.join(', '); }
	method mixed-quoted-variable-names-list($/) { make $<mixed-quoted-variable-name>>>.made.join(', '); }

	# Trivial
	method trivial-parameter($/) { make $/.values[0].made; }
	method trivial-parameter-none($/) { make 'None'; }
	method trivial-parameter-empty($/) { make '[]'; }
	method trivial-parameter-automatic($/) { make 'None'; }
	method trivial-parameter-false($/) { make 'False'; }
	method trivial-parameter-true($/) { make 'True'; }

	# Load data
	method data-load-command($/) { make $/.values[0].made; }
	method load-data-table($/) { make '{ data(' ~ $<data-location-spec>.made ~ '); obj =' ~ $<data-location-spec>.made ~ ' }'; }
	method data-location-spec($/) { make '\'' ~ $/.Str ~ '\''; }
	method use-data-table($/) { make 'obj = ' ~ $<variable-name>.made; }

	# Distinct command
	method distinct-command($/) { make $/.values[0].made; }
	method distinct-simple-command($/) { make 'obj = obj.drop_duplicates()'; }

	# Missing treatment command
	method missing-treatment-command($/) { make $/.values[0].made; }
	method drop-incomplete-cases-command($/) { make 'obj = na_omit(obj)'; }
	method replace-missing-command($/) { make 'obj = obj.replace( numpy.nan,' ~ $<replace-missing-rhs>.made ; }

    # Select command
	method select-command($/) { make $/.values[0].made; }
	method select-plain-variables($/) { make 'obj = obj[[' ~ map( {'"' ~ $_ ~ '"' }, $<variable-names-list>.made.split(', ') ).join(', ') ~ ']]'; }
	method select-mixed-quoted-variables($/) { make 'obj = obj[[' ~ $<mixed-quoted-variable-names-list>.made.join(', ') ~ ']]'; }

    # Filter commands
	method filter-command($/) { make 'obj = obj[' ~ $<filter-spec>.made ~ ']'; }
	method filter-spec($/) { make $<predicates-list>.made; }

    # Mutate command
	method mutate-command($/) { make $<assign-pairs-list>.made; }

    # Group command
	method group-command($/) { make 'obj = obj ( data = obj, ' ~ $<variable-names-list>.made ~ ')'; }

    # Ungroup command
	method ungroup-command($/) { make $/.values[0].made; }
	method ungroup-simple-command($/) { make 'print("Ungrouping is not implemented; there is no ungroup operation in Python-pandas.")'; }

    # Arrange command
	method arrange-command($/) { make $/.values[0].made; }
	method arrange-simple-spec($/) { make '[' ~ $<mixed-quoted-variable-names-list>.made.join(', ') ~ ']'; }
	method arrange-command-ascending($/) { make 'obj = obj.sort_values( ' ~ $<arrange-simple-spec>.made ~ ' )'; }
	method arrange-command-descending($/) { make 'obj = obj.sort_values( ' ~ $<arrange-simple-spec>.made ~ ', ascending = False )'; }

    # Rename columns command
    method rename-columns-command($/) { make $/.values[0].made; }
	method rename-columns-simple($/) {
        # I am not very comfortable with splitting the made string here, but it works.
        # Maybe it is better to no not join the elements in <variable-names-list>.
        # Note that here with subst we assume no single quotes are in <mixed-quoted-variable-names-list>.made .
        my @currentNames = $<current>.made.subst(:g, '"', '').split(', ');
        my @newNames = $<new>.made.subst(:g, '"', '').split(', ');

        if @currentNames.elems != @newNames.elems {
            note 'Same number of current and new column names are expected for column renaming.';
            make 'obj';
        } else {
            my $pairs = do for @currentNames Z @newNames -> ($c, $n) { $n ~ ' : ' ~ $c };
            make 'obj = obj.rename( columns = { ' ~ $pairs.join(', ') ~ ' } )';
        }
    }
    method rename-columns-by-pairs($/) { make $/.values[0].made; }

    # Drop columns command
    method drop-columns-command($/) { make $/.values[0].made; }
    method drop-columns-simple($/) {
        my @todrop = $<todrop>.made.split(', ');
        make 'obj = obj.drop( [' ~ $<todrop>.made.join(', ') ~ '] )';
    }

    # Statistics command
	method statistics-command($/) { make $/.values[0].made; }
	method count-command($/) { make 'tidyverse::count()'; }
	method summarize-data($/) { make 'print(obj.describe())'; }
	method glimpse-data($/) { make 'print(obj.head())'; }
	method summarize-all-command($/) {
		if $<summarize-all-funcs-spec> {
			note 'Summarize-all with functions is not implemented for Python-pandas.';
			make 'print(obj.describe())';
		} else {
			make 'print(obj.describe())';
		}
	}
	method summarize-all-funcs-spec($/) { make '[' ~ $<variable-names-list>.made ~ ']'; }

    # Join command
	method join-command($/) { make $/.values[0].made; }

	method join-by-spec($/) {
		if $<mixed-quoted-variable-names-list> {
			make 'on = [' ~ map( { '"' ~ $_ ~ '"'}, $/.values[0].made.subst(:g, '"', '').split(', ') ).join(', ') ~ ']';
		} else {
			make $/.values[0].made;
		}
	}

	method full-join-spec($/)  {
		if $<join-by-spec> {
			make 'obj = obj.merge( ' ~ $<dataset-name>.made ~ ', ' ~ $<join-by-spec>.made ~ ', how = "full" )';
		} else {
			make 'obj = obj.merge( ' ~ $<dataset-name>.made ~ ', how = "full" )';
		}
	}

	method inner-join-spec($/)  {
		if $<join-by-spec> {
			make 'obj = obj.merge( ' ~ $<dataset-name>.made ~ ', ' ~ $<join-by-spec>.made ~ ', how = "inner" )';
		} else {
			make 'obj = obj.merge( ' ~ $<dataset-name>.made ~ ', how = "inner" )';
		}
	}

	method left-join-spec($/)  {
		if $<join-by-spec> {
			make 'obj = obj.merge( ' ~ $<dataset-name>.made ~ ', ' ~ $<join-by-spec>.made ~ ', how = "left" )';
		} else {
			make 'obj = obj.merge( ' ~ $<dataset-name>.made ~ ', how = "left" )';
		}
	}

	method right-join-spec($/)  {
		if $<join-by-spec> {
			make 'obj = obj.merge( ' ~ $<dataset-name>.made ~ ', ' ~ $<join-by-spec>.made ~ ', how = "right" )';
		} else {
			make 'obj = obj.merge( ' ~ $<dataset-name>.made ~ ', how = "right" )';
		}
	}

	method semi-join-spec($/)  {
		if $<join-by-spec> {
			make 'obj = obj.merge( ' ~ $<dataset-name>.made ~ ', ' ~ $<join-by-spec>.made ~ ', how = "semi" )';
		} else {
			make 'obj = obj.merge( ' ~ $<dataset-name>.made ~ ', how = "semi" )';
		}
	}

    # Cross tabulate command
	method cross-tabulation-command($/) { make $/.values[0].made; }
	method cross-tabulate-command($/) { $<cross-tabulation-formula>.made }
	method contingency-matrix-command($/) { $<cross-tabulation-formula>.made }
	method cross-tabulation-formula($/) { make $/.values[0].made; }
	method cross-tabulation-double-formula($/) {
		if $<values-variable-name> {
			make 'obj = pandas.crosstab( index = obj.' ~ $<rows-variable-name>.made ~ ', columns = obj.' ~ $<columns-variable-name>.made ~ ', values = obj.' ~ $<values-variable-name>.made ~ ', aggfunc = "sum" )';
		} else {
			make 'obj = pandas.crosstab( index = obj.' ~ $<rows-variable-name>.made ~ ', columns = obj.' ~ $<columns-variable-name>.made ~ ' )';
		}
	}
	method cross-tabulation-single-formula($/) {
		if $<values-variable-name> {
			make 'obj = pandas.crosstab( index = obj.' ~ $<rows-variable-name>.made ~ ', values = obj.' ~ $<values-variable-name>.made ~ ', aggfunc = "sum" )';
		} else {
			make 'obj = pandas.crosstab( index = obj.' ~ $<rows-variable-name>.made ~ ' )';
		}
	}
    method rows-variable-name($/) { make $/.values[0].made.subst(:g, '"', ''); }
    method columns-variable-name($/) { make $/.values[0].made.subst(:g, '"', ''); }
    method values-variable-name($/) { make $/.values[0].made.subst(:g, '"', ''); }

    # Reshape command
    method reshape-command($/) { make $/.values[0].made; }

    # Pivot longer command
    method pivot-longer-command($/) { make 'obj = reshape( data = obj, ' ~ $<pivot-longer-arguments-list>.made ~ ', direction = "long" )'; }
    method pivot-longer-arguments-list($/) { make $<pivot-longer-argument>>>.made.join(', '); }
    method pivot-longer-argument($/) { make $/.values[0].made; }

    method pivot-longer-columns-spec($/) { make 'varying = c( ' ~ $<mixed-quoted-variable-names-list>.made.join(', ') ~ ' )'; }

    method pivot-longer-variable-column-spec($/) { make 'timevar = ' ~ $<quoted-variable-name>.made; }

    method pivot-longer-value-column-spec($/) { make 'v.names = ' ~ $<quoted-variable-name>.made; }

    # Pivot wide command
    method pivot-wider-command($/) { make 'obj = reshape( data = obj, ' ~ $<pivot-wider-arguments-list>.made ~ ' , direction = "wide" )'; }
    method pivot-wider-arguments-list($/) { make $<pivot-wider-argument>>>.made.join(', '); }
    method pivot-wider-argument($/) { make $/.values[0].made; }

    method pivot-wider-id-columns-spec($/) { make 'idvar = c( ' ~ $<mixed-quoted-variable-names-list>.made.join(', ') ~ ' )'; }

    method pivot-wider-variable-column-spec($/) { make 'timevar = ' ~ $<quoted-variable-name>.made; }

    method pivot-wider-value-column-spec($/) { make 'v.names = ' ~ $<quoted-variable-name>.made; }

	# Probably have to be in DSL::Shared::Action .
    # Assign-pairs and as-pairs
	method assign-pairs-list($/) { make 'obj = obj.assign( ' ~ $<assign-pair>>>.made.join(', ') ~ ' )'; }
	method as-pairs-list($/)     { make 'obj = obj.assign( ' ~ $<as-pair>>>.made.join(', ') ~ ' )'; }
	method assign-pair($/) { make $<assign-pair-lhs>.made ~ ' = ' ~ $<assign-pair-rhs>.made; }
	method as-pair($/)     { make $<assign-pair-lhs>.made ~ ' = ' ~ $<assign-pair-rhs>.made; }
	method assign-pair-lhs($/) { make $/.values[0].made.subst(:g, '"', ''); }
	method assign-pair-rhs($/) {
        if $<mixed-quoted-variable-name> {
            make 'obj["' ~ $/.values[0].made.subst(:g, '"', '') ~ '"]';
        } else {
            make $/.values[0].made
        }
    }

	# Correspondence pairs
    method key-pairs-list($/) {
		my @pairs = $<key-pair>>>.made;
		my @xs = do for @pairs -> ($x, $y) { $x };
		my @ys = do for @pairs -> ($x, $y) { $y };

		make 'on = None, left_on = [' ~ @xs.join(', ') ~ '], right_on = [' ~ @ys.join(', ') ~ ']';
	}
    method key-pair($/) { make ( $<key-pair-lhs>.made, $<key-pair-rhs>.made); }
    method key-pair-lhs($/) { make '"' ~ $/.values[0].made.subst(:g, '"', '') ~ '"'; }
    method key-pair-rhs($/) { make '"' ~ $/.values[0].made.subst(:g, '"', '') ~ '"'; }

    # Pipeline command
    method pipeline-command($/) { make $/.values[0].made; }
    method take-pipeline-value($/) { make 'obj'; }
    method echo-pipeline-value($/) { make 'print(obj)'; }

    method echo-command($/) { make 'print( ' ~ $<echo-message-spec>.made ~ ' )'; }
    method echo-message-spec($/) { make $/.values[0].made; }
    method echo-words-list($/) { make '"' ~ $<variable-name>>>.made.join(' ') ~ '"'; }
    method echo-variable($/) { make $/.Str; }
    method echo-text($/) { make $/.Str; }
}
