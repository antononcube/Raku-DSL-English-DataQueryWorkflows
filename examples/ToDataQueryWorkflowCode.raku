#!/usr/bin/env perl6
use DSL::English::DataQueryWorkflows;

sub MAIN(Str $commands, Str $target = 'R-tidyverse' ) {
    put ToDataQueryWorkflowCode($commands, $target);
}