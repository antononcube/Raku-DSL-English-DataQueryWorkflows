use v6.d;

use DSL::English::DataQueryWorkflows;

#-----------------------------------------------------------
my $pCOMMAND = DSL::English::DataQueryWorkflows::Grammar;

sub dq-parse(Str:D $command, Str:D :$rule = 'TOP') {
    $pCOMMAND.parse($command, :$rule);
}

sub dq-interpret(Str:D $command,
                 Str:D:$rule = 'TOP',
                 :$actions = DSL::English::DataQueryWorkflows::Actions::WL::System.new) {
    $pCOMMAND.parse($command, :$rule, :$actions).made;
}

#----------------------------------------------------------

my $commands1 = '
use dfTitanic;
filter by passengerSex == "male" and passengerClass in ${"1st", "2nd"};
echo text grouping by variables;
group by passengerClass, passengerSurvival;count;
ungroup;';

my $commands2 = "
include setup code;
use dfStarwars;
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

my $commands6 = '
use starwars;
select the columns name, mass, height;
convert to long form using the columns mass and height, with the variable column "Var1";';

my $commands7 = 'use dfTitanic; replace missing with 0; select passengerSex, passengerClass, passengerAge';

my $commands8 = 'use dfTitanic; select passengerSex as sex and "passengerClass" as "class" and "passengerAge" as age';

my $commands9 = 'use dfTitanic; select "passengerSex", passengerClass, passengerAge as sex, class, age';

my $commands10 = '
use data frame dfStarwars;
keep the columns name, homeworld, mass & height;
replace missing in mass and height with 0;
replace missing with 0;
transform with bmi = `mass/height^2*10000`;
filter rows by bmi >= 30 & height < 200;
arrange by the variables mass & height descending';

my @testCommands = ($commands1, $commands2, $commands3, $commands4, $commands5, $commands6, $commands7, $commands8, $commands9, $commands10);

#----------------------------------------------------------

my @targets = ('Julia-DataFrames', 'Python-pandas', 'R-base', 'R-tidyverse', 'Raku-Reshapers', 'WL-System');
#my @targets = ('Bulgarian', 'English', 'Korean', 'Russian', 'Spanish');

my $dq-type = 'code';

for @testCommands -> $c {
    say "=" x 120;
    say $c;
    for @targets -> $t {
        say '-' x 60;
        say $t;
        say '-' x 60;
        my $start = now;

        my $res;

        given $dq-type {
            when $_ eq 'parse' {
                $res = dq-parse($c, rule => 'workflow-commands-list');
            }

            when $_ eq 'interpret' {
                $res = dq-interpret(
                        @testCommands[0],
                        rule => 'workflow-commands-list',
                        actions => DSL::English::DataQueryWorkflows::Actions::R::base.new);
            }

            default {
                $res = ToDataQueryWorkflowCode($c, $t, format => 'code', language => "English");
            }
        }

        say "time:", now - $start;
        say $res;
    }
};

say "=" x 120;
