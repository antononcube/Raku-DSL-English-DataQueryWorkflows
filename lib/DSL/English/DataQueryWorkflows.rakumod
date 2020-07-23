=begin pod

=head1 DSL::English::DataQueryWorkflows

C<DSL::English::DataQueryWorkflows> package has grammar and action classes for the parsing and
interpretation of natural language commands that specify data queries in the style of
Standard Query Language (SQL) or RStudio's library dplyr.

=head1 Synopsis

    use DSL::English::DataQueryWorkflows;
    my $rcode = to_dplyr("select height & mass; arrange by height descending");

=end pod

unit module DSL::English::DataQueryWorkflows;

use DSL::English::DataQueryWorkflows::Grammar;
use DSL::English::DataQueryWorkflows::Actions::Bulgarian::LocalizedDSL;
use DSL::English::DataQueryWorkflows::Actions::Julia::DataFrames;
use DSL::English::DataQueryWorkflows::Actions::Python::pandas;
use DSL::English::DataQueryWorkflows::Actions::R::base;
use DSL::English::DataQueryWorkflows::Actions::R::dplyr;
use DSL::English::DataQueryWorkflows::Actions::WL::System;

#-----------------------------------------------------------

#my %targetToAction := {
#    "dplyr"         => DSL::English::DataQueryWorkflows::Actions::R::dplyr,
#    "R-dplyr"       => DSL::English::DataQueryWorkflows::Actions::R::dplyr,
#    "R"             => DSL::English::DataQueryWorkflows::Actions::R::base,
#    "R-base"        => DSL::English::DataQueryWorkflows::Actions::R::base,
#    "pandas"        => DSL::English::DataQueryWorkflows::Actions::Python::pandas,
#    "Python-pandas" => DSL::English::DataQueryWorkflows::Actions::Python::pandas,
#    "WL"            => DSL::English::DataQueryWorkflows::Actions::WL::Dataset,
#    "WL-SQL"        => DSL::English::DataQueryWorkflows::Actions::WL::SQL
#};

my %targetToAction =
    "Bulgarian"        => DSL::English::DataQueryWorkflows::Actions::Bulgarian::LocalizedDSL,
    "Julia"            => DSL::English::DataQueryWorkflows::Actions::Julia::DataFrames,
    "Julia-DataFrames" => DSL::English::DataQueryWorkflows::Actions::Julia::DataFrames,
    "R"                => DSL::English::DataQueryWorkflows::Actions::R::base,
    "R-base"           => DSL::English::DataQueryWorkflows::Actions::R::base,
    "R-dplyr"          => DSL::English::DataQueryWorkflows::Actions::R::dplyr,
    "dplyr"            => DSL::English::DataQueryWorkflows::Actions::R::dplyr,
    "Python-pandas"    => DSL::English::DataQueryWorkflows::Actions::Python::pandas,
    "pandas"           => DSL::English::DataQueryWorkflows::Actions::Python::pandas,
    "Mathematica"      => DSL::English::DataQueryWorkflows::Actions::WL::System,
    "WL"               => DSL::English::DataQueryWorkflows::Actions::WL::System,
    "WL-System"        => DSL::English::DataQueryWorkflows::Actions::WL::System;

my %targetToSeparator{Str} =
    "Bulgarian"        => "\n",
    "Julia"            => "\n",
    "Julia-DataFrames" => "\n",
    "R"                => "\n",
    "R-base"           => "\n",
    "R-dplyr"          => " %>%\n",
    "dplyr"            => " %>%\n",
    "Mathematica"      => "\n",
    "Python-pandas"    => ".\n",
    "pandas"           => ".\n",
    "WL"               => ";\n",
    "WL-System"        => ";\n";


#-----------------------------------------------------------
sub has-semicolon (Str $word) {
    return defined index $word, ';';
}

#-----------------------------------------------------------
proto ToDataQueryWorkflowCode(Str $command, Str $target = "dplyr" ) is export {*}

multi ToDataQueryWorkflowCode ( Str $command where not has-semicolon($command), Str $target = "dplyr" ) {

    die 'Unknown target.' unless %targetToAction{$target}:exists;

    my $match = DSL::English::DataQueryWorkflows::Grammar::WorkflowCommad.parse($command, actions => %targetToAction{$target} );
    die 'Cannot parse the given command.' unless $match;
    return $match.made;
}

multi ToDataQueryWorkflowCode ( Str $command where has-semicolon($command), Str $target = 'dplyr' ) {

    die 'Unknown target.' unless %targetToAction{$target}:exists;

    my @commandLines = $command.trim.split(/ ';' \s* /);

    @commandLines = grep { $_.Str.chars > 0 }, @commandLines;

    my @dqLines = map { ToDataQueryWorkflowCode($_, $target) }, @commandLines;

    return @dqLines.join( %targetToSeparator{$target} ).trim;
}

#-----------------------------------------------------------
proto to_DataQuery_Julia($) is export {*}

multi to_DataQuery_Julia ( Str $command ) {
    return ToDataQueryWorkflowCode( $command, 'Julia-DataFrames' );
}

#-----------------------------------------------------------
proto to_DataQuery_dplyr($) is export {*}

multi to_DataQuery_dplyr ( Str $command ) {
    return ToDataQueryWorkflowCode( $command, 'R-dplyr' );
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