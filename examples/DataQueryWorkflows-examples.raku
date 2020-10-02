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

my $commands = 'use dfTitanic; filter by passengerSex == "male"; echo text grouping by variables; group by passengerClass, passengerSurvival;count; ungroup;';

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
cross tabulate passengerClass and passengerSex over passengerAge;
';

my $commands5 = '
      use dfStarwars;
      filter with "gender" is "feminine" and "species" is "Human" or "height" is greater or equal than 160;
      select the columns "mass" & "height";
      keep distinct values only;
      mutate bmi = `obj.mass / obj.height ** 2`;
      arrange by the variable "bmi", "mass", "height" descending;';

my $commands6 = 'use starwars;
select the columns name, mass, height;
convert to long form using the columns mass and height, and with the variable column name "Var1" and with values column name "VAL";
convert to wide form using the id column name and using variable column Var1 and with value column VAL';

#my $commands7 = 'use dfTitanic; mutate sex = passengerSex, class = passengerClass and sex = passengerAge';

my $commands7 = 'use dfTitanic; replace missing with 0; select passengerSex, passengerClass, passengerAge';

my $commands8 = 'use dfTitanic; select passengerSex as sex and "passengerClass" as "class" and "passengerAge" as age';

my $commands9 = 'use dfTitanic; select "passengerSex", passengerClass, passengerAge as sex, class, age';


#my @commandsList = ($commands7, $commands8, $commands9);
#my @targetsList = map( { 'Python-pandas' }, 1 .. @commandsList.elems );

#my @targetsList = ( "Bulgarian", "Korean", "Spanish" );
#my @targetsList = ( 'Julia-DataFrames', 'Python-pandas',  'R-base', 'R-tidyverse', "WL" );
#my @targetsList = ( 'Python-pandas' );
#my @commandsList = map( { $commands7 }, 1 .. @targetsList.elems );
#
#for @commandsList Z @targetsList -> ($c, $t) {
#    say "\n", '=' x 30;
#    say $t, ':';
#    say '-' x 30;
#    say $c;
#    say '-' x 30;
#
#    say ToDataQueryWorkflowCode($c, $t);
#}

#my @testCommands = (
#'DSL TARGET Python-pandas; use dfTitanic; select the columns name, species, mass and height; cross tabulate species over mass',
#'DSL TARGET Python-pandas; use dfStarwars; select species, mass and height as species1, mass2, height2; cross tabulate species over mass;',
#'DSL TARGET Python-pandas; use dfStarwars; select species, homeworld, mass and height; cross tabulate species and homeworld over mass; take pipeline value',
#'DSL TARGET Python-pandas; use dfStarwars; select species as var1, mass as var2, height as var3'
#);

#my @testCommands = (
#'DSL TARGET Julia-DataFrames; use data frame dfStarwars; keep the columns name, homeworld, mass & height; arrange by mass, height, and name',
#'DSL TARGET Python-pandas; use data frame dfStarwars; keep the columns name, homeworld, mass & height; arrange by mass, height, and name',
#'DSL TARGET R-tidyverse; use data frame dfStarwars; keep the columns name, homeworld, mass & height; arrange by mass, height, and name',
#'DSL TARGET R-base; use data frame dfStarwars; keep the columns name, homeworld, mass & height; arrange by mass, height, and name',
#'DSL TARGET WL-System; use data frame dfStarwars; keep the columns name, homeworld, mass & height; arrange by mass, height, and name'
#);

#my @testCommands = (
#"
#DSL TARGET Python-pandas;
#use dfStarwars;
#filter by 'species' is 'Human';
#select name, sex, homeworld;
#inner join with dfStarwarsVehicles on 'name';
#"
#);
#'use dfTitanicLongForm; convert to wide form with id column id, variable column Variable and value column Value'
#my @testCommands = (
#'convert to long form using the columns mass and height, and using the variable column name "Var1" and with values column name "VAL"',
#'use dfTitanic; display data dimensions; to long form with identifier column id'
#);
my @testCommands = (
'use dfStarwars; ungroup; replace missing with 0; summarize mass with Mean, Max;',
'use dfStarwars; group by species; apply per group `length`; summarize mass with Mean, Max;',
'use dfStarwars; group by species and `"homeworld"`; echo data summary; group by gender; summarize mass with Mean, Max;'
);

#my @targets = ('Python-pandas');
#my @targets = ('Julia-DataFrames', 'Python-pandas', 'R-base', 'R-tidyverse', 'WL-System');
my @targets = ('Bulgarian', 'Korean', 'Spanish');

for @testCommands -> $c {
    say "=" x 30;
    say $c;
    for @targets -> $t {
        say '-' x 30;
        say $t;
        say '-' x 30;
        my $start = now;
        my $res = ToDataQueryWorkflowCode($c, $t);
        say "time:", now - $start;
        say $res;
    }
};