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
#   antononcube <##at##> posteo <##dot##> net
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
use DSL::Shared::Actions::Raku::PredicateSpecification;
use DSL::Shared::Actions::English::Raku::PipelineCommand;

unit module DSL::English::DataQueryWorkflows::Actions::Raku::Reshapers;

class DSL::English::DataQueryWorkflows::Actions::Raku::Reshapers
        is DSL::Shared::Actions::Raku::PredicateSpecification
        is DSL::Shared::Actions::English::Raku::PipelineCommand {

    has Str $.name = 'DSL-English-DataQueryWorkflows-Raku-reshapers';

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
    method load-data-table($/) { make '$obj = example-dataset(' ~ $<data-location-spec>.made ~ ')'; }
    method data-location-spec($/) { make '\'' ~ $/.Str ~ '\''; }
    method use-data-table($/) { make '$obj = ' ~ $<variable-name>.made ; }

    # Distinct command
	method distinct-command($/) { make $/.values[0].made; }
	method distinct-simple-command($/) { make '$obj = DeleteDuplicates[$obj]'; }

    # Missing treatment command
	method missing-treatment-command($/) { make $/.values[0].made; }
	method drop-incomplete-cases-command($/) { make '$obj = DeleteMissing[$obj, 1, 2]'; }
	method replace-missing-command($/) { make '$obj = ReplaceAll[ $obj, _Missing -> ' ~ $<replace-missing-rhs>.made ~ ' ]'; }
    method replace-missing-rhs($/) { make $/.values[0].made; }

    # Replace command
    method replace-command($/) { make '$obj = ReplaceAll[ $obj, ' ~ $<lhs>.made ~ ' -> ' ~ $<rhs>.made ~ ' ]'; }

    # Select command
	method select-command($/) { make $/.values[0].made; }
    method select-columns-simple($/) {
      make '$obj = $obj.grep({ $_.key (elem) Set([' ~ $/.values[0].made.join(', ') ~ ']) }).list';
    }
    method select-columns-by-two-lists($/) {
        my @currentNames = $<current>.made.split(', ');
        my @newNames = $<new>.made.split(', ');

        if @currentNames.elems != @newNames.elems {
            note 'Same number of current and new column names are expected for column selection with renaming.';
            make '$obj';
        } else {
            my @pairs = do for @currentNames Z @newNames -> ($c, $n) { $c ~ ' => ' ~ $n };
            make '$obj = { my %colMapper= ' ~ @pairs.join(', ') ~ '; $obj>>.map({ %colMapper{.key}:exists ?? (%colMapper{.key} => .value) !! $_ })>>.Hash };';
        }
    }
    method select-columns-by-pairs($/) {
        my @pairs = $/.values[0].made;
		my $res = do for @pairs -> ( $lhs, $rhsName, $rhs ) { $lhs ~ ' => ' ~ $rhs };
		make '$obj = { my %colMapper= ' ~ @pairs.join(', ') ~ '; $obj>>.map({ %colMapper{.key}:exists ?? (%colMapper{.key} => .value) !! $_ })>>.Hash };';
    }

    # Filter commands
    method filter-command($/) { make '$obj = $obj.grep({ ' ~ $<filter-spec>.made ~ ' })'; }
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
            my $pairs = do for @currentNames Z @newNames -> ($c, $n) { $n ~ ' -> #[' ~ $c ~ ']' };
            make '$obj = $obj.map({ $_ , %(' ~ $pairs.join(', ') ~ ') })' ;
        }
    }
    method mutate-by-pairs($/) {
        my @pairs = $/.values[0].made;
		my $res = do for @pairs -> ( $lhs, $rhsName, $rhs ) { $lhs ~ ' -> ' ~ $rhs };
		make '$obj = Map[ Join[ #, <|' ~ $res.join(', ') ~ '|> ]&, $obj]';
    }

    # Group command
    method group-command($/) { make $/.values[0].made; }
    method group-by-command($/) {
        my $obj = %.properties<IsGrouped>:exists ?? '$obj.values.reduce( -> $x, $y { [|$x, |$y] } )' !! '$obj';
        %.properties<IsGrouped> = True;
        my @vars = map( { '$_{' ~ $_ ~ '}' }, $/.values[0].made.split(', ') );
        my $vars = @vars.elems == 1 ?? @vars.join(', ') !! '{' ~ @vars.join(', ' ) ~ '}';
        make '$obj = $obj.classify({' ~ $vars.join('.') ~ '})';
    }
    method group-map-command($/) { make '$obj = $obj.map({ $_.key => ' ~ $/.values[0].made ~ '($_.valye) })'; }

    # Ungroup command
    method ungroup-command($/) { make $/.values[0].made; }
    method ungroup-simple-command($/) {
        %.properties<IsGrouped>:delete;
        make '$obj = $obj.values.reduce( -> $x, $y { [|$x, |$y] } )';
    }

    # Arrange command
    method arrange-command($/) { make $/.values[0].made; }
    method arrange-simple-command($/) {
        make $<reverse-sort-phrase> || $<descending> ?? '$obj = reverse(sort($obj))' !! '$obj = sort($obj)';
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
            make '$obj = $obj>>.sort({ ' ~ $<arrange-by-spec>.made ~ ' })>>.reverse';
        } else {
            make '$obj = $obj.sort({' ~ $<arrange-by-spec>.made ~ ' })>>.reverse';
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
            my $current = @currentNames.join(', ');
            make '$obj = { my %colMapper= ' ~ @pairs.join(', ') ~ '; $obj>>.map({ %colMapper{.key}:exists ?? (%colMapper{.key} => .value) !! $_ })>>.Hash };';
        }
    }
    method rename-columns-by-pairs($/) {
        my @pairs = $/.values[0].made;
		my $res = do for @pairs -> ( $lhs, $rhsName, $rhs ) { $lhs ~ ' => ' ~ $rhs };
        make '$obj = { my %colMapper= ' ~ @pairs.join(', ') ~ '; $obj>>.map({ %colMapper{.key}:exists ?? (%colMapper{.key} => .value) !! $_ })>>.Hash };';
    }

    # Drop columns command
    method drop-columns-command($/) { make $/.values[0].made; }
    method drop-columns-simple($/) {
        make '$obj = Map[ KeyDrop[ #, {' ~ $<todrop>.made ~ '} ]&, $obj]';
    }

    # Statistics command
    method statistics-command($/) { make $/.values[0].made; }
    method data-dimensions-command($/) { make 'say "dimensions: {dimensions($obj)}"'; }
    method count-command($/) {
        make %.properties<IsGrouped>:exists ?? '$obj = $obj>>.elems' !! '$obj = $obj.elems';
    }
    method echo-count-command($/) {
        make %.properties<IsGrouped>:exists ?? 'Echo[Map[ Length, $obj], "counts:"]' !! 'Echo[Length[$obj], "counts"]';
    }
    method data-summary-command($/) {
        make %.properties<IsGrouped>:exists ?? '$obj.map({ say("summary of {$_.key}"); records-summary($_.value) })' !! 'records-summary($obj)';
    }
    method glimpse-data($/) { make '$obj.head, "glimpse (head):"]'; }
    method summarize-all-command($/) {
        # This needs more coding / reviewing. (I.e. it is at MVP0 stage.)
        make %.properties<IsGrouped>:exists ?? 'say("summarize-all:"); records-summary($obj)' !! 'say("summarize-all:"); records-summary($obj)';
    }

    # Summarize command
    method summarize-command($/) { make $/.values[0].made; }
    method summarize-by-pairs($/) {
        my @pairs = $/.values[0].made;
		my $res = do for @pairs -> ( $lhs, $rhsName, $rhs ) { $lhs ~ ' -> ' ~ $rhs };
		make '$obj = Map[ <|' ~ $res.join(', ') ~ '|>&, $obj]';
    }
	method summarize-at-command($/) {
		my $cols = '{' ~ map( { '"' ~ $_.subst(:g, '"', '') ~ '"' }, $<cols>.made.split(', ') ).join(', ') ~ '}';
        my $funcs = $<summarize-funcs-spec> ?? $<summarize-funcs-spec>.made !! '{Length, Min, Max, Mean, Median, Total}';
  
        if %.properties<IsGrouped>:exists {
            make '$obj = Dataset[$obj][All, Association @ Flatten @ Outer[ToString[#1] <> "_" <> ToString[#2] -> Query[#2, #1] &,' ~ $cols ~ ', '  ~ $funcs ~ ']]';
        } else {
            make '$obj = Association @ Flatten @ Outer[ToString[#1] <> "_" <> ToString[#2] -> $obj[Query[#2, #1]] &,' ~ $cols ~ ', '  ~ $funcs ~ ']';
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
            make '$obj = join-across( $obj, ' ~ $<dataset-name>.made ~ ', ' ~ $<join-by-spec>.made ~ ', join-spec=>"Right"]';
        } else {
            make '$obj = join-across( $obj, ' ~ $<dataset-name>.made ~ ', ($obj[0].keys (&) ' ~ $<dataset-name>.made  ~ '), join-spec=>"Right")';
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

    method pivot-longer-id-columns-spec($/) { make '"IdentifierColumns" -> (' ~ $/.values[0].made ~ ')'; }

    method pivot-longer-columns-spec($/)    { make '"VariableColumns" -> (' ~ $/.values[0].made ~ ')'; }

    method pivot-longer-variable-column-name-spec($/) { make '"VariablesTo" -> ' ~ $/.values[0].made; }

    method pivot-longer-value-column-name-spec($/) { make '"ValuesTo" -> ' ~ $/.values[0].made; }

    # Pivot wider command
    method pivot-wider-command($/) { make '$obj = to-wide-format( $obj, ' ~ $<pivot-wider-arguments-list>.made ~ ' )'; }
    method pivot-wider-arguments-list($/) { make $<pivot-wider-argument>>>.made.join(', '); }
    method pivot-wider-argument($/) { make $/.values[0].made; }

    method pivot-wider-id-columns-spec($/) { make ' "IdentifierColumns" -> (' ~ $/.values[0].made ~ ')'; }

    method pivot-wider-variable-column-spec($/) { make '"VariablesFrom" -> ' ~ $/.values[0].made; }

    method pivot-wider-value-column-spec($/) { make '"ValuesFrom" -> ' ~ $/.values[0].made; }

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
            make ( $v, '#[' ~ $v ~ ']' )
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
