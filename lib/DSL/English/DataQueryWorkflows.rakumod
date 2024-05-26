=begin pod

=head1 DSL::English::DataQueryWorkflows

C<DSL::English::DataQueryWorkflows> package has grammar and action classes for the parsing
and interpretation of natural language commands that specify data queries in the style of
Standard Query Language (SQL) or RStudio's library tidyverse.

=head1 Synopsis

    use DSL::English::DataQueryWorkflows;
    my $rcode = ToDataQueryWorkflowCode("select height & mass; arrange by height descending");

=end pod

unit module DSL::English::DataQueryWorkflows;

use DSL::Shared::Utilities::MetaSpecsProcessing;
use DSL::Shared::Utilities::CommandProcessing;

use DSL::English::DataQueryWorkflows::Grammar;

use DSL::English::DataQueryWorkflows::Actions::Julia::DataFrames;
use DSL::English::DataQueryWorkflows::Actions::Python::pandas;
use DSL::English::DataQueryWorkflows::Actions::R::base;
use DSL::English::DataQueryWorkflows::Actions::R::tidyverse;
use DSL::English::DataQueryWorkflows::Actions::Raku::Reshapers;
use DSL::English::DataQueryWorkflows::Actions::Raku::SQL::Builder;
use DSL::English::DataQueryWorkflows::Actions::SQL::SQLite;
use DSL::English::DataQueryWorkflows::Actions::SQL::Standard;
use DSL::English::DataQueryWorkflows::Actions::WL::System;

use DSL::English::DataQueryWorkflows::Actions::Bulgarian::Standard;
use DSL::English::DataQueryWorkflows::Actions::English::Standard;
use DSL::English::DataQueryWorkflows::Actions::Korean::Standard;
use DSL::English::DataQueryWorkflows::Actions::Russian::Standard;
use DSL::English::DataQueryWorkflows::Actions::Spanish::Standard;

#-----------------------------------------------------------

my %targetToAction{Str} =
    "Bulgarian"         => DSL::English::DataQueryWorkflows::Actions::Bulgarian::Standard,
    "English"           => DSL::English::DataQueryWorkflows::Actions::English::Standard,
    "Julia"             => DSL::English::DataQueryWorkflows::Actions::Julia::DataFrames,
    "Julia-DataFrames"  => DSL::English::DataQueryWorkflows::Actions::Julia::DataFrames,
    "Korean"            => DSL::English::DataQueryWorkflows::Actions::Korean::Standard,
    "Mathematica"       => DSL::English::DataQueryWorkflows::Actions::WL::System,
    "Python"            => DSL::English::DataQueryWorkflows::Actions::Python::pandas,
    "Python-pandas"     => DSL::English::DataQueryWorkflows::Actions::Python::pandas,
    "R"                 => DSL::English::DataQueryWorkflows::Actions::R::base,
    "R-base"            => DSL::English::DataQueryWorkflows::Actions::R::base,
    "R-tidyverse"       => DSL::English::DataQueryWorkflows::Actions::R::tidyverse,
    "Raku"              => DSL::English::DataQueryWorkflows::Actions::Raku::Reshapers,
    "Raku-Reshapers"    => DSL::English::DataQueryWorkflows::Actions::Raku::Reshapers,
    "Raku-SQL"          => DSL::English::DataQueryWorkflows::Actions::Raku::SQL::Builder,
    "Raku-SQLBuilder"   => DSL::English::DataQueryWorkflows::Actions::Raku::SQL::Builder,
    "Raku-SQL-Builder"  => DSL::English::DataQueryWorkflows::Actions::Raku::SQL::Builder,
    "Russian"           => DSL::English::DataQueryWorkflows::Actions::Russian::Standard,
    "SQL"               => DSL::English::DataQueryWorkflows::Actions::SQL::Standard,
    "SQL-Standard"      => DSL::English::DataQueryWorkflows::Actions::SQL::Standard,
    "SQLite"            => DSL::English::DataQueryWorkflows::Actions::SQL::SQLite,
    "SQL-SQLite"        => DSL::English::DataQueryWorkflows::Actions::SQL::SQLite,
    "Spanish"           => DSL::English::DataQueryWorkflows::Actions::Spanish::Standard,
    "WL"                => DSL::English::DataQueryWorkflows::Actions::WL::System,
    "WL-System"         => DSL::English::DataQueryWorkflows::Actions::WL::System,
    "pandas"            => DSL::English::DataQueryWorkflows::Actions::Python::pandas,
    "tidyverse"         => DSL::English::DataQueryWorkflows::Actions::R::tidyverse;

my %targetToAction2{Str} = %targetToAction.grep({ $_.key.contains('-') }).map({ $_.key.subst('-', '::', :g) => $_.value }).Hash;
%targetToAction = |%targetToAction , |%targetToAction2;


my Str %targetToSeparator{Str} =
    "Bulgarian"         => "\n",
    "English"           => "\n",
    "Julia"             => "\n",
    "Julia-DataFrames"  => "\n",
    "Korean"            => "\n",
    "Mathematica"       => "\n",
    "Python"            => "\n",
    "Python-pandas"     => "\n",
    "R"                 => " ;\n",
    "R-base"            => " ;\n",
    "R-tidyverse"       => " %>%\n",
    "Raku"              => " ;\n",
    "Raku-Reshapers"    => " ;\n",
    "Raku-SQL"          => '.',
    "Raku-SQLBuilder"   => ".",
    "Raku-SQL-Builder"  => '.',
    "Russian"           => "\n",
    "SQL"               => "\n",
    "SQL-Standard"      => "\n",
    "Spanish"           => "\n",
    "WL"                => ";\n",
    "WL-System"         => ";\n",
    "pandas"            => "\n.",
    "tidyverse"         => " %>%\n";

my Str %targetToSeparator2{Str} = %targetToSeparator.grep({ $_.key.contains('-') }).map({ $_.key.subst('-', '::', :g) => $_.value }).Hash;
%targetToSeparator = |%targetToSeparator , |%targetToSeparator2;


#-----------------------------------------------------------
sub has-semicolon (Str $word) {
    return defined index $word, ';';
}

#-----------------------------------------------------------
#| Translates natural language commands into data query DSL code.
#| * C<$command> is a string with one or many commands (separated by ';').
#| * C<$target> is a programming-language-and-package name, like <R-tidyverse Raku::Reshapers Python::pandas>; or a natural language one of <Bulgarian English Korean Russian Spanish>.
#| * C<:$format> is the format of the output, one of <code hash raku>.
proto ToDataQueryWorkflowCode(Str $command, | ) is export {*}

multi ToDataQueryWorkflowCode( Str $command, :$target = 'R-tidyverse', *%args ) {
    return ToDataQueryWorkflowCode( $command, $target, |%args);
}

multi ToDataQueryWorkflowCode( Str $command, Str $target = 'R-tidyverse', *%args ) {

    my $lang = %args<language>:exists ?? %args<language> !! 'English';
    $lang = $lang.wordcase;

    my $gname = "DSL::{$lang}::DataQueryWorkflows::Grammar";

    try require ::($gname);
    if ::($gname) ~~ Failure { die "Failed to load the grammar $gname." }

    my Grammar $grammar = ::($gname);

    # Not needed, just showing that :$language is otherwise passed to ToWorkflowCode.
    # %args = %args.pairs.grep({ $_.key ne 'language' }).Hash;

    DSL::Shared::Utilities::CommandProcessing::ToWorkflowCode( $command,
                                                               :$grammar,
                                                               :%targetToAction,
                                                               :%targetToSeparator,
                                                               :$target,
                                                               |%args )
}


multi ToDataQueryWorkflowCode ( Str $command,
                                Str $target where $_ ∈ <SQL SQL::Standard SQL-Standard SQLite SQL-SQLite SQL::SQLite>,
                                *%args ) {

    my $specTarget = get-dsl-spec( $command, 'target');

    $specTarget = $specTarget ?? $specTarget<DSLTARGET> !! $target;

    die 'Unknown target.' unless %targetToAction{$specTarget}:exists;

    # Note that this is global, class variable.
    # It is put to {} here in order to able track group-by statements in WL-System and R-base.
    my $actionsObj = %targetToAction{$target}.new;
    $actionsObj.properties = {};

    my @commandLines = $command.trim.split(/ ';' \s* /);

    @commandLines = grep { $_.Str.chars > 0 }, @commandLines;

    #my @sqlLines = map { ToDataQueryWorkflowCode($_, $specTarget) }, @commandLines;
    my @sqlLines = @commandLines.map({
        ToWorkflowCode($_,
                grammar => DSL::English::DataQueryWorkflows::Grammar,
                actions => $actionsObj,
                separator => %targetToSeparator{$specTarget},
                format => 'hash')
    });

    my @sqlParts = @sqlLines.map({ $_.first({ $_.key !eq 'CODE' }) });

    if @sqlParts.all ~~ Pair:D {
        @sqlParts = DSL::English::DataQueryWorkflows::Actions::SQL::Standard.combine-sql-parts(@sqlParts);
        return @sqlParts.join(%targetToSeparator{$target}).trim;
    } elsif !( @sqlLines.elems == 1 && (@sqlLines.head<CODE>:exists) && @sqlLines.head<CODE>.trim) {
        note "Cannot parse ⎡$command⎦.";
        return Nil;
    } else {
        return @sqlLines.map({ $_<CODE> // Empty }).join("\n");
    }
}

#-----------------------------------------------------------
proto to_DataQuery_Julia($) is export {*}

multi to_DataQuery_Julia ( Str $command ) {
    return ToDataQueryWorkflowCode( $command, 'Julia-DataFrames' );
}

#-----------------------------------------------------------
proto to_DataQuery_tidyverse($) is export {*}

multi to_DataQuery_tidyverse ( Str $command ) {
    return ToDataQueryWorkflowCode( $command, 'R-tidyverse' );
}

#-----------------------------------------------------------
proto to_DataQuery_pandas($) is export {*}

multi to_DataQuery_pandas ( Str $command ) {
    return ToDataQueryWorkflowCode( $command, 'Python-pandas' );
}

#-----------------------------------------------------------
proto to_DataQuery_WL(Str $) is export {*}

multi to_DataQuery_WL ( Str $command ) {
    return ToDataQueryWorkflowCode( $command, 'WL-System' );
}

#-----------------------------------------------------------

#| Shortcut for ToDataQueryWorkflowCode($cmd, "Raku::Reshapers")
proto to-data-query-raku-code($) is export {*}

multi to-data-query-raku-code ( Str $command ) {
    return ToDataQueryWorkflowCode( $command, 'Raku::Reshapers' );
}
