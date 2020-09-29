=begin comment
#==============================================================================
#
#   Data Query Workflows Julia-DataFrames actions in Raku (Perl 6)
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
use DSL::Shared::Actions::Julia::PredicateSpecification;
use DSL::Shared::Actions::English::Julia::PipelineCommand;

unit module DSL::English::DataQueryWorkflows::Actions::Julia::DataFrames;

class DSL::English::DataQueryWorkflows::Actions::Julia::DataFrames
		is DSL::Shared::Actions::Julia::PredicateSpecification
		is DSL::Shared::Actions::English::Julia::PipelineCommand {

    method TOP($/) { make $/.values[0].made; }

	# General
	method variable-names-list($/) { make map( {':' ~ $_ }, $<variable-name>>>.made ).join(', '); }
	method quoted-variable-names-list($/) { make map( {':' ~ $_.subst(:g, '"', '') }, $<quoted-variable-name>>>.made ).join(', '); }
	method mixed-quoted-variable-names-list($/) { make map( {':' ~ $_.subst(:g, '"', '') }, $<mixed-quoted-variable-name>>>.made ).join(', '); }

	# Column specs
    method column-specs-list($/) { make $<column-spec>>>.made.join(', '); }
    method column-spec($/) {  make $/.values[0].made; }
    method column-name-spec($/) { make ':' ~ $<mixed-quoted-variable-name>.made.subst(:g, '"', ''); }

	# Load data
	method data-load-command($/) { make $/.values[0].made; }
	method load-data-table($/) { make 'obj = ' ~ $<data-location-spec>.made; }
	method data-location-spec($/) { make '\"' ~ $/.Str ~ '\"'; }
	method use-data-table($/) { make 'obj = ' ~ $<variable-name>.made; }

	# Distinct command
	method distinct-command($/) { make $/.values[0].made; }
	method distinct-simple-command($/) { make 'obj = unique(obj)'; }

	# Missing treatment command
	method missing-treatment-command($/) { make $/.values[0].made; }
	method drop-incomplete-cases-command($/) { make 'obj = obj[ completecases(obj), :]'; }
	method replace-missing-command($/) { make 'obj = coalesce.( obj, ' ~ $<replace-missing-rhs>.made ~ ')'; }
    method replace-missing-rhs($/) { make $/.values[0].made; }

	# Select command
  	method select-command($/) { make $/.values[0].made; }
	method select-columns-simple($/) { make 'obj = obj[ : , [' ~ $/.values[0].made ~ ']]'; }
	method select-columns-by-two-lists($/) {
		# I am not very comfortable with splitting the made string here, but it works.
        # Maybe it is better to no not join the elements in <variable-names-list>.
        my @currentNames = $<current>.made.split(', ');
        my @newNames = $<new>.made.split(', ');

        if @currentNames.elems != @newNames.elems {
            note 'Same number of current and new column names are expected for column selection with renaming.';
            make 'obj';
        } else {
            my $pairs = do for @currentNames Z @newNames -> ($c, $n) { $c ~ ' => ' ~ $n };
            make 'obj = obj[ :, ' ~ $pairs.join(', ') ~ ' ]';
        }
	}
    method select-columns-by-pairs($/) { make 'select!( obj, ' ~ $/.values[0].made ~ ')'; }

	# Filter commands
	method filter-command($/) { make 'obj = obj[ ' ~ $<filter-spec>.made ~ ', :]'; }
	method filter-spec($/) { make $<predicates-list>.made; }

	# Mutate command
	method mutate-command($/) { make $/.values[0].made; }
	method mutate-by-two-lists($/) {
		my @currentNames = $<current>.made.split(', ');
        my @newNames = $<new>.made.split(', ');

        if @currentNames.elems != @newNames.elems {
            note 'Same number of current and new column names are expected for mutation with two lists.';
            make 'obj';
        } else {
            my $pairs = do for @currentNames Z @newNames -> ($c, $n) { $c ~ ' => ' ~ $n };
            make 'obj = transform( obj, ' ~ $pairs.join(', ') ~ ' )';
        }
	}
	method mutate-by-pairs($/) { make 'obj = transform( obj, ' ~ $/.values[0].made ~ ' )'; }

	# Group command
	method group-command($/) { make 'obj = groupby( obj, [' ~ $<variable-names-list>.made ~ '] )'; }

	# Ungroup command
	method ungroup-command($/) { make $/.values[0].made; }
	method ungroup-simple-command($/) { make 'obj = combine(obj)'; }

	# Arrange command
	method arrange-command($/) { make $/.values[0].made; }
	method arrange-simple-command($/) {
        make $<reverse-sort-phrase> || $<descending> ?? 'obj = sort( obj, rev=true )' !! 'obj = sort( obj )';
    }
	method arrange-by-spec($/) { make $/.values[0].made; }
	method arrange-by-command-ascending($/) { make 'obj = sort( obj, [' ~ $<arrange-by-spec>.made ~ '] )'; }
	method arrange-by-command-descending($/) { make 'obj = sort( obj, [' ~ $<arrange-by-spec>.made ~ '], rev=true )'; }

    # Rename columns command
    method rename-columns-command($/) { make $/.values[0].made; }
    method rename-columns-by-two-lists($/) {
        # I am not very comfortable with splitting the made string here, but it works.
        # Maybe it is better to no not join the elements in <variable-names-list>.
        my @currentNames = $<current>.made.split(', ');
        my @newNames = $<new>.made.split(', ');

        if @currentNames.elems != @newNames.elems {
            note 'Same number of current and new column names are expected for column renaming.';
            make 'obj';
        } else {
            my $pairs = do for @currentNames Z @newNames -> ($c, $n) { $c ~ ' => ' ~ $n };
            make 'obj = rename( obj, ' ~ $pairs.join(', ') ~ ' )';
        }
    }
    method rename-columns-by-pairs($/) { make 'rename!( obj, ' ~ $/.values[0].made ~ ')'; }

    # Drop columns command
    method drop-columns-command($/) { make $/.values[0].made; }
    method drop-columns-simple($/) {
        # Note that here we assume no single quotes are in <mixed-quoted-variable-names-list>.made .
        my @todrop = $<todrop>.made.subst(:g, '"', '').split(', ');
        make 'obj = select( obj, ' ~ map( { 'Not[' ~ $_ ~ ']' }, @todrop ).join(', ') ~ ' )';
    }

	# Statistics command
	method statistics-command($/) { make $/.values[0].made; }
	method count-command($/) { make 'obj = combine(obj, nrow)'; }
	method summarize-data($/) { make 'describe(obj)'; }
	method glimpse-data($/) { make 'first(obj, 6)'; }
	method summarize-all-command($/) {
		if $<summarize-funcs-spec> {
			my $funcs = $<summarize-funcs-spec>.made.split(', ');
			make 'combine( obj, ' ~ map( { 'names(obj) .=> ' ~ $_ } , $funcs ).join(', ') ~ ' )';
		} else {
			make 'combine( obj, names(obj) .=> mean )';
		}
	}
	method summarize-funcs-spec($/) { make $<variable-names-list>.made.subst(:g, ':', ''); }


	# Join command
	method join-command($/) { make $/.values[0].made; }

	method join-by-spec($/) {
		if $<mixed-quoted-variable-names-list> {
			make '[' ~ $/.values[0].made ~ ']';
		} else {
			make $/.values[0].made;
		}
	}

	method full-join-spec($/)  {
		if $<join-by-spec> {
			make 'obj = outerjoin( obj, ' ~ $<dataset-name>.made ~ ', on = ' ~ $<join-by-spec>.made ~ ')';
		} else {
			make 'obj = outerjoin( obj, ' ~ $<dataset-name>.made ~ ')';
		}
	}

	method inner-join-spec($/)  { 
		if $<join-by-spec> {
			make 'obj = innerjoin( obj, ' ~ $<dataset-name>.made ~ ', on = ' ~ $<join-by-spec>.made ~ ')';
		} else {
			make 'obj = innerjoin( obj, ' ~ $<dataset-name>.made ~ ')';
		}
	}

	method left-join-spec($/)  {
		if $<join-by-spec> {
			make 'obj = leftjoin( obj, ' ~ $<dataset-name>.made ~ ', on = ' ~ $<join-by-spec>.made ~ ')';
		} else {
			make 'obj = leftjoin( obj, ' ~ $<dataset-name>.made ~ ')';
		}
	}
	
	method right-join-spec($/)  {
		if $<join-by-spec> {
			make 'obj = rightjoin( obj, ' ~ $<dataset-name>.made ~ ', on = ' ~ $<join-by-spec>.made ~ ')';
		} else {
			make 'obj = rightjoin( obj, ' ~ $<dataset-name>.made ~ ')';
		}
	}
	
	method semi-join-spec($/)  {
		if $<join-by-spec> {
			make 'obj = semijoin( obj, ' ~ $<dataset-name>.made ~ ', on = ' ~ $<join-by-spec>.made ~ ')';
		} else {
			make 'obj = semijoin( obj, ' ~ $<dataset-name>.made ~ ')';
		}
	}

	# Cross tabulate command
	method cross-tabulation-command($/) { make $/.values[0].made; }
	method cross-tabulate-command($/) { $<cross-tabulation-formula>.made }
	method contingency-matrix-command($/) { $<cross-tabulation-formula>.made }
	method cross-tabulation-formula($/) { make $/.values[0].made; }
	method cross-tabulation-double-formula($/) {
		if $<values-variable-name> {
			make 'obj = combine( x -> sum(x[:, ' ~ $<values-variable-name>.made ~ ']), groupby( obj, [ ' ~ $<rows-variable-name>.made ~ ', ' ~ $<columns-variable-name>.made ~ '] ))';
		} else {
			make 'obj = combine( nrow, groupby( obj, [ ' ~ $<rows-variable-name>.made ~ ', ' ~ $<columns-variable-name>.made ~ '] ))';
		}
	}
	method cross-tabulation-single-formula($/) {
		if $<values-variable-name> {
			make 'obj = combine( x -> sum(x[:, ' ~ $<values-variable-name>.made ~ ']), groupby( obj, [ ' ~ $<rows-variable-name>.made ~ ' ] ))';
		} else {
			make 'obj = combine( nrow, groupby( obj, [ ' ~ $<rows-variable-name>.made ~ ' ] ))';
		}
	}
    method rows-variable-name($/) { make $/.values[0].made; }
    method columns-variable-name($/) { make $/.values[0].made; }
    method values-variable-name($/) { make $/.values[0].made; }

  # Reshape command
    method reshape-command($/) { make $/.values[0].made; }

    # Pivot longer command
    method pivot-longer-command($/) { make 'Not implemented'; }

	# Pivot wide command
    method pivot-wider-command($/) {make 'Not implemented'; }

	# Make dictionary command
    method make-dictionary-command($/) { make 'obj = Dict(zip( obj[:, ' ~ $<keycol>.made ~', obj[:, ' ~ $<valcol>.made ~ '] ))';}

	# Probably have to be in DSL::Shared::Actions .
    # Assign-pairs and as-pairs
	method assign-pairs-list($/) { make $<assign-pair>>>.made.join(', '); }
	method as-pairs-list($/)     { make $<as-pair>>>.made.join(', '); }
	method assign-pair($/) { make $<assign-pair-rhs>.made ~ ' => ' ~ $<assign-pair-lhs>.made; }
	method as-pair($/)     { make $<assign-pair-rhs>.made ~ ' => ' ~ $<assign-pair-lhs>.made; }
	method assign-pair-lhs($/) { make ':' ~ $/.values[0].made.subst(:g, '"', ''); }
	method assign-pair-rhs($/) {
        if $<mixed-quoted-variable-name> {
            make ':' ~ $/.values[0].made.subst(:g, '"', '');
        } else {
            make $/.values[0].made
        }
    }

	# Correspondence pairs
    method key-pairs-list($/) { make $<key-pair>>>.made.join(', '); }
	method key-pair($/) { make ':' ~ $<key-pair-lhs>.made ~ ' => :' ~ $<key-pair-rhs>.made; }
    method key-pair-lhs($/) { make $/.values[0].made.subst(:g, '"', ''); }
    method key-pair-rhs($/) { make $/.values[0].made.subst(:g, '"', ''); }

    # Pipeline command
    method pipeline-command($/) { make $/.values[0].made; }
    method take-pipeline-value($/) { make 'obj'; }
    method echo-pipeline-value($/) { make 'println(obj)'; }

    method echo-command($/) { make 'println( ' ~ $<echo-message-spec>.made ~ ' );'; }
    method echo-message-spec($/) { make $/.values[0].made; }
    method echo-words-list($/) { make '"' ~ $<variable-name>>>.made.join(' ') ~ '"'; }
    method echo-variable($/) { make $/.Str; }
    method echo-text($/) { make $/.Str; }
}
