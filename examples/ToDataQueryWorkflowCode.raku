#!/usr/bin/env perl6
use DSL::English::DataQueryWorkflows;

sub MAIN(Str $commands) {
    put ToDataQueryWorkflowCode($commands);
}

