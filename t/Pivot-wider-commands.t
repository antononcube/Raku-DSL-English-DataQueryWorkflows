use v6;
use lib 'lib';
use DSL::English::DataQueryWorkflows::Grammar;
use Test;

plan 7;

# Shortcut
my $pCOMMAND = DSL::English::DataQueryWorkflows::Grammar;

#-----------------------------------------------------------
# Pivot wider commands
#-----------------------------------------------------------

nok $pCOMMAND.parse('convert to broad form'),
        'convert to broad form';

nok $pCOMMAND.parse('convert to wide format'),
        'convert to long format';

nok $pCOMMAND.parse('to wider form'),
        'to wider form';

nok $pCOMMAND.parse('pivot to wide form'),
        'pivot to wide form';

ok $pCOMMAND.parse('pivot to wide form with identifier columns V1 and V2'),
        'pivot to wide form with identifier columns V1 and V2';

ok $pCOMMAND.parse('to wider format for id columns Set and Variable'),
        'to wider format for id columns Set and Variable';

ok $pCOMMAND.parse('to wide form for id columns Set and AutomaticKey variable column Variable and value column Value'),
        'to wide form for id columns Set and AutomaticKey variable column Variable and value column Value';

done-testing;