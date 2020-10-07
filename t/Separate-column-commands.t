use v6;
use lib 'lib';
use DSL::English::DataQueryWorkflows::Grammar;
use Test;

plan 6;

# Shortcut
my $pCOMMAND = DSL::English::DataQueryWorkflows::Grammar;

#-----------------------------------------------------------
# Separate column commands
#-----------------------------------------------------------

ok $pCOMMAND.parse('separate column "Variable" into v1, v2 and Set'),
        'separate column "Variable" into v1, v2 and Set';

ok $pCOMMAND.parse('separate the data variable "Variable" into v1, v2 and Set'),
        'separate the data variable "Variable" into v1, v2 and Set';

ok $pCOMMAND.parse('separate the variable `VAR` into v1, v2 and Set'),
        'separate the variable `VAR` into v1, v2 and Set';

ok $pCOMMAND.parse('separate column "Variable" into v1, v2 and Set with the separator pattern ""'),
        'separate the data column "Variable" into v1, v2 and Set with the separator pattern ""';

ok $pCOMMAND.parse('separate the column "Variable" into v1, v2 and Set with the separator (.)(.)'),
        'separate the column "Variable" into v1, v2 and Set with the separator (.)(.)';

ok $pCOMMAND.parse('separate the data column "Variable" into v1, v2 and Set with the separator rx/""/'),
        'separate the data column "Variable" into v1, v2 and Set with the separator rx/""/';

done-testing;