=begin comment
#==============================================================================
#
#   Data Query Workflows Raku::Reshapers actions in Raku (Perl 6)
#   Copyright (C) 2021  Anton Antonov
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
use DSL::Shared::Actions::Raku::PredicateSpecification;
use DSL::Shared::Actions::English::Raku::ListManagementCommand;

class DSL::English::DataQueryWorkflows::Actions::Raku::Reshapers
        does DSL::English::DataQueryWorkflows::Actions::General
        is DSL::Shared::Actions::Raku::PredicateSpecification
        is DSL::Shared::Actions::English::Raku::ListManagementCommand {

    has Str $.name = 'DSL-English-DataQueryWorkflows-Raku-Reshapers';

    # Top
    method TOP($/) { make $/.values[0].made; }

    # workflow-command-list
    method workflow-commands-list($/) { make $/.values>>.made.join(";\n"); }

    # workflow-command
    method workflow-command($/) { make $/.values[0].made; }

    # General
    method variable-names-list($/) { make $<variable-name>>>.made; }
    method quoted-variable-names-list($/) { make $<quoted-variable-name>>>.made.join(', '); }
    method mixed-quoted-variable-names-list($/) { make $<mixed-quoted-variable-name>>>.made.join(', '); }

    # Column specs
    method column-specs-list($/) { make $<column-spec>>>.made.join(', '); }
    method column-spec($/) {  make $/.values[0].made; }
    method column-name-spec($/) { make '"' ~ $<mixed-quoted-variable-name>.made.subst(:g, '"', '') ~ '"'; }

    # Load data
    method data-load-command($/) { make $/.values[0].made; }
    method load-data-table($/) { make 'my $obj = example-dataset(' ~ $<data-location-spec>.made ~ ')'; }
    method data-location-spec($/) {
        make $<regex-pattern-spec> ?? $<regex-pattern-spec>.made !! '\'' ~ self.unquote($/.Str) ~ '\'';
    }
    method use-data-table($/) { make '$obj = ' ~ $<mixed-quoted-variable-name>.made ; }

    # Distinct command
	method distinct-command($/) { make $/.values[0].made; }
	method distinct-simple-command($/) { make '$obj = unique($obj)'; }

    # Missing treatment command
	method missing-treatment-command($/) { make $/.values[0].made; }
	method drop-incomplete-cases-command($/) { make '$obj = DeleteMissing[$obj, 1, 2]'; }
	method replace-missing-command($/) {
        my $na = $<replace-missing-rhs> ?? $<replace-missing-rhs>.made !! '<NaN>';
        make '$obj = $obj.deepmap({ ( ($_ eqv Any) or $_.isa(Nil) or $_.isa(Whatever) ) ?? ' ~ $na ~ ' !! $_ })'
    }
    method replace-missing-rhs($/) { make $/.values[0].made; }

    # Replace command
    # $obj.deepmap({ $_ ~~ Str ?? $_ !! round($_, 0.01) });
    method replace-command($/) {
        make '$obj = $obj.deepmap({ $_ ~~ ' ~ $<lhs>.made ~ ' ?? ' ~ $<rhs>.made ~ ' !! $_ })'
    }

    # Select command
	method select-command($/) { make $/.values[0].made; }
    method select-columns-simple($/) {
      make '$obj = select-columns($obj, (' ~ $/.values[0].made.join(', ') ~') )';
    }
    method select-columns-by-two-lists($/) {
        my @currentNames = $<current>.made.split(', ');
        my @newNames = $<new>.made.split(', ');

        if @currentNames.elems != @newNames.elems {
            note 'Same number of current and new column names are expected for column selection with renaming.';
            make '$obj';
        } else {
            my @pairs = do for @currentNames Z @newNames -> ($c, $n) { $c ~ ' => ' ~ $n };
            make '$obj = select-columns( $obj, [' ~ @pairs.join(', ') ~ '] )';
        }
    }
    method select-columns-by-pairs($/) {
        my @pairs = $/.values[0].made;
		my @res = do for @pairs -> ( $lhs, $rhsName, $rhs ) { $lhs ~ ' => ' ~ $rhs };
		make '$obj = select-columns( $obj, [' ~ @res.join(', ') ~ '] )';
    }

    # Filter commands
    method filter-command($/) { make '$obj = $obj.grep({ ' ~ $<filter-spec>.made ~ ' }).Array'; }
    method filter-spec($/) { make $<predicates-list>.made; }

    # Mutate command
    method mutate-command($/) { make $/.values[0].made; }
    method mutate-by-two-lists($/) {
        my @currentNames = $<current>.made.split(', ');
        my @newNames = $<new>.made.split(', ');

        if @currentNames.elems != @newNames.elems {
            note 'Same number of current and new column names are expected for mutation with two lists.';
            make '$obj';
        } else {
            my $pairs = do for @currentNames Z @newNames -> ($c, $n) { $n ~ ' => $_{' ~ $c ~ '}' };
            make '$obj = $obj.map({ $_ , %(' ~ $pairs.join(', ') ~ ') })' ;
        }
    }
    method mutate-by-pairs($/) {
        my @pairs = $/.values[0].made;
		my $res = do for @pairs -> ( $lhs, $rhsName, $rhs ) { '$_{' ~ $lhs ~ '} = ' ~ $rhs };
		make '$obj = $obj.map({ ' ~ $res.join('; ') ~'; $_ })';
    }

    # Group command
    method group-command($/) { make $/.values[0].made; }
    method group-by-command($/) {
        my $obj = %.properties<IsGrouped>:exists ?? '$obj.values.reduce( -> $x, $y { [|$x, |$y] } )' !! '$obj';
        %.properties<IsGrouped> = True;
        # This cannot be used since the @vars <column-specs-list> applies .join(',')
        # my @vars = $/.values[0].made;
        # my $vars = @vars.elems == 1 ?? @vars.join(', ') !! '(' ~ @vars.join(', ') ~ ')';
        my $vars = $/.values[0].made;
        $vars = $vars.contains(',') ?? '(' ~ $vars.join(', ') ~ ')' !! $vars;
        make '$obj = group-by(' ~ $obj ~ ', ' ~ $vars.join('.') ~ ')';
    }
    method group-map-command($/) { make '$obj = $obj.map({ $_.key => ' ~ $/.values[0].made ~ '($_.value) })'; }

    # Ungroup command
    method ungroup-command($/) { make $/.values[0].made; }
    method ungroup-simple-command($/) {
        %.properties<IsGrouped>:delete;
        make '$obj = $obj.values.reduce( -> $x, $y { [|$x, |$y] } )';
    }

    # Arrange command
    method arrange-command($/) { make $/.values[0].made; }
    method arrange-simple-command($/) {
        make $<reverse-sort-phrase> || $<descending-phrase> ?? '$obj = reverse(sort($obj))' !! '$obj = sort($obj)';
    }
    method arrange-by-spec($/) { make '(' ~ map( { '$_{"' ~ $_.subst(:g, '"', '') ~ '"}' }, $/.values[0].made.split(', ') ).join(', ') ~ ')'; }
    method arrange-by-command-ascending($/) {
        if %.properties<IsGrouped>:exists {
            make '$obj = $obj>>.sort({ ' ~ $<arrange-by-spec>.made ~ ' })';
        } else {
            make '$obj = $obj.sort({' ~ $<arrange-by-spec>.made ~ ' })';
        }
    }
    method arrange-by-command-descending($/) {
        if %.properties<IsGrouped>:exists {
            make '$obj = $obj>>.sort({ ' ~ $<arrange-by-spec>.made ~ ' })>>.reverse.Array';
        } else {
            make '$obj = $obj.sort({' ~ $<arrange-by-spec>.made ~ ' }).reverse.Array';
        }
    }

    # Rename columns command
    method rename-columns-command($/) { make $/.values[0].made; }
    method rename-columns-by-two-lists($/) {
        my @currentNames = $<current>.made.split(', ');
        my @newNames = $<new>.made.split(', ');

        if @currentNames.elems != @newNames.elems {
            note 'Same number of current and new column names are expected for column renaming.';
            make '$obj';
        } else {
            my @pairs = do for @currentNames Z @newNames -> ($c, $n) { $c ~ ' => ' ~ $n };
            make '$obj = rename-columns( $obj, %(' ~ @pairs.join(', ') ~ ') )';
        }
    }
    method rename-columns-by-pairs($/) {
        my @pairs = $/.values[0].made;
		my @res = do for @pairs -> ( $lhs, $rhsName, $rhs ) { $rhsName ~ ' => ' ~ $lhs };
        make '$obj = rename-columns( $obj, %(' ~ @res.join(', ') ~ ') )';
    }

    # Drop columns command
    method drop-columns-command($/) { make $/.values[0].made; }
    method drop-columns-simple($/) {
        if not $<todrop>.made.contains(',') {
            make '$obj = delete-columns( $obj, ' ~ $<todrop>.made ~ ' )';
        } else {
            make '$obj = delete-columns( $obj, (' ~ $<todrop>.made ~ ') )';
        }
    }

    # Statistics command
    method statistics-command($/) { make $/.values[0].made; }
    method data-dimensions-command($/) { make 'say "dimensions: {dimensions($obj)}"'; }
    method count-command($/) {
        make %.properties<IsGrouped>:exists ?? '$obj = $obj>>.elems' !! '$obj = $obj.elems';
    }
    method echo-count-command($/) {
        make %.properties<IsGrouped>:exists ?? 'say "counts: ", $obj>>.elems' !! 'say "counts : {$obj.elems}"';
    }
    method data-summary-command($/) {
        make %.properties<IsGrouped>:exists ?? '$obj.map({ say("summary of {$_.key}"); records-summary($_.value) })' !! 'records-summary($obj)';
    }
    method glimpse-data($/) { make 'say "glimpse (head): {$obj.head}"'; }
    method summarize-all-command($/) {
        # This needs more coding
        my @funcs = <min max mean median std sum>;
        with $<summarize-funcs-spec> {
            @funcs = $<summarize-funcs-spec>.made
        }
        make '$obj = summarize-at($obj, Whatever, ' ~ @funcs.join(', ') ~ ')';
    }
    method column-names-command($/) { make '$obj.first.keys'; }
    method row-names-command($/) { make '$obj.keys'; }

    # Summarize command
    method summarize-command($/) { make $/.values[0].made; }
    method summarize-by-pairs($/) {
        my @pairs = $/.values[0].made;
		my $res = do for @pairs -> ( $lhs, $rhsName, $rhs ) { $lhs ~ ' => ' ~ $rhs };
		make '$obj = $obj.map({ %(' ~ $res.join(', ') ~ ') })';
    }
	method summarize-at-command($/) {
		my $cols = '(' ~ map( { '"' ~ $_.subst(:g, '"', '') ~ '"' }, $<cols>.made.split(', ') ).join(', ') ~ ')';
        my $funcs = $<summarize-funcs-spec> ?? $<summarize-funcs-spec>.made !! '(&elems, &min, &max)';
  
        if %.properties<IsGrouped>:exists {
            %.properties<IsGrouped>:delete;
            make '$obj = $obj.map({ $_.key => summarize-at($_.value, ' ~ $cols ~ ', ' ~ $funcs ~ ') })';
        } else {
            make '$obj = summarize-at( $obj, ' ~ $cols ~ ', ' ~ $funcs ~ ' )'
        }
    }
	method summarize-funcs-spec($/) { make '(' ~ $<variable-name-or-wl-expr-list>.made.join(', ') ~ ')'; }

    # Join command
    method join-command($/) { make $/.values[0].made; }

    method join-by-spec($/) {
		if $<mixed-quoted-variable-names-list> {
			make '(' ~ map( { '"' ~ $_ ~ '"'}, $/.values[0].made.subst(:g, '"', '').split(', ') ).join(', ') ~ ')';
		} else {
			make $/.values[0].made;
		}
	}

    method anti-join-spec($/)  {
        if $<join-by-spec> {
            make '$obj = join-across( $obj, ' ~ $<dataset-name>.made ~ ', ' ~ $<join-by-spec>.made ~ ', join-spec=>"Anti")';
        } else {
            make '$obj = join-across( $obj, ' ~ $<dataset-name>.made ~ ', ($obj[0].keys (&) ' ~ $<dataset-name>.made  ~ '), join-spec=>"Anti")';
        }
    }

    method full-join-spec($/)  {
        if $<join-by-spec> {
            make '$obj = join-across( $obj, ' ~ $<dataset-name>.made ~ ', ' ~ $<join-by-spec>.made ~ ', join-spec=>"Outer")';
        } else {
            make '$obj = join-across( $obj, ' ~ $<dataset-name>.made ~ ', ($obj[0].keys (&) ' ~ $<dataset-name>.made  ~ '), join-spec=>"Outer")';
        }
    }

    method inner-join-spec($/)  {
        if $<join-by-spec> {
            make '$obj = join-across( $obj, ' ~ $<dataset-name>.made ~ ', ' ~ $<join-by-spec>.made ~ ', join-spec=>"Inner")';
        } else {
            make '$obj = join-across( $obj, ' ~ $<dataset-name>.made ~ ', ($obj[0].keys (&) ' ~ $<dataset-name>.made  ~ '), join-spec=>"Inner")';
        }
    }

    method left-join-spec($/)  {
        if $<join-by-spec> {
            make '$obj = join-across( $obj, ' ~ $<dataset-name>.made ~ ', ' ~ $<join-by-spec>.made ~ ', join-spec=>"Left")';
        } else {
            make '$obj = join-across( $obj, ' ~ $<dataset-name>.made ~ ', ($obj[0].keys (&) ' ~ $<dataset-name>.made  ~ '), join-spec=>"Left")';
        }
    }

    method right-join-spec($/)  {
        if $<join-by-spec> {
            make '$obj = join-across( $obj, ' ~ $<dataset-name>.made ~ ', ' ~ $<join-by-spec>.made ~ ', join-spec=>"Right")';
        } else {
            make '$obj = join-across( $obj, ' ~ $<dataset-name>.made ~ ', ($obj[0].keys (&) ' ~ $<dataset-name>.made  ~ '), join-spec=>"Right")';
        }
    }

    method semi-join-spec($/)  {
        if $<join-by-spec> {
            make '$obj = join-across( $obj, ' ~ $<dataset-name>.made ~ ', ' ~ $<join-by-spec>.made ~ ', join-spec=>"Semi")';
        } else {
            make '$obj = join-across( $obj, ' ~ $<dataset-name>.made ~ ', ($obj[0].keys (&) ' ~ $<dataset-name>.made  ~ '), join-spec=>"Semi")';
        }
    }

    # Cross tabulate command
    method cross-tabulation-command($/) { make $/.values[0].made; }
    method cross-tabulate-command($/) { $<cross-tabulation-formula>.made }
    method contingency-matrix-command($/) { $<cross-tabulation-formula>.made }
    method cross-tabulation-formula($/) { make $/.values[0].made; }
	method cross-tabulation-double-formula($/) {
        if $<values-variable-name> {
            make '$obj = cross-tabulate( $obj, ' ~ $<rows-variable-name>.made ~ ', ' ~ $<columns-variable-name>.made ~  ', ' ~ $<values-variable-name>.made ~ ' )';
        } else {
            make '$obj = cross-tabulate( $obj, ' ~ $<rows-variable-name>.made ~ ', ' ~ $<columns-variable-name>.made ~ ' )';
        }
    }
    method cross-tabulation-single-formula($/) {
        if $<values-variable-name> {
            make '$obj = cross-tabulate( $obj, ' ~ $<rows-variable-name>.made ~ ' )';
        } else {
            make '$obj = cross-tabulate( $obj, ' ~ $<rows-variable-name>.made ~ ' )';
        }
    }
    method rows-variable-name($/) { make $/.values[0].made; }
    method columns-variable-name($/) { make $/.values[0].made; }
    method values-variable-name($/) { make $/.values[0].made; }

    # Reshape command
    method reshape-command($/) { make $/.values[0].made; }

    # Pivot longer command
    method pivot-longer-command($/) {
        if $<pivot-longer-arguments-list> {
            make '$obj = to-long-format( $obj, ' ~ $<pivot-longer-arguments-list>.made ~ ' )';
        } else {
            make '$obj = to-long-format( $obj )';
        }
    }
    method pivot-longer-arguments-list($/) { make $<pivot-longer-argument>>>.made.join(', '); }
    method pivot-longer-argument($/) { make $/.values[0].made; }

    method pivot-longer-id-columns-spec($/) { make 'identifierColumns => (' ~ $/.values[0].made ~ ')'; }

    method pivot-longer-columns-spec($/)    { make 'variableColumns => (' ~ $/.values[0].made ~ ')'; }

    method pivot-longer-variable-column-name-spec($/) { make 'variablesTo => ' ~ $/.values[0].made; }

    method pivot-longer-value-column-name-spec($/) { make 'valuesTo => ' ~ $/.values[0].made; }

    # Pivot wider command
    method pivot-wider-command($/) { make '$obj = to-wide-format( $obj, ' ~ $<pivot-wider-arguments-list>.made ~ ' )'; }
    method pivot-wider-arguments-list($/) { make $<pivot-wider-argument>>>.made.join(', '); }
    method pivot-wider-argument($/) { make $/.values[0].made; }

    method pivot-wider-id-columns-spec($/) { make 'identifierColumns => (' ~ $/.values[0].made ~ ')'; }

    method pivot-wider-variable-column-spec($/) { make 'variablesFrom => ' ~ $/.values[0].made; }

    method pivot-wider-value-column-spec($/) { make 'valuesFrom => ' ~ $/.values[0].made; }

    # Separate string column command
	method separate-column-command($/) {
		my $intocols = map( { '"' ~ $_.subst(:g, '"', '') ~ '"' }, $<into>.made.split(', ') ).join(', ');
		if $<sep> {
			make '$obj = separate-column( $obj, ' ~ $<col>.made ~ ', (' ~ $intocols ~ '), sep => ' ~ $<sep>.made ~ ' )';
		} else {
			make '$obj = separate-column( $obj, ' ~ $<col>.made ~ ', (' ~ $intocols ~ ') )';
		}
	}
    method separator-spec($/) { make $/.values[0].made; }

    # Make dictionary command
    method make-dictionary-command($/) { make '$obj = $obj.map({ $_{' ~ $<keycol>.made ~'} => $_{' ~ $<valcol>.made ~ '} }).Hash'; }

    # Pull column command
    method pull-column-command($/) { make '$obj.map(*{' ~ $<column-name-spec>.made ~ '}).List'; }

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
            make ( $v, '$_{' ~ $v ~ '}' )
        } else {
            make ( $/.values[0].made, $/.values[0].made )
        }
    }

    # Correspondence pairs
    method key-pairs-list($/) { make $<key-pair>>>.made.join(', '); }
    method key-pair($/) { make $<key-pair-lhs>.made ~ ' => ' ~ $<key-pair-rhs>.made; }
    method key-pair-lhs($/) { make '"' ~ $/.values[0].made.subst(:g, '"', '') ~ '"'; }
    method key-pair-rhs($/) { make '"' ~ $/.values[0].made.subst(:g, '"', '') ~ '"'; }

    # Pipeline command
    ## Object
    method assign-pipeline-object-to($/) { make $/.values[0].made ~ ' = $obj'; }

    ## Value
    method assign-pipeline-value-to($/) { make self.assign-pipeline-object-to($/); }
    method pipeline-command($/) { make $/.values[0].made; }
    method take-pipeline-value($/) { make '$obj'; }
    method echo-pipeline-value($/) { make 'say($obj)'; }

    method echo-command($/) { make 'say( ' ~ $<echo-message-spec>.made ~ ' )'; }
    method echo-message-spec($/) { make $/.values[0].made; }
    method echo-words-list($/) { make '"' ~ $<variable-name>>>.made.join(' ') ~ '"'; }
    method echo-variable($/) { make $/.Str; }
    method echo-text($/) { make $/.Str; }

    ## Setup code
    method setup-code-command($/) {
        make 'SETUPCODE' => q:to/SETUPEND/
        use Data::Reshapers;
        use Data::Summarizers;
        use Data::ExampleDatasets;
        SETUPEND
  }
}
