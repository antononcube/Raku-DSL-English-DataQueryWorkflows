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

use DSL::English::DataQueryWorkflows::Actions::General;
use DSL::Shared::Actions::Python::PredicateSpecification;
use DSL::English::DataQueryWorkflows::Actions::Python::ListManagementCommand-pandas;

class DSL::English::DataQueryWorkflows::Actions::Python::pandas
		does DSL::English::DataQueryWorkflows::Actions::General
        is DSL::Shared::Actions::Python::PredicateSpecification
		is DSL::English::DataQueryWorkflows::Actions::Python::ListManagementCommand-pandas {

	has Str $.name = 'DSL-English-DataQueryWorkflows-Python-pandas';

    # Top
    method TOP($/) { make $/.values[0].made; }

    # workflow-command-list
    method workflow-commands-list($/) { make $/.values>>.made.join("\n"); }

    # workflow-command
    method workflow-command($/) { make $/.values[0].made; }

    # Overriding Predicate::predicate-simple -- wrapping the lhs variable specs with 'obj[...]'.
	method predicate-simple($/) {
		my $plhs = 'obj["' ~ $<lhs>.made.subst(:g, '"', '') ~ '"]';
		my $prhs = $<rhs>.made;

		if $<predicate-relation>.made eq '%!in%' {
			make '!( obj[' ~ $plhs ~ '] %in% ' ~ $prhs ~ ')';
		} elsif $<predicate-relation>.made eq 'like' {
			make 'grepl( pattern = ' ~ $prhs ~ ', x = obj$' ~ $plhs ~ ')';
		} else {
			make $plhs ~ $<predicate-relation>.made ~ ' ' ~ $prhs;
		}
	}

	# General
	method variable-names-list($/) { make $<variable-name>>>.made.join(', '); }
	method quoted-variable-names-list($/) { make $<quoted-variable-name>>>.made.join(', '); }
	method mixed-quoted-variable-names-list($/) { map( { '"' ~ $_ ~ '"' }, make $<mixed-quoted-variable-name>>>.made ).join(', '); }

	# Column specs
    method column-specs-list($/) { make $<column-spec>>>.made.join(', '); }
    method column-spec($/) {  make $/.values[0].made; }
    method column-name-spec($/) { make map( {'"' ~ $_ ~ '"' }, $<mixed-quoted-variable-name>.made.subst(:g, '"', '') ); }

	# Load data
	method data-load-command($/) { make $/.values[0].made; }
	method load-data-table($/) { make 'obj = example_dataset(' ~ $<data-location-spec>.made ~ ')'; }
	method data-location-spec($/) {
		make $<regex-pattern-spec> ?? $<regex-pattern-spec>.made !! '\'' ~ self.unquote($/.Str) ~ '\'';
	}
	method use-data-table($/) { make 'obj = ' ~ $<mixed-quoted-variable-name>.made ~ '.copy()'; }

	# Distinct command
	method distinct-command($/) { make $/.values[0].made; }
	method distinct-simple-command($/) { make 'obj = obj.drop_duplicates()'; }

	# Missing treatment command
	method missing-treatment-command($/) { make $/.values[0].made; }
	method drop-incomplete-cases-command($/) { make 'obj = obj.dropna()'; }
	method replace-missing-command($/) {
		my $na = $<replace-missing-rhs> ?? $<replace-missing-rhs>.made !! '"NA"';
		make 'obj = obj.replace( numpy.nan,' ~ $na ~ ')';
	}
    method replace-missing-rhs($/) { make $/.values[0].made; }

	# Replace command
    method replace-command($/) { make 'Not implemented'; }

    # Select command
	method select-command($/) { make $/.values[0].made; }
	method select-columns-simple($/) { make 'obj = obj[[' ~  $/.values[0].made.split(', ').join(', ') ~ ']]'; }
	method select-columns-by-two-lists($/) {
		# Almost the same as rename-columns-by-two-lists($/) .
		my @currentNames = $<current>.made.split(', ');
        my @newNames = $<new>.made.split(', ');

        if @currentNames.elems != @newNames.elems {
            note 'Same number of current and new column names are expected for column selection with renaming.';
            make 'obj';
        } else {
            my $pairs = do for @currentNames Z @newNames -> ($c, $n) { $c ~ ' : ' ~ $n };
            make 'obj.rename( columns = { ' ~ $pairs.join(', ') ~ ' }, inplace = True )' ~
					"\n" ~
					'obj = obj[[ ' ~ @newNames.join(', ') ~ ']]';
        }
	}
	method select-columns-by-pairs($/) {
		my @newCols = $/.values[0].made.split( / '=' | '(' | ')' | ',' / );
		my $res = $/.values[0].made;
		@newCols = grep( { $_.chars > 0 }, @newCols[2..*-1] );
		@newCols = @newCols[0,2...*];
		make $res ~ "\n" ~ 'obj = obj[[' ~ map( { '"' ~ $_.trim ~ '"' }, @newCols ).join(', ') ~ ']]';
	}

    # Filter commands
	method filter-command($/) { make 'obj = obj[' ~ $<filter-spec>.made ~ ']'; }
	method filter-spec($/) { make $<predicates-list>.made; }

    # Mutate command
	method mutate-command($/) { make $/.values[0].made; }
    method mutate-by-two-lists($/) {
		# Almost the same as rename-columns-by-two-lists($/) .
        my @currentNames = $<current>.made.split(', ');
        my @newNames = $<new>.made.split(', ');

        if @currentNames.elems != @newNames.elems {
            note 'Same number of current and new column names are expected for mutation with two lists.';
            make 'obj';
        } else {
            my $pairs = do for @currentNames Z @newNames -> ($c, $n) { $n ~ ' : ' ~ $c };
            make 'obj = obj.asign(' ~ $pairs.join(', ') ~ ')';
        }
	}
	method mutate-by-pairs($/) {
		my @newCols = $/.values[0].made.split( / '=' | '(' | ')' | ',' / );
		my $res = $/.values[0].made;
		@newCols = grep( { $_.chars > 0 }, @newCols[2..*-1] );
		@newCols = @newCols[0,2...*];
		make $res;
	}

    # Group command
    method group-command($/) { make $/.values[0].made; }
	method group-by-command($/) {
		my $pre = (%.properties<IsGrouped> // False) ?? self.ungroup-simple-command($/) ~ "\n" !! '';
		%.properties<IsGrouped> = True;
		make $pre ~ 'obj = obj.groupby([' ~ $/.values[0].made ~ '])';
	}
	method group-map-command($/) { make 'obj = obj.transform(' ~ $/.values[0].made ~ ')'; }

    # Ungroup command
	method ungroup-command($/) { make $/.values[0].made; }
	method ungroup-simple-command($/) {
		%.properties<IsGrouped>:delete;
		# Python::pandas does not ungroup method, but the following code
		# is considered idiomatic, see:
		#   https://github.com/pandas-dev/pandas/issues/43902#issuecomment-936934157
		make 'obj = pandas.concat([g for k, g in obj])';
	}

    # Arrange command
	method arrange-command($/) { make $/.values[0].made; }
	method arrange-simple-command($/) {
        make $<reverse-sort-phrase> || $<descending-phrase> ?? 'obj = obj.sort_values(ascending = False)' !! 'obj = obj.sort_values()';
    }
	method arrange-by-spec($/) { make '[' ~ $/.values[0].made.join(', ') ~ ']'; }
	method arrange-by-command-ascending($/) { make 'obj = obj.sort_values( ' ~ $<arrange-by-spec>.made ~ ' )'; }
	method arrange-by-command-descending($/) { make 'obj = obj.sort_values( ' ~ $<arrange-by-spec>.made ~ ', ascending = False )'; }

    # Rename columns command
    method rename-columns-command($/) { make $/.values[0].made; }
	method rename-columns-by-two-lists($/) {
        # I am not very comfortable with splitting the made string here, but it works.
        # Maybe it is better to no not join the elements in <variable-names-list>.
        # Note that here with subst we assume no single quotes are in <mixed-quoted-variable-names-list>.made .
        my @currentNames = $<current>.made.split(', ');
        my @newNames = $<new>.made.split(', ');

        if @currentNames.elems != @newNames.elems {
            note 'Same number of current and new column names are expected for column renaming.';
            make 'obj';
        } else {
            my $pairs = do for @currentNames Z @newNames -> ($c, $n) { $c ~ ' : ' ~ $n };
            make 'obj.rename( columns = { ' ~ $pairs.join(', ') ~ ' }, inplace = True )';
        }
    }
    method rename-columns-by-pairs($/) { make $/.values[0].made; }

    # Drop columns command
    method drop-columns-command($/) { make $/.values[0].made; }
    method drop-columns-simple($/) {
		# See https://pandas.pydata.org/docs/reference/api/pandas.DataFrame.drop.html
        my @todrop = $<todrop>.made.split(', ');
        make 'obj = obj.drop( columns = [' ~ $<todrop>.made.join(', ') ~ '] )';
    }

    # Statistics command
	method statistics-command($/) { make $/.values[0].made; }
	method data-dimensions-command($/) { self.echo-count-command($/) }
	method count-command($/) {
		if %.properties<IsGrouped>:exists {
			make 'obj = obj.size()'
		} else {
			make 'obj = obj.shape[0]'
		}
	}
	method echo-count-command($/) {
		if %.properties<IsGrouped>:exists {
			make 'print(obj.size())'
		} else {
			make 'print(obj.shape[0])'
		}
    }
	method data-summary-command($/) { make 'print(obj.describe())'; }
	method glimpse-data($/) { make 'print(obj.head())'; }
	method column-names-command($/) { make 'print(obj.columns.values.tolist())'; }
	method row-names-command($/) { make 'print(obj.index.tolist())'; }

	# Summarize command
    method summarize-command($/) {
		make $/.values[0].made;
	}
	method summarize-by-pairs($/) {
		make 'obj = obj.agg(' ~ $/.values[0].made ~ ')';
	}
	method summarize-all-command($/) {
		make 'print("<summarize-all-command> is not implemented for Python::pandas.")'
	}
	method summarize-at-command($/) {
        # Functions
        my @funcs = <min max mean median std sum>;
        with $<summarize-funcs-spec> {
            @funcs = $<summarize-funcs-spec>.made
        }
        my $spec = self.agg-spec-dict($<cols>.made, @funcs);
        make 'obj = obj.agg(' ~ $spec ~ ')';
	}
	method summarize-funcs-spec($/) {
		make $<variable-name-or-wl-expr-list>.made;
	}
    method agg-spec-pairs(@cols, @funcs) {
        # .agg specification that consists of pairs
        my @spec;
        for @cols -> $c {
            for @funcs -> $f {
                @spec.append( $c ~ '_' ~ $f ~ ' = ("' ~ $c ~ '", "' ~ $f ~ '")' )
            }
        }
        return @spec.join(', ');
    }
    method agg-spec-dict(@cols, @funcs) {
        # .agg specification is a dictionary
        my $farr = '[' ~ @funcs.map({ '"' ~ $_ ~ '"' }).join(', ') ~ ']';
        return '{' ~ @cols.map({ '"' ~ $_ ~ '" : ' ~ $farr }).join(', ') ~ '}';
    }

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
			make 'obj = pandas.crosstab( index = ' ~ $<rows-variable-name>.made ~ ', columns = ' ~ $<columns-variable-name>.made ~ ', values = ' ~ $<values-variable-name>.made ~ ', aggfunc = "sum" )';
		} else {
			make 'obj = pandas.crosstab( index = ' ~ $<rows-variable-name>.made ~ ', columns = ' ~ $<columns-variable-name>.made ~ ' )';
		}
	}
	method cross-tabulation-single-formula($/) {
		if $<values-variable-name> {
			make 'obj = pandas.crosstab( index = ' ~ $<rows-variable-name>.made ~ ', values = '~ $<values-variable-name>.made ~ ', aggfunc = "sum" )';
		} else {
			make 'obj = pandas.crosstab( index = ' ~ $<rows-variable-name>.made ~ ' )';
		}
	}
	# Using these definitions brings ambiguity some times. For example:
	# for Titanic data with obj.class is not the same as obj["class"].
    #   method rows-variable-name($/)    { make 'obj.' ~ $/.values[0].made.subst(:g, '"', ''); }
	#   method columns-variable-name($/) { make 'obj.' ~ $/.values[0].made.subst(:g, '"', ''); }
	#   method values-variable-name($/)  { make 'obj.' ~ $/.values[0].made.subst(:g, '"', ''); }
	method rows-variable-name($/)    { make 'obj[' ~ $/.values[0].made ~ ']'; }
	method columns-variable-name($/) { make 'obj[' ~ $/.values[0].made ~ ']'; }
	method values-variable-name($/)  { make 'obj[' ~ $/.values[0].made ~ ']'; }

    # Reshape command
    method reshape-command($/) { make $/.values[0].made; }

    # Pivot longer command
    method pivot-longer-command($/) {
		if $<pivot-longer-arguments-list> {
			make 'obj = pandas.melt( obj, ' ~ $<pivot-longer-arguments-list>.made ~ ' )';
		} else {
			make 'obj = pandas.melt( obj, id_vars = obj.columns[0], var_name = "Variable", value_name = "Value" )';
		}
	}
    method pivot-longer-arguments-list($/) { make $<pivot-longer-argument>>>.made.join(', '); }
    method pivot-longer-argument($/) { make $/.values[0].made; }

    method pivot-longer-id-columns-spec($/) { make 'id_vars = [' ~ $/.values[0].made ~ ']'; }

    method pivot-longer-columns-spec($/)    { make 'value_vars = [' ~ $/.values[0].made ~ ']'; }

    method pivot-longer-variable-column-name-spec($/) { make 'var_name = ' ~ $/.values[0].made; }

    method pivot-longer-value-column-name-spec($/) { make 'value_name ' ~ $/.values[0].made; }

    # Pivot wide command
    method pivot-wider-command($/) { make 'obj = obj.pivot(' ~ $<pivot-wider-arguments-list>.made ~ ')'; }
    method pivot-wider-arguments-list($/) { make $<pivot-wider-argument>>>.made.join(', '); }
    method pivot-wider-argument($/) { make $/.values[0].made; }

    method pivot-wider-id-columns-spec($/) { make 'index = ( ' ~ $/.values[0].made ~ ' )'; }

    method pivot-wider-variable-column-spec($/) { make 'columns = ' ~ $/.values[0].made; }

    method pivot-wider-value-column-spec($/) { make 'values = ' ~ $/.values[0].made; }

	# Separate string column command
	# See https://pandas.pydata.org/docs/reference/api/pandas.Series.str.split.html
	method separate-column-command($/) {
		my $intocols = $<into>.made.join(', ');
		if $<sep> && $<sep>.Str ∈ <'' ""> {
			make 'obj[[' ~ $intocols ~ ']] = obj[' ~ $<col>.made ~ '].str.extract(pat = r"' ~ ('(.)') x $<into>.made.elems ~ '", expand = True)';
		} elsif $<sep> {
			make 'obj[[' ~ $intocols ~ ']] = obj[' ~ $<col>.made ~ '].str.split(pat = ' ~ $<sep>.Str ~ ', n = ' ~ $<into>.made.elems.Str ~ ', expand = True)';
		} else {
			make 'obj[[' ~ $intocols ~ ']] = obj[' ~ $<col>.made ~ '].str.split(pat = None, n = ' ~ $<into>.made.elems.Str ~ ', expand = True)';
		}
	}

	# Make dictionary command
    method make-dictionary-command($/) { make 'obj = dict(zip( obj[' ~ $<keycol>.made ~'], obj[' ~ $<valcol>.made ~ '] ))';}

	# Pull column command
	method pull-column-command($/) { make 'obj[' ~ $<column-name-spec>.made ~ '].values'; }

	# Probably have to be in DSL::Shared::Actions .
    # Assign-pairs and as-pairs
	method assign-pairs-list($/)      { make 'obj = obj.assign( ' ~ $<assign-pair>>>.made.join(', ') ~ ' )'; }
	method as-pairs-list($/)          { make 'obj = obj.assign( ' ~ $<as-pair>>>.made.join(', ') ~ ' )'; }
	method association-pairs-list($/) { make '{' ~ $<association-pair>>>.made.join(', ') ~ '}'; }
	method assign-pair($/)            { make $<assign-pair-lhs>.made ~ ' = ' ~ $<assign-pair-rhs>.made; }
	method as-pair($/)                { make $<assign-pair-lhs>.made ~ ' = ' ~ $<assign-pair-rhs>.made; }
	method association-pair($/)       { make $<assign-pair-lhs>.made ~ ' : ' ~ $<assign-pair-rhs>.made; }
	method assign-pair-lhs($/)        { make $/.values[0].made.subst(:g, '"', ''); }
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
	## Object
	method assign-pipeline-object-to($/) { make $/.values[0].made ~ ' = obj'; }

	## Value
	method assign-pipeline-value-to($/) { make self.assign-pipeline-object-to($/); }
    method pipeline-command($/) { make $/.values[0].made; }
    method take-pipeline-value($/) { make 'obj'; }
    method echo-pipeline-value($/) { make 'print(obj)'; }

    method echo-command($/) { make 'print( ' ~ $<echo-message-spec>.made ~ ' )'; }
    method echo-message-spec($/) { make $/.values[0].made; }
    method echo-words-list($/) { make '"' ~ $<variable-name>>>.made.join(' ') ~ '"'; }
    method echo-variable($/) { make $/.Str; }
    method echo-text($/) { make $/.Str; }

	## Setup code
	method setup-code-command($/) {
		make 'SETUPCODE' => ['import pandas', 'from ExampleDatasets import *'].join("\n");
    }
}
