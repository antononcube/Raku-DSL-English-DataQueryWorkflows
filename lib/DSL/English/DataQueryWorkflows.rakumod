=begin pod

=head1 DSL::English::DataQueryWorkflows

C<DSL::English::DataQueryWorkflows> package has grammar and action classes for the parsing and
interpretation of natural language commands that specify data queries in the style of
Standard Query Language (SQL) or RStudio's library tidyverse.

=head1 Synopsis

    use DSL::English::DataQueryWorkflows;
    my $rcode = to_dplyr("select height & mass; arrange by height descending");

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
use DSL::English::DataQueryWorkflows::Actions::SQL::Standard;
use DSL::English::DataQueryWorkflows::Actions::WL::System;

use DSL::English::DataQueryWorkflows::Actions::Bulgarian::Standard;
use DSL::English::DataQueryWorkflows::Actions::Korean::Standard;
use DSL::English::DataQueryWorkflows::Actions::Spanish::Standard;

#-----------------------------------------------------------

my %targetToAction{Str} =
    "Bulgarian"         => DSL::English::DataQueryWorkflows::Actions::Bulgarian::Standard,
    "Julia"             => DSL::English::DataQueryWorkflows::Actions::Julia::DataFrames,
    "Julia-DataFrames"  => DSL::English::DataQueryWorkflows::Actions::Julia::DataFrames,
    "Korean"            => DSL::English::DataQueryWorkflows::Actions::Korean::Standard,
    "Mathematica"       => DSL::English::DataQueryWorkflows::Actions::WL::System,
    "Python-pandas"     => DSL::English::DataQueryWorkflows::Actions::Python::pandas,
    "R"                 => DSL::English::DataQueryWorkflows::Actions::R::base,
    "R-base"            => DSL::English::DataQueryWorkflows::Actions::R::base,
    "R-tidyverse"       => DSL::English::DataQueryWorkflows::Actions::R::tidyverse,
    "Raku"              => DSL::English::DataQueryWorkflows::Actions::Raku::Reshapers,
    "Raku-Reshapers"    => DSL::English::DataQueryWorkflows::Actions::Raku::Reshapers,
    "SQL"               => DSL::English::DataQueryWorkflows::Actions::SQL::Standard,
    "Spanish"           => DSL::English::DataQueryWorkflows::Actions::Spanish::Standard,
    "WL"                => DSL::English::DataQueryWorkflows::Actions::WL::System,
    "WL-System"         => DSL::English::DataQueryWorkflows::Actions::WL::System,
    "pandas"            => DSL::English::DataQueryWorkflows::Actions::Python::pandas,
    "tidyverse"         => DSL::English::DataQueryWorkflows::Actions::R::tidyverse;

my %targetToAction2{Str} = %targetToAction.grep({ $_.key.contains('-') }).map({ $_.key.subst('-', '::') => $_.value }).Hash;
%targetToAction = |%targetToAction , |%targetToAction2;


my Str %targetToSeparator{Str} =
    "Bulgarian"         => "\n",
    "Julia"             => "\n",
    "Julia-DataFrames"  => "\n",
    "Korean"            => "\n",
    "Mathematica"       => "\n",
    "Python-pandas"     => "\n",
    "R"                 => " ;\n",
    "R-base"            => " ;\n",
    "R-tidyverse"       => " %>%\n",
    "Raku"              => " ;\n",
    "Raku-Reshapers"    => " ;\n",
    "SQL"               => ";\n",
    "Spanish"           => "\n",
    "WL"                => ";\n",
    "WL-System"         => ";\n",
    "pandas"            => ".\n",
    "tidyverse"         => " %>%\n";

my Str %targetToSeparator2{Str} = %targetToSeparator.grep({ $_.key.contains('-') }).map({ $_.key.subst('-', '::') => $_.value }).Hash;
%targetToSeparator = |%targetToSeparator , |%targetToSeparator2;


#-----------------------------------------------------------
sub has-semicolon (Str $word) {
    return defined index $word, ';';
}

#-----------------------------------------------------------
proto ToDataQueryWorkflowCode(Str $command, Str $target = 'tidyverse', | ) is export {*}

multi ToDataQueryWorkflowCode ( Str $command, Str $target = 'tidyverse', *%args ) {

    DSL::Shared::Utilities::CommandProcessing::ToWorkflowCode( $command,
                                                               grammar => DSL::English::DataQueryWorkflows::Grammar,
                                                               :%targetToAction,
                                                               :%targetToSeparator,
                                                               :$target,
                                                               |%args )

}

multi ToDataQueryWorkflowCode ( Str $command where has-semicolon($command), Str $target where $target eq 'SQL' ) {

    my $specTarget = get-dsl-spec( $command, 'target');

    $specTarget = $specTarget ?? $specTarget<DSLTARGET> !! $target;

    die 'Unknown target.' unless %targetToAction{$specTarget}:exists;

    # Note that this is global, class variable.
    # It is put to {} here in order to able track group-by statements in WL-System and R-base.
    %targetToAction{$target}.properties = {};

    my @commandLines = $command.trim.split(/ ';' \s* /);

    @commandLines = grep { $_.Str.chars > 0 }, @commandLines;

    my @cmdLines = map { ToDataQueryWorkflowCode($_, $specTarget) }, @commandLines;

    #@cmdLines = grep { $_.^name eq 'Str' }, @cmdLines;

    my %sqlLines = @cmdLines;

    return @cmdLines.join( %targetToSeparator{$target} ).trim;
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
proto to-data-query-raku-code($) is export {*}

multi to-data-query-raku-code ( Str $command ) {
    return ToDataQueryWorkflowCode( $command, 'Raku::Reshapers' );
}
