use v6;
use lib 'lib';
use DSL::English::DataQueryWorkflows::Grammar;
use Test;

plan 7;

# Shortcut
my $pCOMMAND = DSL::English::DataQueryWorkflows::Grammar;

#-----------------------------------------------------------
# Pivot longer commands
#-----------------------------------------------------------

ok $pCOMMAND.parse('convert to narrow form'),
        'convert to narrow form';

ok $pCOMMAND.parse('convert to long format'),
        'convert to long format';

ok $pCOMMAND.parse('to longer form'),
        'to longer form';

ok $pCOMMAND.parse('pivot to long form'),
        'pivot to long form';

ok $pCOMMAND.parse('pivot to long form with variable columns V1 and V2'),
        'pivot to long form with variable columns V1 and V2';

ok $pCOMMAND.parse('pivot to long form with id columns ID1, ID2 with variable columns V1 and V2'),
        'pivot to long form with id columns ID1, ID2 with variable columns V1 and V2';

# This is parsed but the result is not correct: the identifier columns list is {"ID1", "ID2", "variable"}.
ok $pCOMMAND.parse('pivot to long form with id columns ID1, ID2 and variable columns V1 and V2'),
        'pivot to long form with id columns ID1, ID2 and variable columns V1 and V2';


done-testing;