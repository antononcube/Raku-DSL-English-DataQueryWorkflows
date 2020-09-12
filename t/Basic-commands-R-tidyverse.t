use v6;
use lib 'lib';
use DSL::English::DataQueryWorkflows;
use Test;

plan 11;


#-----------------------------------------------------------
# Basic commands
#-----------------------------------------------------------

is to_DataQuery_tidyverse('use data frame dfTitanic'),
        'dfTitanic',
        'use data frame dfTitanic';

like to_DataQuery_tidyverse('select passengerAge'),
        / 'select(' \h* 'passengerAge' \h* ')' /,
        'select passengerAge';

like to_DataQuery_tidyverse('select passengerAge and passengerSex'),
        / 'select(' \h* 'passengerAge' \h* ',' \h* 'passengerSex' \h* ')' /,
        'select passengerAge and passengerSex';

like to_DataQuery_tidyverse('select passengerAge, passengerClass, and passengerSex'),
        / 'select(' \h* 'passengerAge' \h* ',' \h* 'passengerClass' ',' \h* 'passengerSex' \h* ')' /,
        'select passengerAge, passengerClass, and passengerSex';


like to_DataQuery_tidyverse('select passengerAge as age, passengerClass as class'),
        / 'select(' \h* 'age' \h* '=' \h* 'passengerAge' \h* ',' \h* 'class' \h* '=' \h* 'passengerClass' \h* ')' /,
        'select passengerAge as age, passengerClass as class';

like to_DataQuery_tidyverse('drop the column passengerAge'),
        / 'mutate(' \h* 'passengerAge' \h* '=' \h* 'NULL' \h* ')' /,
        'drop passengerAge';

like to_DataQuery_tidyverse('delete columns passengerAge and passengerSex'),
        / 'mutate(' \h* 'passengerAge' \h* '=' \h* 'NULL' \h* ',' \h* 'passengerSex' \h* '=' \h* 'NULL' \h* ')' /,
        'delete passengerAge and passengerSex';

like to_DataQuery_tidyverse('drop columns passengerAge, passengerClass, and passengerSex'),
        / 'mutate(' \h* 'passengerAge' \h* '=' \h* 'NULL' \h* ',' \h* 'passengerClass' \h* '=' \h* 'NULL' \h* ',' \h* 'passengerSex' \h* '=' \h* 'NULL' \h* ')' /,
        'drop passengerAge, passengerClass, and passengerSex';

like to_DataQuery_tidyverse('transform bmi1 = mass1, bmi2 = mass2'),
        / 'mutate(' \h* 'bmi1' \h* '=' \h* 'mass1' \h* ',' \h* 'bmi2' \h* '=' \h* 'mass2' \h* ')' /,
        'transform bmi1 = mass1, bmi2 = mass2';

like to_DataQuery_tidyverse('mutate bmi = `mass/height^2`'),
        / 'mutate(' \h* 'bmi' \h* '=' \h* 'mass/height^2' \h* ')' /,
        'mutate bmi = mass/height^2';

like to_DataQuery_tidyverse('mutate bmi1 = `mass/height^2` and bmi2 = `mass/height^2`'),
        / 'mutate(' \h* 'bmi1' \h* '=' \h* 'mass/height^2' \h* ',' \h* 'bmi2' \h* '=' \h* 'mass/height^2' \h* ')' /,
        'mutate bmi = `mass/height^2` and bmi2 = `mass/height^2`';

done-testing;