# Standard Data Wrangling Commands

## Introduction

This document demonstrates and exemplifies the abilities of the package
["DSL::English::DataQueryWorkflow"](https://raku.land/zef:antononcube/DSL::English::DataQueryWorkflows), [AAp1],
to produce executable code that fits majority of the data wrangling use cases.

The examples should give a good idea of the English-based Domain Specific Language (DSL)
utilized by [AAp1].

The data wrangling in Raku is done with the packages:
["Data::Generators"](https://raku.land/zef:antononcube/Data::Generators),
["Data::Reshapers"](https://raku.land/zef:antononcube/Data::Reshapers), and
["Data::Summarizers"](https://raku.land/zef:antononcube/Data::Summarizers).

For detailed introduction into data wrangling (with- and in Raku) see the article
["Introduction to data wrangling with Raku"](https://rakuforprediction.wordpress.com/2021/12/31/introduction-to-data-wrangling-with-raku/),
[AA1]. (And its Bulgarian version [AA2].)

The videos in the references provide introduction to data wrangling from a more general, multi-language perspective. 

Some of the data is acquired with the package
["Data::ExampleDatasets"](https://raku.land/zef:antononcube/Data::ExampleDatasets).

### Document execution

This is a "computable Markdown document" -- the Raku cells are (context-consecutively) evaluated with the
["literate programming"](https://en.wikipedia.org/wiki/Literate_programming)
package
["Text::CodeProcessing"](https://raku.land/cpan:ANTONOV/Text::CodeProcessing), [AA3, AAp7].

------

## Setup

### Parameters

```perl6
my $examplesTarget = 'Raku::Reshapers';
```
```
# Raku::Reshapers
```

### Load packages

```perl6
use Data::ExampleDatasets;
use Data::Reshapers;
use Data::Summarizers;
use Text::Plot;

use DSL::English::DataQueryWorkflows;
```
```
# (Any)
```

### Load data

*Actual data is not used at this point.*

#### Titanic data

We can obtain the Titanic dataset using the function `get-titanic-dataset` provided by "Data::Reshapers":

```perl6
my @dfTitanic = get-titanic-dataset();
dimensions(@dfTitanic)
```
```
# (1309 5)
```

#### Anscombe's quartet

The dataset named
["Anscombe's quartet"](https://en.wikipedia.org/wiki/Anscombe%27s_quartet)
has four datasets that have nearly identical simple descriptive statistics, 
yet have very different distributions and appear very different when graphed.

Anscombe's quartet is (usually) given in a table with eight columns that is somewhat awkward to work with.
Below we demonstrate data transformations that make plotting of the four datasets easier.
The DSL specifications used make those data transformations are programming language independent.

We can obtain the Anscombe's dataset using the function `example-dataset` provided by "Data::ExampleDatasets":

```perl6
my @dfAnscombe = |example-dataset('anscombe');
@dfAnscombe = |@dfAnscombe.map({ %( $_.keys Z=> $_.values>>.Numeric) });
dimensions(@dfAnscombe)
```
```
# (11 8)
```

#### Star Wars films data

We can obtain
[Star Wars films](https://en.wikipedia.org/wiki/List_of_Star_Wars_films)
datasets using (again) the function `example-dataset`:

```perl6
my @dfStarwars = example-dataset("https://raw.githubusercontent.com/antononcube/R-packages/master/DataQueryWorkflowsTests/inst/extdata/dfStarwars.csv");
my @dfStarwarsFilms = example-dataset("https://raw.githubusercontent.com/antononcube/R-packages/master/DataQueryWorkflowsTests/inst/extdata/dfStarwarsFilms.csv");
my @dfStarwarsStarships = example-dataset("https://raw.githubusercontent.com/antononcube/R-packages/master/DataQueryWorkflowsTests/inst/extdata/dfStarwarsStarships.csv");
my @dfStarwarsVehicles = example-dataset("https://raw.githubusercontent.com/antononcube/R-packages/master/DataQueryWorkflowsTests/inst/extdata/dfStarwarsVehicles.csv");

(@dfStarwars, @dfStarwarsFilms, @dfStarwarsStarships, @dfStarwarsVehicles).map({ dimensions($_) })
```
```
# ((87 11) (173 2) (31 2) (13 2))
```

------

## Multi-language translation

### Programming languages

```perl6
my $command0 = 'use dfStarwars; group by species; counts;';
<Python Raku R R::tidyverse WL>.map({ say "\n{ $_ }:\n", ToDataQueryWorkflowCode($command0, target => $_) });
```
```
# Python:
# obj = dfStarwars.copy()
# obj = obj.groupby(["species"])
# obj = obj.size()
# 
# Raku:
# $obj = dfStarwars ;
# $obj = group-by($obj, "species") ;
# $obj = $obj>>.elems
# 
# R:
# obj <- dfStarwars ;
# obj <- split( x = obj, f = "species" ) ;
# obj = length(obj)
# 
# R::tidyverse:
# dfStarwars %>%
# dplyr::group_by(species) %>%
# dplyr::count()
# 
# WL:
# obj = dfStarwars;
# obj = GroupBy[ obj, #["species"]& ];
# obj = Map[ Length, obj]
```

### Natural languages

```perl6
<Bulgarian Korean Russian Spanish>.map({ say "\n{ $_ }:\n", ToDataQueryWorkflowCode($command0, target => $_) });
```
```
# Bulgarian:
# използвай таблицата: dfStarwars
# групирай с колоните: species
# намери броя
# 
# Korean:
# 테이블 사용: dfStarwars
# 열로 그룹화: species
# 하위 그룹의 크기 찾기
# 
# Russian:
# использовать таблицу: dfStarwars
# групировать с колонками: species
# найти число
# 
# Spanish:
# utilizar la tabla: dfStarwars
# agrupar con columnas: "species"
# encontrar recuentos
```

------

## Using DSL cells

If the package "DSL::Shared::Utilities::ComprehensiveTranslations", [AAp3], is installed
then DSL specifications can be directly written in the Markdown cells.

Here is an example:

```raku-dsl
DSL TARGET Python::pandas;
include setup code;
use dfStarwars;
join with dfStarwarsFilms by "name"; 
group by species; 
counts;
```
```
# {
#   "USERID": "",
#   "DSLFUNCTION": "proto sub ToDataQueryWorkflowCode (Str $command, |) {*}",
#   "COMMAND": "DSL TARGET Python::pandas;\ninclude setup code;\nuse dfStarwars;\njoin with dfStarwarsFilms by \"name\"; \ngroup by species; \ncounts;\n",
#   "DSL": "DSL::English::DataQueryWorkflows",
#   "DSLTARGET": "Python::pandas",
#   "CODE": "obj = dfStarwars.copy()\nobj = obj.merge( dfStarwarsFilms, on = [\"name\"], how = \"inner\" )\nobj = obj.groupby([\"species\"])\nobj = obj.size()",
#   "SETUPCODE": "import pandas\nfrom ExampleDatasets import *"
# }
```

------

## Non-trivial workflow

In this section we generate and demonstrates data wrangling steps that 
clean, mutate, filter, group, and summarize a given dataset.

### Code generation

```perl6
my $command1 = '
use dfStarwars;
replace missing with `<0>`;
mutate with mass = `+$_<mass>` and height = `+$_<height>`;
show dimensions;
echo summary;
filter by birth_year greater than 27;
select homeworld, mass and height;
group by homeworld;
show counts;
summarize the variables mass and height with &mean and &median
';

ToDataQueryWorkflowCode($command1, target => $examplesTarget)
```
```
# $obj = dfStarwars ;
# $obj = $obj.deepmap({ ( ($_ eqv Any) or $_.isa(Nil) or $_.isa(Whatever) ) ?? <0> !! $_ }) ;
# $obj = $obj.map({ $_{"mass"} = +$_<mass>; $_{"height"} = +$_<height>; $_ }) ;
# say "dimensions: {dimensions($obj)}" ;
# records-summary($obj) ;
# $obj = $obj.grep({ $_{"birth_year"} > 27 }).Array ;
# $obj = select-columns($obj, ("homeworld", "mass", "height") ) ;
# $obj = group-by($obj, "homeworld") ;
# say "counts: ", $obj>>.elems ;
# $obj = $obj.map({ $_.key => summarize-at($_.value, ("mass", "height"), (&mean, &median)) })
```

### Execution steps (Raku)

Here is code that cleans the data of missing values, and shows dimensions and summary (corresponds to the first five lines above):

```perl6
my $obj = @dfStarwars ;
$obj = $obj.deepmap({ ( ($_ eqv Any) or $_.isa(Nil) or $_.isa(Whatever) ) ?? <0> !! $_ }) ;
$obj = $obj.map({ $_{"mass"} = +$_<mass>; $_{"height"} = +$_<height>; $_ }).Array ;
say "dimensions: {dimensions($obj)}" ;
records-summary($obj);
```
```
# dimensions: 87 11
# +------------------------+---------------+--------------------+----------------+---------------+---------------+----------------------+-----------------+----------------------+-----------------+---------------------+
# | name                   | skin_color    | birth_year         | species        | eye_color     | hair_color    | sex                  | homeworld       | height               | gender          | mass                |
# +------------------------+---------------+--------------------+----------------+---------------+---------------+----------------------+-----------------+----------------------+-----------------+---------------------+
# | Jek Tono Porkins => 1  | fair    => 17 | Min    => 0        | Human    => 35 | brown   => 21 | none    => 37 | male           => 60 | Naboo     => 11 | Min    => 0          | masculine => 66 | Min    => 0         |
# | Lando Calrissian => 1  | light   => 11 | 1st-Qu => 0        | Droid    => 6  | blue    => 19 | brown   => 18 | female         => 16 | 0         => 10 | 1st-Qu => 163        | feminine  => 17 | 1st-Qu => 0         |
# | Dormé            => 1  | grey    => 6  | Mean   => 43.27931 | 0        => 4  | yellow  => 11 | black   => 13 | none           => 6  | Tatooine  => 10 | Mean   => 162.333333 | 0         => 4  | Mean   => 65.993103 |
# | Wat Tambor       => 1  | green   => 6  | Median => 0        | Gungan   => 3  | black   => 10 | 0       => 5  | 0              => 4  | Kamino    => 3  | Median => 178        |                 | Median => 56.2      |
# | Ric Olié         => 1  | dark    => 6  | 3rd-Qu => 52       | Zabrak   => 2  | orange  => 8  | white   => 4  | hermaphroditic => 1  | Coruscant => 3  | 3rd-Qu => 191        |                 | 3rd-Qu => 80        |
# | Padmé Amidala    => 1  | pale    => 5  | Max    => 896      | Kaminoan => 2  | red     => 5  | blond   => 3  |                      | Alderaan  => 3  | Max    => 264        |                 | Max    => 1358      |
# | Ratts Tyerell    => 1  | brown   => 4  |                    | Mirialan => 2  | unknown => 3  | auburn  => 1  |                      | Ryloth    => 2  |                      |                 |                     |
# | (Other)          => 80 | (Other) => 32 |                    | (Other)  => 33 | (Other) => 10 | (Other) => 6  |                      | (Other)   => 45 |                      |                 |                     |
# +------------------------+---------------+--------------------+----------------+---------------+---------------+----------------------+-----------------+----------------------+-----------------+---------------------+
```

Here is the deduced type: 

```perl6
say deduce-type($obj);
```
```
# Vector((Any), 87)
```

Here is a sample of the dataset (wrangled so far):

```perl6
say to-pretty-table($obj.pick(7));
```
```
# +-----------+------------+------+-----------------+------+-----------+--------------+-----------+--------+------------+--------------+
# | homeworld | birth_year | sex  |       name      | mass |   gender  |   species    | eye_color | height | hair_color |  skin_color  |
# +-----------+------------+------+-----------------+------+-----------+--------------+-----------+--------+------------+--------------+
# |  Corellia |     21     | male |  Wedge Antilles |  77  | masculine |    Human     |   hazel   |  170   |   brown    |     fair     |
# |  Sullust  |     0      | male |    Nien Nunb    |  68  | masculine |  Sullustan   |   black   |  160   |    none    |     grey     |
# |  Mon Cala |     41     | male |      Ackbar     |  83  | masculine | Mon Calamari |   orange  |  180   |    none    | brown mottle |
# |   Naboo   |     0      | male |   Roos Tarpals  |  82  | masculine |    Gungan    |   orange  |  224   |    none    |     grey     |
# |    Ojom   |     0      | male | Dexter Jettster | 102  | masculine |   Besalisk   |   yellow  |  198   |    none    |    brown     |
# | Trandosha |     53     | male |      Bossk      | 113  | masculine |  Trandoshan  |    red    |  190   |    none    |    green     |
# |  Toydaria |     0      | male |      Watto      |  0   | masculine |  Toydarian   |   yellow  |  137   |   black    |  blue, grey  |
# +-----------+------------+------+-----------------+------+-----------+--------------+-----------+--------+------------+--------------+
```

Here we group by "homeworld" and show counts for each group:

```perl6
$obj = group-by($obj, "homeworld") ;
say "counts: ", $obj>>.elems ;
```
```
# counts: {0 => 10, Alderaan => 3, Aleen Minor => 1, Bespin => 1, Bestine IV => 1, Cato Neimoidia => 1, Cerea => 1, Champala => 1, Chandrila => 1, Concord Dawn => 1, Corellia => 2, Coruscant => 3, Dathomir => 1, Dorin => 1, Endor => 1, Eriadu => 1, Geonosis => 1, Glee Anselm => 1, Haruun Kal => 1, Iktotch => 1, Iridonia => 1, Kalee => 1, Kamino => 3, Kashyyyk => 2, Malastare => 1, Mirial => 2, Mon Cala => 1, Muunilinst => 1, Naboo => 11, Nal Hutta => 1, Ojom => 1, Quermia => 1, Rodia => 1, Ryloth => 2, Serenno => 1, Shili => 1, Skako => 1, Socorro => 1, Stewjon => 1, Sullust => 1, Tatooine => 10, Toydaria => 1, Trandosha => 1, Troiken => 1, Tund => 1, Umbara => 1, Utapau => 1, Vulpter => 1, Zolan => 1}
```

Here is summarization at specified columns with specified functions (from the "Stats"):

```perl6
use Stats;
$obj = $obj.map({ $_.key => summarize-at($_.value, ("mass", "height"), (&mean, &median)) });
say to-pretty-table($obj.pick(7));
```
```
# +------------+---------------+-------------+-------------+-------------+
# |            | height.median | mass.median |  mass.mean  | height.mean |
# +------------+---------------+-------------+-------------+-------------+
# | Coruscant  |   170.000000  |   0.000000  |  16.666667  |  173.666667 |
# | Haruun Kal |   188.000000  |  84.000000  |  84.000000  |  188.000000 |
# | Malastare  |   112.000000  |  40.000000  |  40.000000  |  112.000000 |
# | Nal Hutta  |   175.000000  | 1358.000000 | 1358.000000 |  175.000000 |
# | Quermia    |   264.000000  |   0.000000  |   0.000000  |  264.000000 |
# | Ryloth     |   179.000000  |  27.500000  |  27.500000  |  179.000000 |
# | Trandosha  |   190.000000  |  113.000000 |  113.000000 |  190.000000 |
# +------------+---------------+-------------+-------------+-------------+
```

------

## Joins

```perl6
my $command2 = "use dfStarwarsFilms;
left join with dfStarwars by 'name';
sort by name, film desc;
echo data summary;
take pipeline value";

ToDataQueryWorkflowCode($command2, target => $examplesTarget)
```
```
# $obj = dfStarwarsFilms ;
# $obj = join-across( $obj, dfStarwars, ("name"), join-spec=>"Left") ;
# $obj = $obj.sort({($_{"name"}, $_{"film"}) })>>.reverse ;
# records-summary($obj) ;
# $obj
````

------

## Cross tabulation

[Cross tabulation](https://en.wikipedia.org/wiki/Contingency_table) 
is a fundamental data wrangling operation:

### Code generation

```perl6
my $command3 = "use dfTitanic;
filter with passengerSex is 'male' and passengerSurvival equals 'died' or passengerSurvival is 'survived' ;
cross tabulate passengerClass, passengerSurvival over passengerAge;";

ToDataQueryWorkflowCode($command3, target => $examplesTarget);
```
```
# $obj = dfTitanic ;
# $obj = $obj.grep({ $_{"passengerSex"} eq "male" and $_{"passengerSurvival"} eq "died" or $_{"passengerSurvival"} eq "survived" }).Array ;
# $obj = cross-tabulate( $obj, "passengerClass", "passengerSurvival", "passengerAge" )
```

### Execution steps (Raku)

Copy the Titanic data into a "pipeline object" and show its dimensions and a sample of it:

```perl6
my $obj = @dfTitanic ;
say "Titanic dimensions:", dimensions(@dfTitanic);
say to-pretty-table($obj.pick(7));
```
```
# Titanic dimensions:(1309 5)
# +------+--------------+----------------+--------------+-------------------+
# |  id  | passengerAge | passengerClass | passengerSex | passengerSurvival |
# +------+--------------+----------------+--------------+-------------------+
# | 1204 |      40      |      3rd       |     male     |        died       |
# | 1009 |      40      |      3rd       |    female    |        died       |
# | 1138 |      -1      |      3rd       |     male     |        died       |
# | 1068 |      20      |      3rd       |    female    |      survived     |
# | 520  |      30      |      2nd       |     male     |        died       |
# | 938  |      0       |      3rd       |    female    |        died       |
# | 537  |      30      |      2nd       |    female    |      survived     |
# +------+--------------+----------------+--------------+-------------------+
```

Filter the data and show the number of rows in the result set:

```perl6
$obj = $obj.grep({ $_{"passengerSex"} eq "male" and $_{"passengerSurvival"} eq "died" or $_{"passengerSurvival"} eq "survived" }).Array ;
say $obj.elems;
```
```
# 1182
```

Cross tabulate and show the result:

```perl6
$obj = cross-tabulate( $obj, "passengerClass", "passengerSurvival", "passengerAge" );
say to-pretty-table($obj);
```
```
# +-----+------+----------+
# |     | died | survived |
# +-----+------+----------+
# | 1st | 4290 |   6671   |
# | 2nd | 4419 |   2776   |
# | 3rd | 7562 |   2720   |
# +-----+------+----------+
```

------

## Formulas with column references

Special care has to be taken when the specifying data mutations with formulas that reference to columns in the dataset.

The code corresponding to the `transform ...` line in this example produces 
*expected* result for the target "R::tidyverse":

```perl6
my $command4 = "use data frame dfStarwars;
keep the columns name, homeworld, mass & height;
transform with bmi = `mass/height^2*10000`;
filter rows by bmi >= 30 & height < 200;
arrange by the variables mass & height descending";

ToDataQueryWorkflowCode($command4, target => 'R::tidyverse');
```
```
# dfStarwars %>%
# dplyr::select(name, homeworld, mass, height) %>%
# dplyr::mutate(bmi = mass/height^2*10000) %>%
# dplyr::filter(bmi >= 30 & height < 200) %>%
# dplyr::arrange(desc(mass, height))
```

Specifically, for "Raku::Reshapers" the transform specification line has to refer to the context variable `$_`.
Here is an example:

```perl6
my $command4r = 'use data frame dfStarwars;
transform with bmi = `$_<mass>/$_<height>^2*10000` and homeworld = `$_<homeworld>.uc`;';

ToDataQueryWorkflowCode($command4r, target => 'Raku::Reshapers');
```
```
# $obj = dfStarwars ;
# $obj = $obj.map({ $_{"bmi"} = $_<mass>/$_<height>^2*10000; $_{"homeworld"} = $_<homeworld>.uc; $_ })
```

**Remark:** Note that we have to use single quotes for the command assignment; 
using double quotes will invoke Raku's string interpolation feature. 

------

## Grouping awareness

### Code generation 

Since there is no expectation to have a dedicated data transformation monad -- in whatever programming language -- we
can try to make the command sequence parsing to be "aware" of the grouping operations.

In the following example before applying the grouping operation in fourth line 
we have to flatten the data (which is grouped in the second line):

```perl6
my $command5 = "use dfTitanic; 
group by passengerClass; 
echo counts; 
group by passengerSex; 
counts";

ToDataQueryWorkflowCode($command5, target => $examplesTarget)
```
```
# $obj = dfTitanic ;
# $obj = group-by($obj, "passengerClass") ;
# say "counts: ", $obj>>.elems ;
# $obj = group-by($obj.values.reduce( -> $x, $y { [|$x, |$y] } ), "passengerSex") ;
# $obj = $obj>>.elems
```

### Execution steps (Raku)

First grouping:

```perl6
my $obj = @dfTitanic ;
$obj = group-by($obj, "passengerClass") ;
say "counts: ", $obj>>.elems ;
```
```
# counts: {1st => 323, 2nd => 277, 3rd => 709}
```

Before doing the second grouping we flatten the groups of the first:

```perl6
$obj = group-by($obj.values.reduce( -> $x, $y { [|$x, |$y] } ), "passengerSex") ;
$obj = $obj>>.elems
```
```
# {female => 466, male => 843}
```

Instead of `reduce` we can use the function `flatten` (provided by "Data::Reshapers"):

```perl6
my $obj2 = group-by(@dfTitanic , "passengerClass") ;
say "counts: ", $obj2>>.elems ;
$obj2 = group-by(flatten($obj2.values, max-level => 1).Array, "passengerSex") ;
say "counts: ", $obj2>>.elems;
```
```
# counts: {1st => 323, 2nd => 277, 3rd => 709}
# counts: {female => 466, male => 843}
```

------

## Complicated workflows

### Code generation

```perl6
my $command6 =
        'use dfAnscombe;
convert to long form;
separate the data column Variable into Variable and Set with separator pattern "";
to wide form for id columns Set and AutomaticKey variable column Variable and value column Value';

ToDataQueryWorkflowCode($command6, target => $examplesTarget)
```
```
# $obj = dfAnscombe ;
# $obj = to-long-format( $obj ) ;
# $obj = separate-column( $obj, "Variable", ("Variable", "Set"), sep => "" ) ;
# $obj = to-wide-format( $obj, identifierColumns => ("Set", "AutomaticKey"), variablesFrom => "Variable", valuesFrom => "Value" )
```

### Execution steps (Raku)

Get a copy of the dataset into a "pipeline object":

```perl6
my $obj = @dfAnscombe;
say to-pretty-table($obj);
```
```
# +----+----+-----------+-----------+----+----------+----+-----------+
# | x3 | x1 |     y4    |     y1    | x2 |    y2    | x4 |     y3    |
# +----+----+-----------+-----------+----+----------+----+-----------+
# | 10 | 10 |  6.580000 |  8.040000 | 10 | 9.140000 | 8  |  7.460000 |
# | 8  | 8  |  5.760000 |  6.950000 | 8  | 8.140000 | 8  |  6.770000 |
# | 13 | 13 |  7.710000 |  7.580000 | 13 | 8.740000 | 8  | 12.740000 |
# | 9  | 9  |  8.840000 |  8.810000 | 9  | 8.770000 | 8  |  7.110000 |
# | 11 | 11 |  8.470000 |  8.330000 | 11 | 9.260000 | 8  |  7.810000 |
# | 14 | 14 |  7.040000 |  9.960000 | 14 | 8.100000 | 8  |  8.840000 |
# | 6  | 6  |  5.250000 |  7.240000 | 6  | 6.130000 | 8  |  6.080000 |
# | 4  | 4  | 12.500000 |  4.260000 | 4  | 3.100000 | 19 |  5.390000 |
# | 12 | 12 |  5.560000 | 10.840000 | 12 | 9.130000 | 8  |  8.150000 |
# | 7  | 7  |  7.910000 |  4.820000 | 7  | 7.260000 | 8  |  6.420000 |
# | 5  | 5  |  6.890000 |  5.680000 | 5  | 4.740000 | 8  |  5.730000 |
# +----+----+-----------+-----------+----+----------+----+-----------+
```

Summarize Anscombe's quartet (using "Data::Summarizers", [AAp3]):

```perl6
records-summary($obj);
```
```
# +--------------+--------------------+-----------------+--------------------+--------------+--------------+--------------------+--------------+
# | x3           | y4                 | y3              | y2                 | x2           | x4           | y1                 | x1           |
# +--------------+--------------------+-----------------+--------------------+--------------+--------------+--------------------+--------------+
# | Min    => 4  | Min    => 5.25     | Min    => 5.39  | Min    => 3.1      | Min    => 4  | Min    => 8  | Min    => 4.26     | Min    => 4  |
# | 1st-Qu => 6  | 1st-Qu => 5.76     | 1st-Qu => 6.08  | 1st-Qu => 6.13     | 1st-Qu => 6  | 1st-Qu => 8  | 1st-Qu => 5.68     | 1st-Qu => 6  |
# | Mean   => 9  | Mean   => 7.500909 | Mean   => 7.5   | Mean   => 7.500909 | Mean   => 9  | Mean   => 9  | Mean   => 7.500909 | Mean   => 9  |
# | Median => 9  | Median => 7.04     | Median => 7.11  | Median => 8.14     | Median => 9  | Median => 8  | Median => 7.58     | Median => 9  |
# | 3rd-Qu => 12 | 3rd-Qu => 8.47     | 3rd-Qu => 8.15  | 3rd-Qu => 9.13     | 3rd-Qu => 12 | 3rd-Qu => 8  | 3rd-Qu => 8.81     | 3rd-Qu => 12 |
# | Max    => 14 | Max    => 12.5     | Max    => 12.74 | Max    => 9.26     | Max    => 14 | Max    => 19 | Max    => 10.84    | Max    => 14 |
# +--------------+--------------------+-----------------+--------------------+--------------+--------------+--------------------+--------------+
```

**Remark:** Note that Anscombe's sets have same x- and y- mean values. (But the sets have very different shapes.)

**Remark:** From the table above it is not clear how exactly we have to access the data in order 
to plot each of Anscombe's sets. The data wrangling steps below show a way to separate the sets
and make them amenable for set-wise manipulations.

Very often values of certain data parameters are conflated and put into dataset's column names.
(As in Anscombe's dataset.)

In those situations we:

- Convert the dataset into long format, since that allows column names to be treated as data

- Separate the values of a certain column into to two or more columns

Reshape the "pipeline object" into
[long format](https://en.wikipedia.org/wiki/Wide_and_narrow_data):

```perl6
$obj = to-long-format($obj);
to-pretty-table($obj.head(7))
```
```
# +----------+--------------+----------+
# | Variable | AutomaticKey |  Value   |
# +----------+--------------+----------+
# |    x4    |      0       |    8     |
# |    y2    |      0       | 9.140000 |
# |    y4    |      0       | 6.580000 |
# |    y3    |      0       | 7.460000 |
# |    x2    |      0       |    10    |
# |    x1    |      0       |    10    |
# |    y1    |      0       | 8.040000 |
# +----------+--------------+----------+
```

Separate the data column "Variable" into the columns "Variable" and "Set":

```perl6
$obj = separate-column( $obj, "Variable", ("Variable", "Set"), sep => "" ) ;
to-pretty-table($obj.head(7))
```
```
# +-----+--------------+----------+----------+
# | Set | AutomaticKey | Variable |  Value   |
# +-----+--------------+----------+----------+
# |  4  |      0       |    x     |    8     |
# |  2  |      0       |    y     | 9.140000 |
# |  4  |      0       |    y     | 6.580000 |
# |  3  |      0       |    y     | 7.460000 |
# |  2  |      0       |    x     |    10    |
# |  1  |      0       |    x     |    10    |
# |  1  |      0       |    y     | 8.040000 |
# +-----+--------------+----------+----------+
```

Reshape the "pipeline object" into
[wide format](https://en.wikipedia.org/wiki/Wide_and_narrow_data)
using appropriate identifier-, variable-, and value column names:

```perl6
$obj = to-wide-format( $obj, identifierColumns => ("Set", "AutomaticKey"), variablesFrom => "Variable", valuesFrom => "Value" );
to-pretty-table($obj.head(7))
```
```
# +-----+------+--------------+----+
# | Set |  y   | AutomaticKey | x  |
# +-----+------+--------------+----+
# |  1  | 8.04 |      0       | 10 |
# |  1  | 6.95 |      1       | 8  |
# |  1  | 7.58 |      2       | 13 |
# |  1  | 8.81 |      3       | 9  |
# |  1  | 8.33 |      4       | 11 |
# |  1  | 9.96 |      5       | 14 |
# |  1  | 7.24 |      6       | 6  |
# +-----+------+--------------+----+
```

Plot each dataset of Anscombe's quartet (using "Text::Plot", [AAp6]):

```perl6
group-by($obj, 'Set').map({ say "\n", text-list-plot( $_.value.map({ +$_<x> }).List, $_.value.map({ +$_<y> }).List, title => 'Set : ' ~ $_.key) })
```
```
# Set : 4                           
# +---+--------+--------+---------+--------+---------+-------+       
# |                                                          |       
# +                                                      *   +  12.00
# |                                                          |       
# |                                                          |       
# +                                                          +  10.00
# |                                                          |       
# |   *                                                      |       
# +   *                                                      +   8.00
# |   *                                                      |       
# |   *                                                      |       
# +                                                          +   6.00
# |   *                                                      |       
# |                                                          |       
# +---+--------+--------+---------+--------+---------+-------+       
#     8.00     10.00    12.00     14.00    16.00     18.00           
# 
#                           Set : 3                           
# +---+---------+---------+----------+---------+---------+---+       
# |                                                          |       
# |                                                 *        |       
# +                                                          +  12.00
# |                                                          |       
# |                                                          |       
# +                                                          +  10.00
# |                                                      *   |       
# |                                            *             |       
# +                                  *    *                  +   8.00
# |                       *    *                             |       
# |             *    *                                       |       
# +   *    *                                                 +   6.00
# |                                                          |       
# +---+---------+---------+----------+---------+---------+---+       
#     4.00      6.00      8.00       10.00     12.00     14.00       
# 
#                           Set : 1                           
# +---+---------+---------+----------+---------+---------+---+       
# |                                                          |       
# |                                            *             |       
# +                                                      *   +  10.00
# |                                                          |       
# |                            *                             |       
# +                                  *    *                  +   8.00
# |                                                 *        |       
# |             *         *                                  |       
# |                                                          |       
# +        *                                                 +   6.00
# |                                                          |       
# |   *              *                                       |       
# +                                                          +   4.00
# +---+---------+---------+----------+---------+---------+---+       
#     4.00      6.00      8.00       10.00     12.00     14.00       
# 
#                           Set : 2                           
# +---+---------+---------+----------+---------+---------+---+      
# |                                                          |      
# +                            *     *    *    *    *        +  9.00
# |                                                          |      
# +                       *                              *   +  8.00
# |                  *                                       |      
# +                                                          +  7.00
# +             *                                            +  6.00
# |                                                          |      
# +                                                          +  5.00
# |        *                                                 |      
# +                                                          +  4.00
# |   *                                                      |      
# +                                                          +  3.00
# +---+---------+---------+----------+---------+---------+---+      
#     4.00      6.00      8.00       10.00     12.00     14.00
```

------

## References

### Articles

[AA1] Anton Antonov,
["Introduction to data wrangling with Raku"](https://rakuforprediction.wordpress.com/2021/12/31/introduction-to-data-wrangling-with-raku/)
,
(2021), 
[RakuForPrediction at WordPress](https://rakuforprediction.wordpress.com).

[AA2] Anton Antonov,
["Увод в обработката на данни с Raku"](https://rakuforprediction.wordpress.com/2022/05/24/увод-в-обработката-на-данни-с-raku/)
,
(2022),
[RakuForPrediction at WordPress](https://rakuforprediction.wordpress.com).

[AA3] Anton Antonov,
["Raku Text::CodeProcessing"](https://rakuforprediction.wordpress.com/2021/07/13/raku-textcodeprocessing/),
(2021),
[RakuForPrediction at WordPress](https://rakuforprediction.wordpress.com).

[HW1] Hadley Wickham,
["The Split-Apply-Combine Strategy for Data Analysis"](https://www.jstatsoft.org/article/view/v040i01),
(2011),
[Journal of Statistical Software](https://www.jstatsoft.org/).

### Packages

[AAp1] Anton Antonov,
[DSL::English::DataQueryWorkflows Raku package](https://github.com/antononcube/Raku-DSL-English-DataQueryWorkflows),
(2020-2022),
[GitHub/antononcube](https://github.com/antononcube).

[AAp2] Anton Antonov,
[DSL::Bulgarian Raku package](https://github.com/antononcube/Raku-DSL-Bulgarian),
(2022),
[GitHub/antononcube](https://github.com/antononcube).

[AAp3] Anton Antonov,
[DSL::Shared::Utilities::ComprehensiveTranslations Raku package](https://github.com/antononcube/Raku-Text-Plot),
(2020-2022),
[GitHub/antononcube](https://github.com/antononcube).

[AAp4] Anton Antonov,
[Data::Generators Raku package](https://github.com/antononcube/Raku-Data-Generators),
(2021),
[GitHub/antononcube](https://github.com/antononcube).

[AAp5] Anton Antonov,
[Data::Reshapers Raku package](https://github.com/antononcube/Raku-Data-Reshapers),
(2021),
[GitHub/antononcube](https://github.com/antononcube).

[AAp6] Anton Antonov,
[Data::Summarizers Raku package](https://github.com/antononcube/Raku-Data-Summarizers),
(2021),
[GitHub/antononcube](https://github.com/antononcube).

[AAp7] Anton Antonov,
[Text::CodeProcessing Raku package](https://github.com/antononcube/Raku-Text-CodeProcessing),
(2021),
[GitHub/antononcube](https://github.com/antononcube).

[AAp8] Anton Antonov,
[Text::Plot Raku package](https://github.com/antononcube/Raku-Text-Plot),
(2022),
[GitHub/antononcube](https://github.com/antononcube).


### Videos

[AAv1] Anton Antonov,
["Multi-language Data-Wrangling Conversational Agent"](https://www.youtube.com/watch?v=pQk5jwoMSxs),
(2020),
[Wolfram Technology Conference 2020, YouTube/Wolfram](https://www.youtube.com/channel/UCJekgf6k62CQHdENWf2NgAQ).

