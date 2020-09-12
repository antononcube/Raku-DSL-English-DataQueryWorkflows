use lib './lib';
use lib '.';
use DSL::English::DataQueryWorkflows;

#say DataQueryWorkflows::Grammar.parse("select mass & height");

#say to_dplyr("filter by mass > 10 & height <200");

#say "=" x 10;
#
#say to_DataQuery_tidyverse('select mass & height');
#
#say "=" x 10;
#
#say to_DataQuery_tidyverse('use the data frame df;
#select mass and height;
#arrange by the variable mass & height desc');
#
#say "=" x 10;
#
#say to_DataQuery_pandas('use the data frame df;
#select mass and height;
#arrange by the variable mass & height desc');

say "=" x 10;

my $commands = 'use dfTitanic;filter by passengerSex == "male";echo text grouping by variables;group by passengerClass, passengerSurvival;count;ungroup;';

my $commands2 = "use dfStarwars;
semi join with dfStarwarsFilms by 'name';
sort by 'name', 'film' desc;
echo data summary;
set the pipeline value as var1";

my $commands3 = 'use iris;
sort by PetalWidth, SepalLength;
echo data summary;
group by Species;
echo data summary
';

my $commands4 = '
use dfTitanic;
delete missing values;
filter with passengerSex is "male" and passengerSurvival equals "died" or passengerSurvival is "survived" ;
filter by passengerClass is like "1.";
cross tabulate passengerClass over passengerAge;
';

my $commands5 = '
      use dfStarwars;
      filter with "gender" is "feminine" and "species" is "Human" or "height" is greater or equal than 160;
      select the columns "mass" & "height";
      keep distinct values only;
      mutate bmi = `obj.mass / obj.height ** 2`;
      arrange by the variable "bmi", "mass", "height" descending;';

my $commands6 = 'use dfTitanic;
rename columns "passengerSex" and "passengerAge" as "sex" and "age";
select age and sex;
cross tabulate sex over age;
summarize data;';

my $commands7 = 'use dfTitanic;
rename "passengerSex" and "passengerClass" as "sex" and "class";
cross tabulate "sex" and "class";
echo pipeline values;';

my $commands8 = 'use starwars;
select the columns name, mass, height;
convert to long form using the columns mass and height, and with the variable column name "Var1" and with values column name "VAL";
convert to wide form using the id column name and using variable column Var1 and with value column VAL';

my $commands9 = 'use dfTitanic;
select "passengerSex" as "sex", and "passengerClass" as "class";';

my $commands10 = 'use dfTitanic;
mutate sex = passengerSex, and class = passengerClass;';

say "\n", '=' x 30;
say '-' x 3, 'Julia-DataFrames:';
say '=' x 30;

#say DSL::English::DataQueryWorkflows::Grammar.parse( 'keep unique values only');

say ToDataQueryWorkflowCode($commands9, 'Spanish');


say "\n", '=' x 30;
say '-' x 3, 'R-tidyverse:';
say '=' x 30;

say ToDataQueryWorkflowCode($commands9, 'Korean');

#
#say "\n", '=' x 30;
#say '-' x 3, 'R-tidyverse:';
#say '=' x 30;
#
#say ToDataQueryWorkflowCode($commands2, 'R-tidyverse');
#
#say "\n", '-' x 3, 'Julia-DataFrames:';
#
#say ToDataQueryWorkflowCode( $commands4, 'Julia-DataFrames' );
#
#say "\n", '-' x 3, 'WL-System:';
#
#say ToDataQueryWorkflowCode( $commands4, 'WL-System' );
