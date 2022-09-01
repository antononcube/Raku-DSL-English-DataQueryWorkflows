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

The data wrangling sections have two parts: a code generation part, and a execution steps part. 

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
use Stats;
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
my $command0 = 'use dfTitanic; group by passengerClass; counts;';
<Python Raku R R::tidyverse WL>.map({ say "\n{ $_ }:\n", ToDataQueryWorkflowCode($command0, target => $_) });
```
```
# Python:
# obj = dfTitanic.copy()
# obj = obj.groupby(["passengerClass"])
# obj = obj.size()
# 
# Raku:
# $obj = dfTitanic ;
# $obj = group-by($obj, "passengerClass") ;
# $obj = $obj>>.elems
# 
# R:
# obj <- dfTitanic ;
# obj <- split( x = obj, f = "passengerClass" ) ;
# obj = length(obj)
# 
# R::tidyverse:
# dfTitanic %>%
# dplyr::group_by(passengerClass) %>%
# dplyr::count()
# 
# WL:
# obj = dfTitanic;
# obj = GroupBy[ obj, #["passengerClass"]& ];
# obj = Map[ Length, obj]
```

### Natural languages

```perl6
<Bulgarian Korean Russian Spanish>.map({ say "\n{ $_ }:\n", ToDataQueryWorkflowCode($command0, target => $_) });
```
```
# Bulgarian:
# използвай таблицата: dfTitanic
# групирай с колоните: passengerClass
# намери броя
# 
# Korean:
# 테이블 사용: dfTitanic
# 열로 그룹화: passengerClass
# 하위 그룹의 크기 찾기
# 
# Russian:
# использовать таблицу: dfTitanic
# групировать с колонками: passengerClass
# найти число
# 
# Spanish:
# utilizar la tabla: dfTitanic
# agrupar con columnas: "passengerClass"
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
#   "DSL": "DSL::English::DataQueryWorkflows",
#   "DSLFUNCTION": "proto sub ToDataQueryWorkflowCode (Str $command, |) {*}",
#   "DSLTARGET": "Python::pandas",
#   "USERID": "",
#   "CODE": "obj = dfStarwars.copy()\nobj = obj.merge( dfStarwarsFilms, on = [\"name\"], how = \"inner\" )\nobj = obj.groupby([\"species\"])\nobj = obj.size()",
#   "COMMAND": "DSL TARGET Python::pandas;\ninclude setup code;\nuse dfStarwars;\njoin with dfStarwarsFilms by \"name\"; \ngroup by species; \ncounts;\n",
#   "SETUPCODE": "import pandas\nfrom ExampleDatasets import *"
# }
```

------

## Trivial workflow

### Code generation

For the simple specification:

```perl6
say $command0;
```
```
# use dfTitanic; group by passengerClass; counts;
```

We generate target code with `ToDataQueryWorkflowCode`:

```perl6
ToDataQueryWorkflowCode($command0, target => $examplesTarget)
```
```
# $obj = dfTitanic ;
# $obj = group-by($obj, "passengerClass") ;
# $obj = $obj>>.elems
```

### Execution steps (Raku)

Get the dataset into a "pipeline object":

```perl6
my $obj = @dfTitanic;
dimensions($obj)
```
```
# (1309 5)
```

Group by column:

```perl6
$obj = group-by($obj, "passengerClass") ;
$obj.elems
```
```
# 3
```

Assign group sizes to the "pipeline object":

```perl6
$obj = $obj>>.elems
```
```
# {1st => 323, 2nd => 277, 3rd => 709}
```

------

## Cross tabulation

[Cross tabulation](https://en.wikipedia.org/wiki/Contingency_table) 
is a fundamental data wrangling operation. For the related transformations to long- and wide-format
see the see the section "Complicated and neat workflow".

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
# +----------------+------+--------------+--------------+-------------------+
# | passengerClass |  id  | passengerSex | passengerAge | passengerSurvival |
# +----------------+------+--------------+--------------+-------------------+
# |      3rd       | 1179 |     male     |      -1      |        died       |
# |      3rd       | 1060 |     male     |      30      |        died       |
# |      3rd       | 752  |     male     |      20      |        died       |
# |      3rd       | 1074 |     male     |      -1      |        died       |
# |      2nd       | 454  |     male     |      20      |        died       |
# |      1st       |  84  |    female    |      60      |      survived     |
# |      1st       | 246  |    female    |      30      |      survived     |
# +----------------+------+--------------+--------------+-------------------+
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

## Non-trivial workflow

In this section we generate and demonstrates data wrangling steps that
clean, mutate, filter, group, and summarize a given dataset.

### Code generation

```perl6
my $command1 = '
use dfStarwars;
replace missing with `<NaN>`;
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
# $obj = $obj.deepmap({ ( ($_ eqv Any) or $_.isa(Nil) or $_.isa(Whatever) ) ?? <NaN> !! $_ }) ;
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
$obj = $obj.deepmap({ ( ($_ eqv Any) or $_.isa(Nil) or $_.isa(Whatever) ) ?? <NaN> !! $_ }) ;
$obj = $obj.map({ $_{"mass"} = +$_<mass>; $_{"height"} = +$_<height>; $_ }).Array ;
say "dimensions: {dimensions($obj)}" ;
records-summary($obj);
```
```
# dimensions: 87 11
# +-------------------+----------------+-----------------------------------------+----------------------+----------------------------------------+-----------------+----------------------+---------------+-----------------+---------------+----------------------------------------+
# | hair_color        | species        | height                                  | sex                  | mass                                   | gender          | name                 | eye_color     | homeworld       | skin_color    | birth_year                             |
# +-------------------+----------------+-----------------------------------------+----------------------+----------------------------------------+-----------------+----------------------+---------------+-----------------+---------------+----------------------------------------+
# | none        => 37 | Human    => 35 | Min                       => 66         | male           => 60 | Min                       => 15        | masculine => 66 | Dormé          => 1  | brown   => 21 | Naboo     => 11 | fair    => 17 | Min                       => 8         |
# | brown       => 18 | Droid    => 6  | 1st-Qu                    => 166.5      | female         => 16 | 1st-Qu                    => 55        | feminine  => 17 | Luke Skywalker => 1  | blue    => 19 | Tatooine  => 10 | light   => 11 | 1st-Qu                    => 33        |
# | black       => 13 | NaN      => 4  | Mean                      => 174.358025 | none           => 6  | Mean                      => 97.311864 | NaN       => 4  | Jango Fett     => 1  | yellow  => 11 | NaN       => 10 | green   => 6  | Mean                      => 87.565116 |
# | NaN         => 5  | Gungan   => 3  | Median                    => 180        | NaN            => 4  | Median                    => 79        |                 | Ben Quadinaros => 1  | black   => 10 | Coruscant => 3  | grey    => 6  | Median                    => 52        |
# | white       => 4  | Mirialan => 2  | 3rd-Qu                    => 191        | hermaphroditic => 1  | 3rd-Qu                    => 85        |                 | Ayla Secura    => 1  | orange  => 8  | Kamino    => 3  | dark    => 6  | 3rd-Qu                    => 72        |
# | blond       => 3  | Kaminoan => 2  | Max                       => 264        |                      | Max                       => 1358      |                 | Watto          => 1  | red     => 5  | Alderaan  => 3  | pale    => 5  | Max                       => 896       |
# | brown, grey => 1  | Wookiee  => 2  | (Any-Nan-Nil-or-Whatever) => 6          |                      | (Any-Nan-Nil-or-Whatever) => 28        |                 | Bib Fortuna    => 1  | hazel   => 3  | Mirial    => 2  | brown   => 4  | (Any-Nan-Nil-or-Whatever) => 44        |
# | (Other)     => 6  | (Other)  => 33 |                                         |                      |                                        |                 | (Other)        => 80 | (Other) => 10 | (Other)   => 45 | (Other) => 32 |                                        |
# +-------------------+----------------+-----------------------------------------+----------------------+----------------------------------------+-----------------+----------------------+---------------+-----------------+---------------+----------------------------------------+
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
# +---------------------+--------+------------+-----------+--------+----------------+-----------+------------+-----------+-----------+------------+
# |         name        |  sex   | birth_year |   gender  | height |    species     | eye_color | skin_color |    mass   | homeworld | hair_color |
# +---------------------+--------+------------+-----------+--------+----------------+-----------+------------+-----------+-----------+------------+
# |        IG-88        |  none  |     15     | masculine |  200   |     Droid      |    red    |   metal    |    140    |    NaN    |    none    |
# |       Tarfful       |  male  |    NaN     | masculine |  234   |    Wookiee     |    blue   |   brown    |    136    |  Kashyyyk |   brown    |
# |      Boba Fett      |  male  | 31.500000  | masculine |  183   |     Human      |   brown   |    fair    | 78.200000 |   Kamino  |   black    |
# |         Yoda        |  male  |    896     | masculine |   66   | Yoda's species |   brown   |   green    |     17    |    NaN    |   white    |
# |        Dormé        | female |    NaN     |  feminine |  165   |     Human      |   brown   |   light    |    NaN    |   Naboo   |   brown    |
# | Bail Prestor Organa |  male  |     67     | masculine |  191   |     Human      |   brown   |    tan     |    NaN    |  Alderaan |   black    |
# |   Luminara Unduli   | female |     58     |  feminine |  170   |    Mirialan    |    blue   |   yellow   | 56.200000 |   Mirial  |   black    |
# +---------------------+--------+------------+-----------+--------+----------------+-----------+------------+-----------+-----------+------------+
```

Here we group by "homeworld" and show counts for each group:

```perl6
$obj = group-by($obj, "homeworld") ;
say "counts: ", $obj>>.elems ;
```
```
# counts: {Alderaan => 3, Aleen Minor => 1, Bespin => 1, Bestine IV => 1, Cato Neimoidia => 1, Cerea => 1, Champala => 1, Chandrila => 1, Concord Dawn => 1, Corellia => 2, Coruscant => 3, Dathomir => 1, Dorin => 1, Endor => 1, Eriadu => 1, Geonosis => 1, Glee Anselm => 1, Haruun Kal => 1, Iktotch => 1, Iridonia => 1, Kalee => 1, Kamino => 3, Kashyyyk => 2, Malastare => 1, Mirial => 2, Mon Cala => 1, Muunilinst => 1, NaN => 10, Naboo => 11, Nal Hutta => 1, Ojom => 1, Quermia => 1, Rodia => 1, Ryloth => 2, Serenno => 1, Shili => 1, Skako => 1, Socorro => 1, Stewjon => 1, Sullust => 1, Tatooine => 10, Toydaria => 1, Trandosha => 1, Troiken => 1, Tund => 1, Umbara => 1, Utapau => 1, Vulpter => 1, Zolan => 1}
```

Here is summarization at specified columns with specified functions (from the "Stats"):

```perl6
$obj = $obj.map({ $_.key => summarize-at($_.value, ("mass", "height"), (&mean, &median)) });
say to-pretty-table($obj.pick(7));
```
```
# +-------------+------------+-------------+-------------+---------------+
# |             | mass.mean  | mass.median | height.mean | height.median |
# +-------------+------------+-------------+-------------+---------------+
# | Aleen Minor | 15.000000  |  15.000000  |  79.000000  |   79.000000   |
# | Chandrila   |    NaN     |     NaN     |  150.000000 |   150.000000  |
# | Coruscant   |    NaN     |     NaN     |  173.666667 |   170.000000  |
# | Iktotch     |    NaN     |     NaN     |  188.000000 |   188.000000  |
# | Kalee       | 159.000000 |  159.000000 |  216.000000 |   216.000000  |
# | Muunilinst  |    NaN     |     NaN     |  191.000000 |   191.000000  |
# | Trandosha   | 113.000000 |  113.000000 |  190.000000 |   190.000000  |
# +-------------+------------+-------------+-------------+---------------+
```

------

## Joins

### Code generation

```perl6
my $command2 = "use dfStarwarsFilms;
left join with dfStarwars by 'name';
replace missing with `<NaN>`;
sort by name, film desc;
take pipeline value";

ToDataQueryWorkflowCode($command2, target => $examplesTarget)
```
```
# $obj = dfStarwarsFilms ;
# $obj = join-across( $obj, dfStarwars, ("name"), join-spec=>"Left") ;
# $obj = $obj.deepmap({ ( ($_ eqv Any) or $_.isa(Nil) or $_.isa(Whatever) ) ?? <NaN> !! $_ }) ;
# $obj = $obj.sort({($_{"name"}, $_{"film"}) }).reverse ;
# $obj
````

### Execution steps (Raku)

```perl6
$obj = @dfStarwarsFilms ;
$obj = join-across( $obj, select-columns( @dfStarwars, <name species>), ("name"), join-spec=>"Left") ;
$obj = $obj.deepmap({ ( ($_ eqv Any) or $_.isa(Nil) or $_.isa(Whatever) ) ?? <NaN> !! $_ }) ;
$obj = $obj.sort({($_{"name"}, $_{"film"}) }).reverse ;
to-pretty-table($obj.head(12))
```
```
# +-----------------------+----------------------+----------------+
# |          name         |         film         |    species     |
# +-----------------------+----------------------+----------------+
# |       Zam Wesell      | Attack of the Clones |    Clawdite    |
# |          Yoda         |  Return of the Jedi  | Yoda's species |
# |      Yarael Poof      |  The Phantom Menace  |    Quermian    |
# |     Wilhuff Tarkin    |      A New Hope      |     Human      |
# | Wicket Systri Warrick |  Return of the Jedi  |      Ewok      |
# |     Wedge Antilles    |      A New Hope      |     Human      |
# |         Watto         |  The Phantom Menace  |   Toydarian    |
# |       Wat Tambor      | Attack of the Clones |    Skakoan     |
# |       Tion Medon      | Revenge of the Sith  |     Pau'an     |
# |        Taun We        | Attack of the Clones |    Kaminoan    |
# |        Tarfful        | Revenge of the Sith  |    Wookiee     |
# |       Sly Moore       | Revenge of the Sith  |      NaN       |
# +-----------------------+----------------------+----------------+
```

------

## Complicated and neat workflow

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
# +----------+----+----+-----------+-----------+----+----+-----------+
# |    y2    | x3 | x4 |     y1    |     y3    | x2 | x1 |     y4    |
# +----------+----+----+-----------+-----------+----+----+-----------+
# | 9.140000 | 10 | 8  |  8.040000 |  7.460000 | 10 | 10 |  6.580000 |
# | 8.140000 | 8  | 8  |  6.950000 |  6.770000 | 8  | 8  |  5.760000 |
# | 8.740000 | 13 | 8  |  7.580000 | 12.740000 | 13 | 13 |  7.710000 |
# | 8.770000 | 9  | 8  |  8.810000 |  7.110000 | 9  | 9  |  8.840000 |
# | 9.260000 | 11 | 8  |  8.330000 |  7.810000 | 11 | 11 |  8.470000 |
# | 8.100000 | 14 | 8  |  9.960000 |  8.840000 | 14 | 14 |  7.040000 |
# | 6.130000 | 6  | 8  |  7.240000 |  6.080000 | 6  | 6  |  5.250000 |
# | 3.100000 | 4  | 19 |  4.260000 |  5.390000 | 4  | 4  | 12.500000 |
# | 9.130000 | 12 | 8  | 10.840000 |  8.150000 | 12 | 12 |  5.560000 |
# | 7.260000 | 7  | 8  |  4.820000 |  6.420000 | 7  | 7  |  7.910000 |
# | 4.740000 | 5  | 8  |  5.680000 |  5.730000 | 5  | 5  |  6.890000 |
# +----------+----+----+-----------+-----------+----+----+-----------+
```

Summarize Anscombe's quartet (using "Data::Summarizers", [AAp3]):

```perl6
records-summary($obj);
```
```
# +--------------+-----------------+--------------+--------------------+--------------------+--------------+--------------------+--------------+
# | x1           | y3              | x2           | y4                 | y1                 | x4           | y2                 | x3           |
# +--------------+-----------------+--------------+--------------------+--------------------+--------------+--------------------+--------------+
# | Min    => 4  | Min    => 5.39  | Min    => 4  | Min    => 5.25     | Min    => 4.26     | Min    => 8  | Min    => 3.1      | Min    => 4  |
# | 1st-Qu => 6  | 1st-Qu => 6.08  | 1st-Qu => 6  | 1st-Qu => 5.76     | 1st-Qu => 5.68     | 1st-Qu => 8  | 1st-Qu => 6.13     | 1st-Qu => 6  |
# | Mean   => 9  | Mean   => 7.5   | Mean   => 9  | Mean   => 7.500909 | Mean   => 7.500909 | Mean   => 9  | Mean   => 7.500909 | Mean   => 9  |
# | Median => 9  | Median => 7.11  | Median => 9  | Median => 7.04     | Median => 7.58     | Median => 8  | Median => 8.14     | Median => 9  |
# | 3rd-Qu => 12 | 3rd-Qu => 8.15  | 3rd-Qu => 12 | 3rd-Qu => 8.47     | 3rd-Qu => 8.81     | 3rd-Qu => 8  | 3rd-Qu => 9.13     | 3rd-Qu => 12 |
# | Max    => 14 | Max    => 12.74 | Max    => 14 | Max    => 12.5     | Max    => 10.84    | Max    => 19 | Max    => 9.26     | Max    => 14 |
# +--------------+-----------------+--------------+--------------------+--------------------+--------------+--------------------+--------------+
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
# +--------------+----------+----------+
# | AutomaticKey | Variable |  Value   |
# +--------------+----------+----------+
# |      0       |    y2    | 9.140000 |
# |      0       |    y1    | 8.040000 |
# |      0       |    y3    | 7.460000 |
# |      0       |    y4    | 6.580000 |
# |      0       |    x1    |    10    |
# |      0       |    x3    |    10    |
# |      0       |    x2    |    10    |
# +--------------+----------+----------+
```

Separate the data column "Variable" into the columns "Variable" and "Set":

```perl6
$obj = separate-column( $obj, "Variable", ("Variable", "Set"), sep => "" ) ;
to-pretty-table($obj.head(7))
```
```
# +----------+--------------+----------+-----+
# | Variable | AutomaticKey |  Value   | Set |
# +----------+--------------+----------+-----+
# |    y     |      0       | 9.140000 |  2  |
# |    y     |      0       | 8.040000 |  1  |
# |    y     |      0       | 7.460000 |  3  |
# |    y     |      0       | 6.580000 |  4  |
# |    x     |      0       |    10    |  1  |
# |    x     |      0       |    10    |  3  |
# |    x     |      0       |    10    |  2  |
# +----------+--------------+----------+-----+
```

Reshape the "pipeline object" into
[wide format](https://en.wikipedia.org/wiki/Wide_and_narrow_data)
using appropriate identifier-, variable-, and value column names:

```perl6
$obj = to-wide-format( $obj, identifierColumns => ("Set", "AutomaticKey"), variablesFrom => "Variable", valuesFrom => "Value" );
to-pretty-table($obj.head(7))
```
```
# +--------------+----+-----+------+
# | AutomaticKey | x  | Set |  y   |
# +--------------+----+-----+------+
# |      0       | 10 |  1  | 8.04 |
# |      1       | 8  |  1  | 6.95 |
# |      2       | 13 |  1  | 7.58 |
# |      3       | 9  |  1  | 8.81 |
# |      4       | 11 |  1  | 8.33 |
# |      5       | 14 |  1  | 9.96 |
# |      6       | 6  |  1  | 7.24 |
# +--------------+----+-----+------+
```

Plot each dataset of Anscombe's quartet (using "Text::Plot", [AAp6]):

```perl6
group-by($obj, 'Set').map({ say "\n", text-list-plot( $_.value.map({ +$_<x> }).List, $_.value.map({ +$_<y> }).List, title => 'Set : ' ~ $_.key) })
```
```
# Set : 1                           
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
# 
#                           Set : 4                           
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

