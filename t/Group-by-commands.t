use v6;
use lib 'lib';
use DSL::English::DataQueryWorkflows::Grammar;
use Test;

plan 6;

# Shortcut
my $pCOMMAND = DSL::English::DataQueryWorkflows::Grammar;

#-----------------------------------------------------------
# Group-by commands
#-----------------------------------------------------------

ok $pCOMMAND.parse('group by the column Species'),
        'group by the column Species';

ok $pCOMMAND.parse('group by Species'),
        'group by Species';

ok $pCOMMAND.parse('group by "Species"'),
        'group by "Species"';

ok $pCOMMAND.parse('group over the column Species'),
        'group over the column Species';

ok $pCOMMAND.parse('group by using the column Species'),
        'group by using the column Species';

ok $pCOMMAND.parse('group with the column Species'),
        'group with the column Species';


done-testing;