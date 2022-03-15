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
#   ʇǝu˙oǝʇsod@ǝqnɔuouoʇuɐ,
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

	has Str $.name = 'DSL-English-DataQueryWorkflows-R-base';

    # Top
    method TOP($/) { make $/.values[0].made; }

    # workflow-command-list
    method workflow-commands-list($/) { make $/.values>>.made.join("\n"); }

    # workflow-command
    method workflow-command($/) { make $/.values[0].made; }

	# Overriding DSL::Shared::Actions::R::PredicateSpecification::predicate-simple :
	# 1) prefixing the lhs variable specs with 'obj$',
	# 2) if with quotes using the universal obj[[...]].
	method predicate-simple($/) {
		my Str $objCol =
				self.is-single-quoted($<lhs>.made) || self.is-double-quoted($<lhs>.made)
				?? 'obj[[' ~ $<lhs>.made ~ ']]'
				!! 'obj$' ~ $<lhs>.made;

		if $<predicate-relation>.made eq '%!in%' {
			make '!( ' ~ $objCol ~ ' %in% ' ~ $<rhs>.made ~ ')';
		} elsif $<predicate-relation>.made eq 'like' {
			make 'grepl( pattern = ' ~ $<rhs>.made ~ ', x = ' ~ $objCol ~ ')';
		} else {
			make $objCol ~ ' ' ~ $<predicate-relation>.made ~ ' ' ~ $<rhs>.made;
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
    method replace-missing-rhs($/) { make $/.values[0].made; }

	# Replace command
    method replace-command($/) { make 'Not implemented'; }

    # Select command
	method select-command($/) { make $/.values[0].made; }
	method select-columns-simple($/) { make 'obj <- obj[, c(' ~ $/.values[0].made ~ ')]'; }
    method select-columns-by-two-lists($/) {
		## See how the <mixed-quoted-variable-names-list> was made.
        my @currentNames = $<current>.made.split(', ');
        my @newNames = $<new>.made.split(', ');

        if @currentNames.elems != @newNames.elems {
            note 'Same number of current and new column names are expected for column selection with renaming.';
            make 'obj';
        } else {
            my $pairs = do for @currentNames Z @newNames -> ($c, $n) { 'colnames(obj) <- gsub( ' ~ $c ~ ', ' ~ $n ~ ', colnames(obj) )' };
			make $pairs.join(" ;\n") ~ "\n" ~ 'obj <- obj[, c(' ~ @newNames.join(', ') ~ ')]';
        }
    }
	method select-columns-by-pairs($/) {
		my @triplets = $/.values[0].made;
		my $res = do for @triplets -> ( $lhs, $rhsName, $rhs ) { 'colnames(obj) <- gsub( ' ~ $rhsName ~ ', ' ~ $lhs ~ ', colnames(obj) )' };
		my $newcols = do for @triplets -> ( $lhs, $rhsName, $rhs ) { $lhs };
		make $res.join("\n") ~ "\n" ~ 'obj[, c('~ $newcols.join(', ') ~ ')]';
	}

    # Filter commands
	method filter-command($/) { make 'obj <- obj[' ~ $<filter-spec>.made ~ ', ]'; }
	method filter-spec($/) { make $<predicates-list>.made; }

    # Mutate command
	method mutate-command($/) { make $/.values[0].made; }
    method mutate-by-two-lists($/) {
		## See how the <mixed-quoted-variable-names-list> was made.
        my @currentNames = $<current>.made.split(', ');
        my @newNames = $<new>.made.split(', ');

        if @currentNames.elems != @newNames.elems {
            note 'Same number of current and new column names are expected for mutation by two lists.';
            make 'obj';
        } else {
            my $pairs = do for @currentNames Z @newNames -> ($c, $n) { 'obj[[' ~ $n ~ ']] <- obj[[' ~ $c ~ ']]' };
			make $pairs.join(" ;\n");
        }
    }
	method mutate-by-pairs($/) {
		my @triplets = $/.values[0].made;
		my $res = do for @triplets -> ( $lhs, $rhsName, $rhs ) { 'obj[[' ~ $lhs ~ ']] <- ' ~ $rhs; };
		make '{' ~ $res.join("; ") ~ '}';
	}

    # Group command
    method group-command($/) { make $/.values[0].made; }
	method group-by-command($/) { make 'obj <- split( x = obj, f = ' ~ $/.values[0].made ~ ' )'; }
	method group-map-command($/) { make 'obj <- lapply( X = obj, FUN = ' ~ $/.values[0].made ~ ' )'; }

    # Ungroup command
	method ungroup-command($/) { make $/.values[0].made; }
	method ungroup-simple-command($/) { make 'obj <- as.data.frame(ungroup(obj), stringsAsFactors=FALSE)'; }

    # Arrange command
	method arrange-command($/) { make $/.values[0].made; }
	method arrange-simple-command($/) {
        make $<reverse-sort-phrase> || $<descending-phrase> ?? 'obj = obj[rev(order(obj)),]' !! 'obj = obj[order(obj),]';
    }
	method arrange-by-spec($/) { make 'c(' ~ $/.values[0].made.join(', ') ~ ')'; }
	method arrange-by-command-ascending($/) { make 'obj <- obj[ order(obj[ ,' ~ $<arrange-by-spec>.made ~ ']), ]'; }
	method arrange-by-command-descending($/) { make 'obj <- obj[ rev(order(obj[ ,' ~ $<arrange-by-spec>.made ~ '])), ]'; }

    # Rename columns command
    method rename-columns-command($/) { make $/.values[0].made; }
    method rename-columns-by-two-lists($/) {
		## See how the <mixed-quoted-variable-names-list> was made.
        my @currentNames = $<current>.made.split(', ');
        my @newNames = $<new>.made.split(', ');

        if @currentNames.elems != @newNames.elems {
            note 'Same number of current and new column names are expected for column renaming.';
            make 'obj';
        } else {
            my $pairs = do for @currentNames Z @newNames -> ($c, $n) { 'colnames(obj) <- gsub( ' ~ $c ~ ', ' ~ $n ~ ', colnames(obj) )' };
			make $pairs.join(" ;\n") ~ "\n" ~ 'obj <- obj[,' ~ ~ 'setdiff( colnames(obj), c(' ~ @currentNames.join(', ') ~ '))]';
        }
    }
    method rename-columns-by-pairs($/) {
		my @pairs = $/.values[0].made;
		my $res = do for @pairs -> ( $lhs, $rhsName, $rhs ) { 'colnames(obj) <- gsub( ' ~ $rhsName ~ ', ' ~ $lhs ~ ', colnames(obj) )' };
		my $oldcols = do for @pairs -> ( $lhs, $rhsName, $rhs ) { $rhsName };
		make $res.join(" ;\n") ~ "\n" ~ 'obj <- obj[,' ~ ~ 'setdiff( colnames(obj), c(' ~ $oldcols.join(', ') ~ '))]';
	}

    # Drop columns command
    method drop-columns-command($/) { make $/.values[0].made; }
    method drop-columns-simple($/) {
        my @todrop = $<todrop>.made.split(', ');
        make 'obj <- obj[, setdiff( colnames(obj), c(' ~ $<todrop>.made.join(', ') ~ ') )]';
    }

    # Statistics command
	method statistics-command($/) { make $/.values[0].made; }
	method data-dimensions-command($/) { make 'print(dim(obj))'; }
	method count-command($/) { make 'obj = length(obj)'; }
	method echo-count-command($/) {
        make 'print(length(obj))';
    }
	method data-summary-command($/) { make 'print(summary(obj))'; }
	method glimpse-data($/) { make 'head(obj)'; }

	# Summarize command
    method summarize-command($/) { make $/.values[0].made; }
	method summarize-by-pairs($/) {
		my @triplets = $/.values[0].made;
		my $res = do for @triplets -> ( $lhs, $rhsName, $rhs ) { 'obj[[' ~ $lhs ~ ']] <- ' ~ $rhs; };
		make '{' ~ $res.join("; ") ~ '}';
	}
	method summarize-all-command($/) {
		if $<summarize-funcs-spec> {
			note 'Summarize-all with functions is not implemented for R-base.';
			make 'summary(obj)';
		} else {
			make 'summary(obj)';
		}
	}
	method summarize-at-command($/) {
		my $cols = 'c(' ~ map( { '"' ~ $_ ~ '"' }, $<cols>.made ).join(', ') ~ ')';
		if $<summarize-funcs-spec> {
			make 'Reduce( function(a,f) rbind( a, lapply( starwars[,' ~ $cols ~ '], f) ), init = NULL, x =' ~ $<summarize-funcs-spec>.made ~ ' )';
		} else {
			make 'Reduce( function(a,f) rbind( a, lapply( starwars[,' ~ $cols ~ '], f) ), init = NULL, x = c( Min = function(.) min(., na.rm = T), Max = function(.) max(., na.rm = T), Mean = function(.) mean(., na.rm = T), Median = function(.) median(., na.rm = T), Sum = function(.) sum(., na.rm = T) ) )';
		}
	}
	method summarize-funcs-spec($/) { make 'c(' ~ $<variable-name-or-wl-expr-list>.made.join(', ') ~ ')'; }

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
    method pivot-longer-command($/) {
		if $<pivot-longer-arguments-list> {
			make 'obj <- reshape( data = obj, ' ~ $<pivot-longer-arguments-list>.made ~ ', direction = "long" )';
		} else {
			make 'obj <- reshape( data = obj, idvar = 1, varying = list(2:ncol(obj)), timevar = "Variable", v.names = "Value", direction = "long" )';
		}
	}
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

	# Separate string column command
	method separate-column-commands($/) { make 'Not implemented'; }
	method separator-spec($/) { make $/.values[0].made; }

	# Make dictionary command
    method make-dictionary-command($/) { make 'obj <- setNames( obj[, '  ~ $<valcol>.made ~'], obj[, ' ~ $<keycol>.made ~ '] )';}

	# Probably have to be in DSL::Shared::Actions .
    # Assign-pairs and as-pairs
	method assign-pairs-list($/) { make $<assign-pair>>>.made; }
	method as-pairs-list($/)     { make $<as-pair>>>.made; }
	method assign-pair($/) { make ( $<assign-pair-lhs>.made, |$<assign-pair-rhs>.made ); }
	method as-pair($/)     { make ( $<assign-pair-lhs>.made, |$<assign-pair-rhs>.made ); }
	method assign-pair-lhs($/) { make '"' ~ $/.values[0].made.subst(:g, '"', '') ~ '"'; }
	method assign-pair-rhs($/) {
        if $<mixed-quoted-variable-name> {
            my $v = '"' ~ $/.values[0].made.subst(:g, '"', '') ~ '"';
			make ( $v, 'obj[[' ~ $v ~ ']]' );
        } else {
            make ( $/.values[0].made, $/.values[0].made )
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

}
