use v6;
use lib 'lib';
use DSL::English::DataQueryWorkflows::Grammar;
use Test;

plan 19;

# Shortcut
my $pCOMMAND = DSL::English::DataQueryWorkflows::Grammar;

#-----------------------------------------------------------
# Basic commands
#-----------------------------------------------------------

ok $pCOMMAND.parse('use data frame dfTitanic'),
        'use data frame dfTitanic';

ok $pCOMMAND.parse('load data table dfTitanic'),
        'load data table dfTitanic';

ok $pCOMMAND.parse('keep only distinct values'),
        'keep only distinct values';

ok $pCOMMAND.parse('remove duplicates'),
        'remove duplicates';

ok $pCOMMAND.parse('exclude missing values'),
        'exclude missing values';

ok $pCOMMAND.parse('keep only complete cases'),
        'keep only complete cases';

ok $pCOMMAND.parse('select passengerAge'),
        'select passengerAge';

ok $pCOMMAND.parse('select passengerAge and passengerSex'),
        'select passengerAge and passengerSex';

ok $pCOMMAND.parse('select passengerAge, passengerClass, and passengerSex'),
        'select passengerAge, passengerClass, and passengerSex';

ok $pCOMMAND.parse('select passengerAge as age, passengerClass as class, and passengerSex as sex'),
        'select passengerAge as age, passengerClass as class, and passengerSex as sex';

ok $pCOMMAND.parse('drop passengerAge, passengerClass, and passengerSex'),
        'drop passengerAge, passengerClass, and passengerSex';

ok $pCOMMAND.parse('delete passengerAge and passengerSex'),
        'delete passengerAge and passengerSex';

ok $pCOMMAND.parse('rename passengerAge, passengerClass, and passengerSex as age, class, sex'),
        'rename passengerAge, passengerClass, and passengerSex as age, class, sex';

ok $pCOMMAND.parse('rename passengerAge as age, passengerClass as class and passengerSex as sex'),
        'rename passengerAge as age, passengerClass as class and passengerSex as sex';

ok $pCOMMAND.parse('drop passengerAge, passengerClass, and passengerSex'),
        'drop passengerAge, passengerClass, and passengerSex';

ok $pCOMMAND.parse('transform bmi1 = mass1 and bmi2 = mass2'),
        'transform bmi1 = mass1 and bmi2 = mass2';

ok $pCOMMAND.parse('transform bmi1 = mass1, bmi2 = mass2'),
        'transform bmi1 = mass1, bmi2 = mass2';

ok $pCOMMAND.parse('mutate bmi = `mass/height^2`'),
        'mutate bmi = `mass/height^2`';

ok $pCOMMAND.parse('mutate bmi = `mass/height^2` and bmi2 = `masx/height^2`'),
        'mutate bmi = `mass/height^2` and bmi2 = `masx/height^2`';

done-testing;