use v6;
use lib 'lib';
use DSL::English::DataQueryWorkflows::Grammar;
use Test;

plan 7;

# Shortcut
my $pCOMMAND = DSL::English::DataQueryWorkflows::Grammar;

#-----------------------------------------------------------
# Inner join commands
#-----------------------------------------------------------

ok $pCOMMAND.parse('inner join with dfStarwarsVehicles'),
        'inner join with dfStarwarsVehicles';

ok $pCOMMAND.parse('inner join with dfStarwarsVehicles on "name"'),
        'inner join with dfStarwarsVehicles on "name"';

ok $pCOMMAND.parse('inner join with dfStarwarsVehicles by "character" -> "name"'),
        'inner join with dfStarwarsVehicles by "character" -> "name"';

ok $pCOMMAND.parse('inner join with dfStarwarsVehicles by "character" == "name"'),
        'inner join with dfStarwarsVehicles by "character" == "name"';

ok $pCOMMAND.parse('inner join with dfStarwarsVehicles by "character" = "name"'),
        'inner join with dfStarwarsVehicles by "character" = "name"';

ok $pCOMMAND.parse('inner join with dfStarwarsVehicles by "character" equals "name"'),
        'inner join with dfStarwarsVehicles by "character" equals "name"';

ok $pCOMMAND.parse('inner join with dfStarswars by "name" = "name2" and mass = mass3'),
        'inner join with dfStarswars by "name" = "name2" and mass = mass3';

done-testing;