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

my $commands2 = "use starwars;
inner join with starwars_films by 'name';
sort by name, film desc;
echo data summary";

my $commands3 = 'use iris;
sort by PetalWidth, SepalLength;
echo data summary;
group by Species;
echo data summary
';

my $commands4 = '
use dfTitanic;
filter with passengerSex is "male" and passengerSurvival equals "died" or passengerSurvival is "survived" ;
filter by passengerClass is like "1.";
cross tabulate passengerClass, passengerSurvival over passengerAge;
';

my $commands5 = '
      use starwars;
      filter with gender is "female";
      select the columns mass & height;
      mutate bmi = `mass/height^2`;
      arrange by the variable bmi, mass, height descending;';

my $commands6 = 'use dfTitanic; rename columns "passengerSex" and "passengerAge" as "sex" and "age"; summarize data';

my $commands7 = 'use dfTitanic; drop columns "passengerSex" and "passengerAge"; summarize data';

my $commands8 = 'use starwars;
select the columns name, mass, height;
convert to long form using the columns mass and height, with the variable column name "Var1" and values column name "VAL"';

say "\n", '=' x 30;
say '-' x 3, 'R-tidyverse:';
say '=' x 30;

#say DSL::English::DataQueryWorkflows::Grammar.subparse( 'convert to long form using the variable column name "Var1" and the values column name "VAL"' );

say ToDataQueryWorkflowCode($commands8, 'R-base');


say "\n", '=' x 30;
say '-' x 3, 'R-base:';
say '=' x 30;

say ToDataQueryWorkflowCode($commands5, 'R-base');
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


