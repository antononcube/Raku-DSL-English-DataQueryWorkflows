=begin comment
#==============================================================================
#
#   Data Query Workflows R-base actions in Raku (Perl 6)
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
use DSL::Shared::Actions::R::PredicateSpecification;
use DSL::Shared::Actions::English::R::PipelineCommand;

unit module DSL::English::DataQueryWorkflows::Actions::R::base;

class DSL::English::DataQueryWorkflows::Actions::R::base
        is DSL::Shared::Actions::R::PredicateSpecification
		is DSL::Shared::Actions::English::R::PipelineCommand {

	method TOP($/) { make $/.values[0].made; }

	# Overriding Predicate::predicate-simple -- prefixing the lhs variable specs with 'obj$'.
	method predicate-simple($/) {
		if $<predicate-relation>.made eq '%!in%' {
			make '!( obj$' ~ $<lhs>.made ~ ' %in% ' ~ $<rhs>.made ~ ')';
		} elsif $<predicate-relation>.made eq 'like' {
			make 'grepl( pattern = ' ~ $<rhs>.made ~ ', x = obj$' ~ $<lhs>.made ~ ')';
		} else {
			make 'obj$' ~ $<lhs>.made ~ ' ' ~ $<predicate-relation>.made ~ ' ' ~ $<rhs>.made;
		}
	}

	# General
	method variable-names-list($/) { make $<variable-name>>>.made; }
	method quoted-variable-names-list($/) { make $<quoted-variable-name>>>.made; }
	method mixed-quoted-variable-names-list($/) { make $<mixed-quoted-variable-name>>>.made; }

	# Column specs
    method column-specs-list($/) { make $<column-spec>>>.made.join(', '); }
    method column-spec($/) {  make $/.values[0].made; }
    method column-name-spec($/) { make '"' ~ $<mixed-quoted-variable-name>.made.subst(:g, '"', '') ~ '"'; }

	# Load data
	method data-load-command($/) { make $/.values[0].made; }
	method load-data-table($/) { make '{ data(' ~ $<data-location-spec>.made ~ '); obj =' ~ $<data-location-spec>.made ~ ' }'; }
	method data-location-spec($/) { make '\'' ~ $/.Str ~ '\''; }
	method use-data-table($/) { make 'obj <- ' ~ $<variable-name>.made; }

	# Distinct command
	method distinct-command($/) { make $/.values[0].made; }
	method distinct-simple-command($/) { make 'obj <- unique(obj)'; }

	# Missing treatment command
	method missing-treatment-command($/) { make $/.values[0].made; }
	method drop-incomplete-cases-command($/) { make 'obj <- na.omit(obj)'; }
	method replace-missing-command($/) { make 'obj[ is.na(obj) ] <- ' ~ $<replace-missing-rhs>.made ; }

    # Select command
	method select-command($/) { make $/.values[0].made; }
	method select-plain-variables($/) { make 'obj <- obj[ , c(' ~ map( {'"' ~ $_ ~ '"' }, $<variable-names-list>.made ).join(', ') ~ ') ]'; }
	method select-mixed-quoted-variables($/) { make 'obj <- obj[ , c(' ~ $<mixed-quoted-variable-names-list>.made.join(', ') ~ ') ]'; }
    method select-columns-by-pairs($/) { make $/.values[0].made; }

    # Filter commands
	method filter-command($/) { make 'obj <- obj[' ~ $<filter-spec>.made ~ ', ]'; }
	method filter-spec($/) { make $<predicates-list>.made; }

    # Mutate command
	method mutate-command($/) { make $<assign-pairs-list>.made; }

    # Group command
	method group-command($/) { make 'obj <- by( data = obj, ' ~ $<variable-names-list>.made.join(', ') ~ ')'; }

    # Ungroup command
	method ungroup-command($/) { make $/.values[0].made; }
	method ungroup-simple-command($/) { make 'obj <- as.data.frame(ungroup(obj), stringsAsFactors=FALSE)'; }

    # Arrange command
	method arrange-command($/) { make $/.values[0].made; }
	method arrange-simple-spec($/) { make 'c(' ~ $<mixed-quoted-variable-names-list>.made.join(', ') ~ ')'; }
	method arrange-command-ascending($/) { make 'obj <- obj[ order(obj[ ,' ~ $<arrange-simple-spec>.made ~ ']), ]'; }
	method arrange-command-descending($/) { make 'obj <- obj[ rev(order(obj[ ,' ~ $<arrange-simple-spec>.made ~ '])), ]'; }

    # Rename columns command
    method rename-columns-command($/) { make $/.values[0].made; }
    method rename-columns-simple($/) {
		## See how the <mixed-quoted-variable-names-list> was made.
        my @currentNames = $<current>.made;
        my @newNames = $<new>.made;

        if @currentNames.elems != @newNames.elems {
            note 'Same number of current and new column names are expected for column renaming.';
            make 'obj';
        } else {
            my $pairs = do for @currentNames Z @newNames -> ($c, $n) { 'colnames(obj) <- gsub( ' ~ $c ~ ', ' ~ $n ~ ', colnames(obj) )' };
            make $pairs.join(" ;\n");
        }
    }
    method rename-columns-by-pairs($/) { make $/.values[0].made; }

    # Drop columns command
    method drop-columns-command($/) { make $/.values[0].made; }
    method drop-columns-simple($/) {
        my @todrop = $<todrop>.made.split(', ');
        make 'obj <- obj[, setdiff( colnames(obj), c(' ~ $<todrop>.made.join(', ') ~ ') )]';
    }

    # Statistics command
	method statistics-command($/) { make $/.values[0].made; }
	method count-command($/) { make 'tidyverse::count()'; }
	method summarize-data($/) { make 'print(summary(obj))'; }
	method glimpse-data($/) { make 'head(obj)'; }
	method summarize-all-command($/) {
		if $<summarize-all-funcs-spec> {
			note 'Summarize-all with functions is not implemented for R-base.';
			make 'summary(obj)';
		} else {
			make 'summary(obj)';
		}
	}
	method summarize-all-funcs-spec($/) { make 'c(' ~ $<variable-names-list>.made ~ ')'; }

    # Join command
	method join-command($/) { make $/.values[0].made; }

	method join-by-spec($/) {
		if $<mixed-quoted-variable-names-list> {
			make 'by = c(' ~ map( { '"' ~ $_.subst(:g, '"', '') ~ '"'}, $/.values[0].made ).join(', ') ~ ')';
		} else {
			make $/.values[0].made;
		}
	}

	method full-join-spec($/)  {
		if $<join-by-spec> {
			make 'full_join(' ~ $<dataset-name>.made ~ ', by = ' ~ $<join-by-spec>.made ~ ')';
		} else {
			make 'full_join(' ~ $<dataset-name>.made ~ ')';
		}
	}

	method inner-join-spec($/)  {
		if $<join-by-spec> {
			make 'obj <- merge( x = obj, y = ' ~ $<dataset-name>.made ~ ', ' ~ $<join-by-spec>.made ~ ')';
		} else {
			make 'obj <- merge( x = obj, y = ' ~ $<dataset-name>.made ~ ')';
		}
	}

	method left-join-spec($/)  {
		if $<join-by-spec> {
			make 'obj <- merge( x = obj, y = ' ~ $<dataset-name>.made ~ ', ' ~ $<join-by-spec>.made ~ ', all.x = TRUE )';
		} else {
			make 'obj <- merge( x = obj, y = ' ~ $<dataset-name>.made ~ ', all.x = TRUE )';
		}
	}

	method right-join-spec($/)  {
		if $<join-by-spec> {
			make 'obj <- merge( x = obj, y = ' ~ $<dataset-name>.made ~ ', ' ~ $<join-by-spec>.made ~ ', all.y = TRUE )';
		} else {
			make 'obj <- merge( x = obj, y = ' ~ $<dataset-name>.made ~ ', all.y = TRUE )';
		}
	}

	method semi-join-spec($/)  {
		if $<join-by-spec> {
			make 'obj <- merge( x = obj, y = ' ~ $<dataset-name>.made ~ '[, ' ~ $<join-by-spec>.made ~ ' ], by = ' ~ $<join-by-spec>.made ~ ' )';
		} else {
			make 'obj <- merge( x = obj, y = ' ~ $<dataset-name>.made ~ '[, intersect( colnames(obj), colnames(' ~ $<dataset-name>.made ~ ') ) ] )';
		}
	}

    # Cross tabulate command
	method cross-tabulation-command($/) { make $/.values[0].made; }
	method cross-tabulate-command($/) { $<cross-tabulation-formula>.made }
	method contingency-matrix-command($/) { $<cross-tabulation-formula>.made }
	method cross-tabulation-formula($/) { make $/.values[0].made; }
	method cross-tabulation-double-formula($/) {
		if $<values-variable-name> {
			make 'obj <- xtabs( formula = ' ~ $<values-variable-name>.made ~ ' ~ ' ~ $<rows-variable-name>.made ~ ' + ' ~ $<columns-variable-name>.made ~ ', data = obj )';
		} else {
			make 'obj <- xtabs( formula = ~ ' ~ $<rows-variable-name>.made ~ ' + ' ~ $<columns-variable-name>.made ~ ', data = obj )';
		}
	}
	method cross-tabulation-single-formula($/) {
		if $<values-variable-name> {
			make 'obj <- xtabs( formula = ' ~ $<values-variable-name>.made ~ ' ~ ' ~ $<rows-variable-name>.made ~ ', data = obj )';
		} else {
			make 'obj <- xtabs( formula = ~ ' ~ $<rows-variable-name>.made ~ ', data = obj )';
		}
	}
    method rows-variable-name($/) { make $/.values[0]; }
    method columns-variable-name($/) { make $/.values[0]; }
    method values-variable-name($/) { make $/.values[0]; }

    # Reshape command
    method reshape-command($/) { make $/.values[0].made; }

    # Pivot longer command
    method pivot-longer-command($/) { make 'obj <- reshape( data = obj, ' ~ $<pivot-longer-arguments-list>.made ~ ', direction = "long" )'; }
    method pivot-longer-arguments-list($/) { make $<pivot-longer-argument>>>.made.join(', '); }
    method pivot-longer-argument($/) { make $/.values[0].made; }

	method pivot-longer-id-columns-spec($/) { make 'idvar = c( ' ~ $/.values[0].made ~ ' )'; }

    method pivot-longer-columns-spec($/) { make 'varying = list(' ~ $/.values[0].made ~ ' )'; }

    method pivot-longer-variable-column-name-spec($/) { make 'timevar = ' ~ $/.values[0].made; }

    method pivot-longer-value-column-name-spec($/) { make 'v.names = ' ~ $/.values[0].made; }

    # Pivot wider command
    method pivot-wider-command($/) { make 'obj <- reshape( data = obj, ' ~ $<pivot-wider-arguments-list>.made ~ ' , direction = "wide" )'; }
    method pivot-wider-arguments-list($/) { make $<pivot-wider-argument>>>.made.join(', '); }
    method pivot-wider-argument($/) { make $/.values[0].made; }

    method pivot-wider-id-columns-spec($/) { make 'idvar = c( ' ~ $/.values[0].made.join(', ') ~ ' )'; }

    method pivot-wider-variable-column-spec($/) { make 'timevar = ' ~ $/.values[0].made; }

    method pivot-wider-value-column-spec($/) { make 'v.names = ' ~ $/.values[0].made; }

	# Probably have to be in DSL::Shared::Action .
    # Assign-pairs and as-pairs
	method assign-pairs-list($/) { make '{' ~ $<assign-pair>>>.made.join('; ') ~ '}'; }
	method as-pairs-list($/)     { make '{' ~ $<as-pair>>>.made.join('; ') ~ '}'; }
	method assign-pair($/) { make 'obj$' ~ $<assign-pair-lhs>.made ~ ' = ' ~ $<assign-pair-rhs>.made; }
	method as-pair($/)     { make 'obj$' ~ $<assign-pair-lhs>.made ~ ' = ' ~ $<assign-pair-rhs>.made; }
	method assign-pair-lhs($/) { make $/.values[0].made.subst(:g, '"', ''); }
	method assign-pair-rhs($/) {
        if $<mixed-quoted-variable-name> {
            make 'obj$' ~ $/.values[0].made.subst(:g, '"', '');
        } else {
            make $/.values[0].made
        }
    }

	# Correspondence pairs
    method key-pairs-list($/) {
		my @pairs = $<key-pair>>>.made;
		my @xs = do for @pairs -> ($x, $y) { $x };
		my @ys = do for @pairs -> ($x, $y) { $y };

		make 'by.x = c(' ~ @xs.join(', ') ~ '), by.y = c(' ~ @ys.join(', ') ~ ')';
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
