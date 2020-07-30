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

use DSL::English::DataQueryWorkflows::Grammar;

use DSL::English::DataQueryWorkflows::Actions::Julia::DataFrames;
use DSL::English::DataQueryWorkflows::Actions::Python::pandas;
use DSL::English::DataQueryWorkflows::Actions::R::base;
use DSL::English::DataQueryWorkflows::Actions::R::tidyverse;
use DSL::English::DataQueryWorkflows::Actions::WL::System;

use DSL::English::DataQueryWorkflows::Actions::Bulgarian::Standard;
use DSL::English::DataQueryWorkflows::Actions::Spanish::Standard;

#-----------------------------------------------------------

#my %targetToAction := {
#    "tidyverse"         => DSL::English::DataQueryWorkflows::Actions::R::tidyverse,
#    "R-tidyverse"       => DSL::English::DataQueryWorkflows::Actions::R::tidyverse,
#    "R"             => DSL::English::DataQueryWorkflows::Actions::R::base,
#    "R-base"        => DSL::English::DataQueryWorkflows::Actions::R::base,
#    "pandas"        => DSL::English::DataQueryWorkflows::Actions::Python::pandas,
#    "Python-pandas" => DSL::English::DataQueryWorkflows::Actions::Python::pandas,
#    "WL"            => DSL::English::DataQueryWorkflows::Actions::WL::Dataset,
#    "WL-SQL"        => DSL::English::DataQueryWorkflows::Actions::WL::SQL
#};

my %targetToAction =
    "Julia"            => DSL::English::DataQueryWorkflows::Actions::Julia::DataFrames,
    "Julia-DataFrames" => DSL::English::DataQueryWorkflows::Actions::Julia::DataFrames,
    "R"                => DSL::English::DataQueryWorkflows::Actions::R::base,
    "R-base"           => DSL::English::DataQueryWorkflows::Actions::R::base,
    "R-tidyverse"          => DSL::English::DataQueryWorkflows::Actions::R::tidyverse,
    "tidyverse"            => DSL::English::DataQueryWorkflows::Actions::R::tidyverse,
    "Python-pandas"    => DSL::English::DataQueryWorkflows::Actions::Python::pandas,
    "pandas"           => DSL::English::DataQueryWorkflows::Actions::Python::pandas,
    "Mathematica"      => DSL::English::DataQueryWorkflows::Actions::WL::System,
    "WL"               => DSL::English::DataQueryWorkflows::Actions::WL::System,
    "WL-System"        => DSL::English::DataQueryWorkflows::Actions::WL::System,
    "Bulgarian"        => DSL::English::DataQueryWorkflows::Actions::Bulgarian::Standard,
    "Spanish"          => DSL::English::DataQueryWorkflows::Actions::Spanish::Standard;

my %targetToSeparator{Str} =
    "Julia"            => "\n",
    "Julia-DataFrames" => "\n",
    "R"                => "\n",
    "R-base"           => "\n",
    "R-tidyverse"          => " %>%\n",
    "tidyverse"            => " %>%\n",
    "Mathematica"      => "\n",
    "Python-pandas"    => ".\n",
    "pandas"           => ".\n",
    "WL"               => ";\n",
    "WL-System"        => ";\n",
    "Bulgarian"        => "\n",
    "Spanish"          => "\n";


#-----------------------------------------------------------
sub has-semicolon (Str $word) {
    return defined index $word, ';';
}

#-----------------------------------------------------------
proto ToDataQueryWorkflowCode(Str $command, Str $target = "tidyverse" ) is export {*}

multi ToDataQueryWorkflowCode ( Str $command where not has-semicolon($command), Str $target = "tidyverse" ) {

    die 'Unknown target.' unless %targetToAction{$target}:exists;

    my $match = DSL::English::DataQueryWorkflows::Grammar.parse($command, actions => %targetToAction{$target} );
    die 'Cannot parse the given command.' unless $match;
    return $match.made;
}

multi ToDataQueryWorkflowCode ( Str $command where has-semicolon($command), Str $target = 'tidyverse' ) {

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