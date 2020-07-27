use v6;
use lib 'lib';
use DSL::English::DataQueryWorkflows;
use Test;

plan 10;


#-----------------------------------------------------------
# Creation
#-----------------------------------------------------------

is to_DataQuery_dplyr('use data frame dfTitanic'),
        'dfTitanic',
        'use data frame dfTitanic';

like to_DataQuery_dplyr('select passengerAge'),
        / 'select(' \h* 'passengerAge' \h* ')' /,
        'select passengerAge';

like to_DataQuery_dplyr('select passengerAge and passengerSex'),
        / 'select(' \h* 'passengerAge' \h* ',' \h* 'passengerSex' \h* ')' /,
        'select passengerAge and passengerSex';

like to_DataQuery_dplyr('select passengerAge, passengerClass, and passengerSex'),
        / 'select(' \h* 'passengerAge' \h* ',' \h* 'passengerClass' ',' \h* 'passengerSex' \h* ')' /,
        'select passengerAge, passengerClass, and passengerSex';

like to_DataQuery_dplyr('drop the column passengerAge'),
        / 'mutate(' \h* 'passengerAge' \h* '=' \h* 'NULL' \h* ')' /,
        'drop passengerAge';

like to_DataQuery_dplyr('delete columns passengerAge and passengerSex'),
        / 'mutate(' \h* 'passengerAge' \h* '=' \h* 'NULL' \h* ',' \h* 'passengerSex' \h* '=' \h* 'NULL' \h* ')' /,
        'delete passengerAge and passengerSex';

like to_DataQuery_dplyr('drop columns passengerAge, passengerClass, and passengerSex'),
        / 'mutate(' \h* 'passengerAge' \h* '=' \h* 'NULL' \h* ',' \h* 'passengerClass' \h* '=' \h* 'NULL' \h* ',' \h* 'passengerSex' \h* '=' \h* 'NULL' \h* ')' /,
        'drop passengerAge, passengerClass, and passengerSex';

like to_DataQuery_dplyr('transform bmi1 = mass1, bmi2 = mass2'),
        / 'mutate(' \h* 'bmi1' \h* '=' \h* 'mass1' \h* ',' \h* 'bmi2' \h* '=' \h* 'mass2' \h* ')' /,
        'transform bmi1 = mass1, bmi2 = mass2';

like to_DataQuery_dplyr('mutate bmi = `mass/height^2`'),
        / 'mutate(' \h* 'bmi' \h* '=' \h* 'mass/height^2' \h* ')' /,
        'mutate bmi = mass/height^2';

like to_DataQuery_dplyr('mutate bmi1 = `mass/height^2` and bmi2 = `mass/height^2`'),
        / 'mutate(' \h* 'bmi1' \h* '=' \h* 'mass/height^2' \h* ',' \h* 'bmi2' \h* '=' \h* 'mass/height^2' \h* ')' /,
        'mutate bmi = `mass/height^2` and bmi2 = `mass/height^2`';

done-testing;