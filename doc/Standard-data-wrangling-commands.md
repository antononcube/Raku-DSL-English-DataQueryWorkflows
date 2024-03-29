# Standard Data Wrangling Commands

#### *Raku::Reshapers, version 0.7*

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

This document has examples that were used in the presentation “Multi-language Data-Wrangling Conversational Agent”, [AAv1]. 
That presentation is an introduction to data wrangling from a more general, multi-language perspective.
It is assumed that the readers of this document are familiar with the general data processing workflow discussed in the presentation [AAv1].

For detailed introduction into data wrangling (with- and in Raku) see the article
["Introduction to data wrangling with Raku"](https://rakuforprediction.wordpress.com/2021/12/31/introduction-to-data-wrangling-with-raku/),
[AA1]. (And its Bulgarian version [AA2].)

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

.say for <@dfStarwars @dfStarwarsFilms @dfStarwarsStarships @dfStarwarsVehicles>.map({ $_ => dimensions(::($_)) })
```
```
# @dfStarwars => (87 11)
# @dfStarwarsFilms => (173 2)
# @dfStarwarsStarships => (31 2)
# @dfStarwarsVehicles => (13 2)
```

------

## Multi-language translation

In this section show that the Raku package “DSL::English::DataQueryWorkflows” generates code for multiple programming languages. 
Also, it translates the English DSL into DSLs of other natural languages.

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
#   "CODE": "obj = dfStarwars.copy()\nobj = obj.merge( dfStarwarsFilms, on = [\"name\"], how = \"inner\" )\nobj = obj.groupby([\"species\"])\nobj = obj.size()",
#   "COMMAND": "DSL TARGET Python::pandas;\ninclude setup code;\nuse dfStarwars;\njoin with dfStarwarsFilms by \"name\"; \ngroup by species; \ncounts;\n",
#   "DSLFUNCTION": "proto sub ToDataQueryWorkflowCode (Str $command, |) {*}",
#   "USERID": "",
#   "DSL": "DSL::English::DataQueryWorkflows",
#   "DSLTARGET": "Python::pandas",
#   "SETUPCODE": "import pandas\nfrom ExampleDatasets import *"
# }
```

------

## Trivial workflow

In this section we demonstrate code generation and execution results for very simple (and very frequently used) sequence of data wrangling operations.

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

### Execution steps

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
see the section "Complicated and neat workflow".

### Code generation

Here we define a command that filters the Titanic dataset and then makes cross-tabulates:

```perl6
my $command1 = "use dfTitanic;
filter with passengerSex is 'male' and passengerSurvival equals 'died' or passengerSurvival is 'survived' ;
cross tabulate passengerClass, passengerSurvival over passengerAge;";

ToDataQueryWorkflowCode($command1, target => $examplesTarget);
```
```
# $obj = dfTitanic ;
# $obj = $obj.grep({ $_{"passengerSex"} eq "male" and $_{"passengerSurvival"} eq "died" or $_{"passengerSurvival"} eq "survived" }).Array ;
# $obj = cross-tabulate( $obj, "passengerClass", "passengerSurvival", "passengerAge" )
```

### Execution steps

Copy the Titanic data into a "pipeline object" and show its dimensions and a sample of it:

```perl6
my $obj = @dfTitanic ;
say "Titanic dimensions:", dimensions(@dfTitanic);
say to-pretty-table($obj.pick(7));
```
```
# Titanic dimensions:(1309 5)
# +--------------+----------------+-----+-------------------+--------------+
# | passengerAge | passengerClass |  id | passengerSurvival | passengerSex |
# +--------------+----------------+-----+-------------------+--------------+
# |      30      |      1st       |  30 |      survived     |     male     |
# |      40      |      2nd       | 565 |      survived     |    female    |
# |      40      |      3rd       | 825 |        died       |     male     |
# |      50      |      1st       | 189 |      survived     |    female    |
# |      20      |      1st       | 256 |      survived     |    female    |
# |      0       |      2nd       | 549 |      survived     |     male     |
# |      30      |      3rd       | 934 |        died       |     male     |
# +--------------+----------------+-----+-------------------+--------------+
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
# +-----+----------+------+
# |     | survived | died |
# +-----+----------+------+
# | 1st |   6671   | 4290 |
# | 2nd |   2776   | 4419 |
# | 3rd |   2720   | 7562 |
# +-----+----------+------+
```

------

## Mutation with formulas

In this section we discuss formula utilization to mutate data. We show how to use column references.

Special care has to be taken when the specifying data mutations with formulas that reference to columns in the dataset.

The code corresponding to the `transform ...` line in this example produces 
*expected* result for the target "R::tidyverse":

```perl6
my $command2 = "use data frame dfStarwars;
keep the columns name, homeworld, mass & height;
transform with bmi = `mass/height^2*10000`;
filter rows by bmi >= 30 & height < 200;
arrange by the variables mass & height descending";

ToDataQueryWorkflowCode($command2, target => 'R::tidyverse');
```
```
# dfStarwars %>%
# dplyr::select(name, homeworld, mass, height) %>%
# dplyr::mutate(bmi = mass/height^2*10000) %>%
# dplyr::filter(bmi >= 30 & height < 200) %>%
# dplyr::arrange(desc(mass), desc(height))
```

Specifically, for "Raku::Reshapers" the transform specification line has to refer to the context variable `$_`.
Here is an example:

```perl6
my $command2r = 'use data frame dfStarwars;
transform with bmi = `$_<mass>/$_<height>^2*10000` and homeworld = `$_<homeworld>.uc`;';

ToDataQueryWorkflowCode($command2r, target => 'Raku::Reshapers');
```
```
# $obj = dfStarwars ;
# $obj = $obj.map({ $_{"bmi"} = $_<mass>/$_<height>^2*10000; $_{"homeworld"} = $_<homeworld>.uc; $_ })
```

**Remark:** Note that we have to use single quotes for the command assignment; 
using double quotes will invoke Raku's string interpolation feature. 

------

## Grouping awareness

In this section we discuss the treatment of multiple "group by" invocations within the same DSL specification.

### Code generation 

Since there is no expectation to have a dedicated data transformation monad -- in whatever programming language -- we
can try to make the command sequence parsing to be "aware" of the grouping operations.

In the following example before applying the grouping operation in fourth line 
we have to flatten the data (which is grouped in the second line):

```perl6
my $command3 = "use dfTitanic; 
group by passengerClass; 
echo counts; 
group by passengerSex; 
counts";

ToDataQueryWorkflowCode($command3, target => $examplesTarget)
```
```
# $obj = dfTitanic ;
# $obj = group-by($obj, "passengerClass") ;
# say "counts: ", $obj>>.elems ;
# $obj = group-by($obj.values.reduce( -> $x, $y { [|$x, |$y] } ), "passengerSex") ;
# $obj = $obj>>.elems
```

### Execution steps

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

In this section we generate and demonstrate data wrangling steps that clean, mutate, filter, group, and summarize a given dataset.

### Code generation

```perl6
my $command4 = '
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

ToDataQueryWorkflowCode($command4, target => $examplesTarget)
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

### Execution steps

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
# +-----------------+---------------+-----------------------------------------+-----------------------+-----------------+----------------------------------------+----------------------------------------+---------------+----------------+----------------------+---------------+
# | gender          | eye_color     | height                                  | name                  | homeworld       | birth_year                             | mass                                   | hair_color    | species        | sex                  | skin_color    |
# +-----------------+---------------+-----------------------------------------+-----------------------+-----------------+----------------------------------------+----------------------------------------+---------------+----------------+----------------------+---------------+
# | masculine => 66 | brown   => 21 | Min                       => 66         | Sly Moore       => 1  | Naboo     => 11 | Min                       => 8         | Min                       => 15        | none    => 37 | Human    => 35 | male           => 60 | fair    => 17 |
# | feminine  => 17 | blue    => 19 | 1st-Qu                    => 166.5      | Bossk           => 1  | Tatooine  => 10 | 1st-Qu                    => 33        | 1st-Qu                    => 55        | brown   => 18 | Droid    => 6  | female         => 16 | light   => 11 |
# | NaN       => 4  | yellow  => 11 | Mean                      => 174.358025 | Dexter Jettster => 1  | NaN       => 10 | Mean                      => 87.565116 | Mean                      => 97.311864 | black   => 13 | NaN      => 4  | none           => 6  | dark    => 6  |
# |                 | black   => 10 | Median                    => 180        | Adi Gallia      => 1  | Alderaan  => 3  | Median                    => 52        | Median                    => 79        | NaN     => 5  | Gungan   => 3  | NaN            => 4  | green   => 6  |
# |                 | orange  => 8  | 3rd-Qu                    => 191        | Quarsh Panaka   => 1  | Kamino    => 3  | 3rd-Qu                    => 72        | 3rd-Qu                    => 85        | white   => 4  | Mirialan => 2  | hermaphroditic => 1  | grey    => 6  |
# |                 | red     => 5  | Max                       => 264        | Ben Quadinaros  => 1  | Coruscant => 3  | Max                       => 896       | Max                       => 1358      | blond   => 3  | Kaminoan => 2  |                      | pale    => 5  |
# |                 | unknown => 3  | (Any-Nan-Nil-or-Whatever) => 6          | Taun We         => 1  | Corellia  => 2  | (Any-Nan-Nil-or-Whatever) => 44        | (Any-Nan-Nil-or-Whatever) => 28        | grey    => 1  | Zabrak   => 2  |                      | brown   => 4  |
# |                 | (Other) => 10 |                                         | (Other)         => 80 | (Other)   => 45 |                                        |                                        | (Other) => 6  | (Other)  => 33 |                      | (Other) => 32 |
# +-----------------+---------------+-----------------------------------------+-----------------------+-----------------+----------------------------------------+----------------------------------------+---------------+----------------+----------------------+---------------+
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
# +------+-----------+-----------+-----------+---------------------+------------+--------+--------------+-----------+------------+--------------+
# | sex  |    mass   | eye_color |   gender  |         name        | birth_year | height |   species    | homeworld | hair_color |  skin_color  |
# +------+-----------+-----------+-----------+---------------------+------------+--------+--------------+-----------+------------+--------------+
# | male |     75    |   yellow  | masculine |      Palpatine      |     82     |  170   |    Human     |   Naboo   |    grey    |     pale     |
# | male |     83    |   orange  | masculine |        Ackbar       |     41     |  180   | Mon Calamari |  Mon Cala |    none    | brown mottle |
# | male |     82    |   yellow  | masculine |     Ki-Adi-Mundi    |     92     |  198   |    Cerean    |   Cerea   |   white    |     pale     |
# | male |    102    |   yellow  | masculine |   Dexter Jettster   |    NaN     |  198   |   Besalisk   |    Ojom   |    none    |    brown     |
# | male | 78.200000 |   brown   | masculine |      Boba Fett      | 31.500000  |  183   |    Human     |   Kamino  |   black    |     fair     |
# | male |    NaN    |   brown   | masculine | Bail Prestor Organa |     67     |  191   |    Human     |  Alderaan |   black    |     tan      |
# | male |     80    |   brown   | masculine |       Han Solo      |     29     |  180   |    Human     |  Corellia |   brown    |     fair     |
# +------+-----------+-----------+-----------+---------------------+------------+--------+--------------+-----------+------------+--------------+
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
# +-----------+-------------+---------------+------------+-------------+
# |           | height.mean | height.median | mass.mean  | mass.median |
# +-----------+-------------+---------------+------------+-------------+
# | Corellia  |  175.000000 |   175.000000  | 78.500000  |  78.500000  |
# | Coruscant |  173.666667 |   170.000000  |    NaN     |     NaN     |
# | Geonosis  |  183.000000 |   183.000000  | 80.000000  |  80.000000  |
# | Iridonia  |  171.000000 |   171.000000  |    NaN     |     NaN     |
# | Kashyyyk  |  231.000000 |   231.000000  | 124.000000 |  124.000000 |
# | Socorro   |  177.000000 |   177.000000  | 79.000000  |  79.000000  |
# | Trandosha |  190.000000 |   190.000000  | 113.000000 |  113.000000 |
# +-----------+-------------+---------------+------------+-------------+
```

------

## Joins

In this section we demonstrate the fundamental operation of joining two datasets.

### Code generation

```perl6
my $command5 = "use dfStarwarsFilms;
left join with dfStarwars by 'name';
replace missing with `<NaN>`;
sort by name, film desc;
take pipeline value";

ToDataQueryWorkflowCode($command5, target => $examplesTarget)
```
```
# $obj = dfStarwarsFilms ;
# $obj = join-across( $obj, dfStarwars, ("name"), join-spec=>"Left") ;
# $obj = $obj.deepmap({ ( ($_ eqv Any) or $_.isa(Nil) or $_.isa(Whatever) ) ?? <NaN> !! $_ }) ;
# $obj = $obj.sort({($_{"name"}, $_{"film"}) }).reverse.Array ;
# $obj
````

### Execution steps

```perl6
$obj = @dfStarwarsFilms ;
$obj = join-across( $obj, select-columns( @dfStarwars, <name species>), ("name"), join-spec=>"Left") ;
$obj = $obj.deepmap({ ( ($_ eqv Any) or $_.isa(Nil) or $_.isa(Whatever) ) ?? <NaN> !! $_ }) ;
$obj = $obj.sort({($_{"name"}, $_{"film"}) }).reverse ;
to-pretty-table($obj.head(12))
```
```
# +-----------------------+----------------+----------------------+
# |          name         |    species     |         film         |
# +-----------------------+----------------+----------------------+
# |       Zam Wesell      |    Clawdite    | Attack of the Clones |
# |          Yoda         | Yoda's species |  Return of the Jedi  |
# |      Yarael Poof      |    Quermian    |  The Phantom Menace  |
# |     Wilhuff Tarkin    |     Human      |      A New Hope      |
# | Wicket Systri Warrick |      Ewok      |  Return of the Jedi  |
# |     Wedge Antilles    |     Human      |      A New Hope      |
# |         Watto         |   Toydarian    |  The Phantom Menace  |
# |       Wat Tambor      |    Skakoan     | Attack of the Clones |
# |       Tion Medon      |     Pau'an     | Revenge of the Sith  |
# |        Taun We        |    Kaminoan    | Attack of the Clones |
# |        Tarfful        |    Wookiee     | Revenge of the Sith  |
# |       Sly Moore       |      NaN       | Revenge of the Sith  |
# +-----------------------+----------------+----------------------+
```

------

## Complicated and neat workflow

In this section we demonstrate a fairly complicated data wrangling sequence of operations that transforms [Anscombe's quartet](https://en.wikipedia.org/wiki/Anscombe's_quartet) into a form that is easier to plot.

**Remark:** Anscombe's quartet has four sets of points that have nearly the same x- and y- mean values. (But the sets have very different shapes.)

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

### Execution steps

Get a copy of the dataset into a "pipeline object":

```perl6
my $obj = @dfAnscombe;
say to-pretty-table($obj);
```
```
# +----+-----------+-----------+----+----------+----+-----------+----+
# | x2 |     y3    |     y1    | x3 |    y2    | x4 |     y4    | x1 |
# +----+-----------+-----------+----+----------+----+-----------+----+
# | 10 |  7.460000 |  8.040000 | 10 | 9.140000 | 8  |  6.580000 | 10 |
# | 8  |  6.770000 |  6.950000 | 8  | 8.140000 | 8  |  5.760000 | 8  |
# | 13 | 12.740000 |  7.580000 | 13 | 8.740000 | 8  |  7.710000 | 13 |
# | 9  |  7.110000 |  8.810000 | 9  | 8.770000 | 8  |  8.840000 | 9  |
# | 11 |  7.810000 |  8.330000 | 11 | 9.260000 | 8  |  8.470000 | 11 |
# | 14 |  8.840000 |  9.960000 | 14 | 8.100000 | 8  |  7.040000 | 14 |
# | 6  |  6.080000 |  7.240000 | 6  | 6.130000 | 8  |  5.250000 | 6  |
# | 4  |  5.390000 |  4.260000 | 4  | 3.100000 | 19 | 12.500000 | 4  |
# | 12 |  8.150000 | 10.840000 | 12 | 9.130000 | 8  |  5.560000 | 12 |
# | 7  |  6.420000 |  4.820000 | 7  | 7.260000 | 8  |  7.910000 | 7  |
# | 5  |  5.730000 |  5.680000 | 5  | 4.740000 | 8  |  6.890000 | 5  |
# +----+-----------+-----------+----+----------+----+-----------+----+
```

Summarize Anscombe's quartet (using "Data::Summarizers", [AAp3]):

```perl6
records-summary($obj);
```
```
# +--------------+--------------------+--------------------+--------------------+-----------------+--------------+--------------+--------------+
# | x1           | y1                 | y4                 | y2                 | y3              | x2           | x4           | x3           |
# +--------------+--------------------+--------------------+--------------------+-----------------+--------------+--------------+--------------+
# | Min    => 4  | Min    => 4.26     | Min    => 5.25     | Min    => 3.1      | Min    => 5.39  | Min    => 4  | Min    => 8  | Min    => 4  |
# | 1st-Qu => 6  | 1st-Qu => 5.68     | 1st-Qu => 5.76     | 1st-Qu => 6.13     | 1st-Qu => 6.08  | 1st-Qu => 6  | 1st-Qu => 8  | 1st-Qu => 6  |
# | Mean   => 9  | Mean   => 7.500909 | Mean   => 7.500909 | Mean   => 7.500909 | Mean   => 7.5   | Mean   => 9  | Mean   => 9  | Mean   => 9  |
# | Median => 9  | Median => 7.58     | Median => 7.04     | Median => 8.14     | Median => 7.11  | Median => 9  | Median => 8  | Median => 9  |
# | 3rd-Qu => 12 | 3rd-Qu => 8.81     | 3rd-Qu => 8.47     | 3rd-Qu => 9.13     | 3rd-Qu => 8.15  | 3rd-Qu => 12 | 3rd-Qu => 8  | 3rd-Qu => 12 |
# | Max    => 14 | Max    => 10.84    | Max    => 12.5     | Max    => 9.26     | Max    => 12.74 | Max    => 14 | Max    => 19 | Max    => 14 |
# +--------------+--------------------+--------------------+--------------------+-----------------+--------------+--------------+--------------+
```

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
# |      0       |    y3    | 7.460000 |
# |      0       |    y2    | 9.140000 |
# |      0       |    y1    | 8.040000 |
# |      0       |    y4    | 6.580000 |
# |      0       |    x4    |    8     |
# |      0       |    x1    |    10    |
# |      0       |    x3    |    10    |
# +--------------+----------+----------+
```

Separate the data column "Variable" into the columns "Variable" and "Set":

```perl6
$obj = separate-column( $obj, "Variable", ("Variable", "Set"), sep => "" ) ;
to-pretty-table($obj.head(7))
```
```
# +-----+----------+----------+--------------+
# | Set |  Value   | Variable | AutomaticKey |
# +-----+----------+----------+--------------+
# |  3  | 7.460000 |    y     |      0       |
# |  2  | 9.140000 |    y     |      0       |
# |  1  | 8.040000 |    y     |      0       |
# |  4  | 6.580000 |    y     |      0       |
# |  4  |    8     |    x     |      0       |
# |  1  |    10    |    x     |      0       |
# |  3  |    10    |    x     |      0       |
# +-----+----------+----------+--------------+
```

Reshape the "pipeline object" into
[wide format](https://en.wikipedia.org/wiki/Wide_and_narrow_data)
using appropriate identifier-, variable-, and value column names:

```perl6
$obj = to-wide-format( $obj, identifierColumns => ("Set", "AutomaticKey"), variablesFrom => "Variable", valuesFrom => "Value" );
to-pretty-table($obj.head(7))
```
```
# +-----+--------------+----+------+
# | Set | AutomaticKey | x  |  y   |
# +-----+--------------+----+------+
# |  1  |      0       | 10 | 8.04 |
# |  1  |      1       | 8  | 6.95 |
# |  1  |      2       | 13 | 7.58 |
# |  1  |      3       | 9  | 8.81 |
# |  1  |      4       | 11 | 8.33 |
# |  1  |      5       | 14 | 9.96 |
# |  1  |      6       | 6  | 7.24 |
# +-----+--------------+----+------+
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

