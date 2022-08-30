# Standard Data Wrangling Commands

## Introduction

This document demonstrates and exemplifies the abilities of the package
["DSL::English::DataQueryWorkflow"](https://raku.land/zef:antononcube/DSL::English::DataQueryWorkflows)
to produce executable code that fits majority of the data wrangling use cases.

------

## Setup

### Parameters

```perl6
my $examplesTarget = 'Raku';
```
```
# Raku
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

#### Anscombe quartet

See ["Anscombe's quartet"](https://en.wikipedia.org/wiki/Anscombe%27s_quartet).

We can obtain the Anscombe dataset using the function `example-dataset` provided by "Data::ExampleDatasets":

```perl6
my @dfAnscombe = |example-dataset('anscombe');
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
#my @dfStarwars = example-dataset("https://raw.githubusercontent.com/antononcube/R-packages/master/DataQueryWorkflowsTests/inst/extdata/dfStarwars.csv");
#my @dfStarwarsFilms = example-dataset("https://raw.githubusercontent.com/antononcube/R-packages/master/DataQueryWorkflowsTests/inst/extdata/dfStarwarsFilms.csv");
#my @dfStarwarsStarships = example-dataset("https://raw.githubusercontent.com/antononcube/R-packages/master/DataQueryWorkflowsTests/inst/extdata/dfStarwarsStarships.csv");
#my @dfStarwarsVehicles = example-dataset("https://raw.githubusercontent.com/antononcube/R-packages/master/DataQueryWorkflowsTests/inst/extdata/dfStarwarsVehicles.csv");
#
#(@ @dfStarwars, @dfStarwarsFilms, @dfStarwarsStarships, @dfStarwarsVehicles).map({ dimensions($_) })
```
```
# ()
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
# $obj = group-by( $obj, "species") ;
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

## Filter, group, and summarize

```perl6
my $command1 = "
use dfStarwars;
filter by birth_year greater than 27;
select homeworld, mass and height;
group by homeworld;
replace missing with 0;
replace 'NA' with 0;
summarize the variables mass and height with Mean and Median
";

ToDataQueryWorkflowCode($command1, target => $examplesTarget)
```
```
# $obj = dfStarwars ;
# $obj = $obj.grep({ $_{"birth_year"} > 27 }).Array ;
# $obj = select-columns($obj, ("homeworld", "mass", "height") ) ;
# $obj = group-by( $obj, "homeworld") ;
# $obj = $obj.deepmap({ ( ($_ eqv Any) or $_.isa(Nil) or $_.isa(Whatever) ) ?? 0 !! $_ }) ;
# $obj = $obj.deepmap({ $_ ~~ "NA" ?? 0 !! $_ }) ;
# $obj = $obj.map({ $_.key => summarize-at($_.value, ("mass", "height"), (Mean, Median)) })
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

Cross tabulation is a fundamental data wrangling operation:

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

------

## Formulas with column references

Special care has to be taken for when formulas the references to columns are used.

Here is an example:

```perl6
my $command4 = "use data frame dfStarwars;
keep the columns name, homeworld, mass & height;
transform with bmi = `mass/height^2*10000`;
filter rows by bmi >= 30 & height < 200;
arrange by the variables mass & height descending";

ToDataQueryWorkflowCode($command4, target => $examplesTarget);
```
```
# $obj = dfStarwars ;
# $obj = select-columns($obj, ("name", "homeworld", "mass", "height") ) ;
# note "mutate by pairs is not implemented" ;
# $obj = $obj.grep({ $_{"bmi"} >= 30 and $_{"height"} < 200 }).Array ;
# $obj = $obj.sort({($_{"mass"}, $_{"height"}) })>>.reverse
```

------

## Grouping awareness

Since there is no expectation to have a dedicated data transformation monad -- in whatever programming language -- we
can try to make the command sequence parsing to be "aware" of the grouping operations.

Here are is an example:

```perl6
my $command5 = "use dfStarwars; 
group by species; 
echo counts; 
group by homeworld; 
counts";

ToDataQueryWorkflowCode($command5, target => $examplesTarget)
```
```
# $obj = dfStarwars ;
# $obj = group-by( $obj, "species") ;
# say "counts: ", $obj>>.elems ;
# $obj = group-by( $obj, "homeworld") ;
# $obj = $obj>>.elems
```

------

### Complicated workflows

```perl6
to-pretty-table(@dfAnscombe)
```
```
# +-----------+----+----+-----------+----+----+----------+-----------+
# |     y3    | x4 | x1 |     y1    | x2 | x3 |    y2    |     y4    |
# +-----------+----+----+-----------+----+----+----------+-----------+
# |  7.460000 | 8  | 10 |  8.040000 | 10 | 10 | 9.140000 |  6.580000 |
# |  6.770000 | 8  | 8  |  6.950000 | 8  | 8  | 8.140000 |  5.760000 |
# | 12.740000 | 8  | 13 |  7.580000 | 13 | 13 | 8.740000 |  7.710000 |
# |  7.110000 | 8  | 9  |  8.810000 | 9  | 9  | 8.770000 |  8.840000 |
# |  7.810000 | 8  | 11 |  8.330000 | 11 | 11 | 9.260000 |  8.470000 |
# |  8.840000 | 8  | 14 |  9.960000 | 14 | 14 | 8.100000 |  7.040000 |
# |  6.080000 | 8  | 6  |  7.240000 | 6  | 6  | 6.130000 |  5.250000 |
# |  5.390000 | 19 | 4  |  4.260000 | 4  | 4  | 3.100000 | 12.500000 |
# |  8.150000 | 8  | 12 | 10.840000 | 12 | 12 | 9.130000 |  5.560000 |
# |  6.420000 | 8  | 7  |  4.820000 | 7  | 7  | 7.260000 |  7.910000 |
# |  5.730000 | 8  | 5  |  5.680000 | 5  | 5  | 4.740000 |  6.890000 |
# +-----------+----+----+-----------+----+----+----------+-----------+
```

#### Code generation

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
# $obj = to-wide-format( $obj, identifierColumn => "Set", "AutomaticKey", variablesFrom => "Variable", valuesFrom => "Value" )
```

#### Execution steps (Raku)

Get a copy of the dataset into a "pipeline object":

```perl6
my $obj = @dfAnscombe;
```
```
# [{x1 => 10, x2 => 10, x3 => 10, x4 => 8, y1 => 8.04, y2 => 9.14, y3 => 7.46, y4 => 6.58} {x1 => 8, x2 => 8, x3 => 8, x4 => 8, y1 => 6.95, y2 => 8.14, y3 => 6.77, y4 => 5.76} {x1 => 13, x2 => 13, x3 => 13, x4 => 8, y1 => 7.58, y2 => 8.74, y3 => 12.74, y4 => 7.71} {x1 => 9, x2 => 9, x3 => 9, x4 => 8, y1 => 8.81, y2 => 8.77, y3 => 7.11, y4 => 8.84} {x1 => 11, x2 => 11, x3 => 11, x4 => 8, y1 => 8.33, y2 => 9.26, y3 => 7.81, y4 => 8.47} {x1 => 14, x2 => 14, x3 => 14, x4 => 8, y1 => 9.96, y2 => 8.1, y3 => 8.84, y4 => 7.04} {x1 => 6, x2 => 6, x3 => 6, x4 => 8, y1 => 7.24, y2 => 6.13, y3 => 6.08, y4 => 5.25} {x1 => 4, x2 => 4, x3 => 4, x4 => 19, y1 => 4.26, y2 => 3.1, y3 => 5.39, y4 => 12.5} {x1 => 12, x2 => 12, x3 => 12, x4 => 8, y1 => 10.84, y2 => 9.13, y3 => 8.15, y4 => 5.56} {x1 => 7, x2 => 7, x3 => 7, x4 => 8, y1 => 4.82, y2 => 7.26, y3 => 6.42, y4 => 7.91} {x1 => 5, x2 => 5, x3 => 5, x4 => 8, y1 => 5.68, y2 => 4.74, y3 => 5.73, y4 => 6.89}]
```

Very often values of certain parameters are conflated and put into dataset's column names.
(As with Anscombe's dataset.)

In those situations we:

- Convert the dataset in long format, since that allows column names to be treated as data

- Separate the values of a certain column into to two or more columns

Convert to
[long format](https://en.wikipedia.org/wiki/Wide_and_narrow_data):

```perl6
$obj = to-long-format($obj);
to-pretty-table($obj.head(7))
```
```
# +----------+--------------+----------+
# |  Value   | AutomaticKey | Variable |
# +----------+--------------+----------+
# | 6.580000 |      0       |    y4    |
# | 7.460000 |      0       |    y3    |
# | 9.140000 |      0       |    y2    |
# |    10    |      0       |    x1    |
# |    10    |      0       |    x2    |
# | 8.040000 |      0       |    y1    |
# |    10    |      0       |    x3    |
# +----------+--------------+----------+
```

Separate the data column "Variable" into the columns "Variable" and "Set":

```perl6
$obj = separate-column( $obj, "Variable", ("Variable", "Set"), sep => "" ) ;
to-pretty-table($obj.head(7))
```
```
# +--------------+-----+----------+----------+
# | AutomaticKey | Set | Variable |  Value   |
# +--------------+-----+----------+----------+
# |      0       |  4  |    y     | 6.580000 |
# |      0       |  3  |    y     | 7.460000 |
# |      0       |  2  |    y     | 9.140000 |
# |      0       |  1  |    x     |    10    |
# |      0       |  2  |    x     |    10    |
# |      0       |  1  |    y     | 8.040000 |
# |      0       |  3  |    x     |    10    |
# +--------------+-----+----------+----------+
```

Convert to
[wide format](https://en.wikipedia.org/wiki/Wide_and_narrow_data)
using appropriate identifier-, variable-, and value column names:

```perl6
$obj = to-wide-format($obj, identifierColumns => <Set AutomaticKey>, variablesFrom => "Variable", valuesFrom => "Value");
to-pretty-table($obj.head(7))
```
```
# +--------------+-----+----+------+
# | AutomaticKey | Set | x  |  y   |
# +--------------+-----+----+------+
# |      0       |  1  | 10 | 8.04 |
# |      1       |  1  | 8  | 6.95 |
# |      2       |  1  | 13 | 7.58 |
# |      3       |  1  | 9  | 8.81 |
# |      4       |  1  | 11 | 8.33 |
# |      5       |  1  | 14 | 9.96 |
# |      6       |  1  | 6  | 7.24 |
# +--------------+-----+----+------+
```

Plot the Anscombe's quartet sets:

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

[HW1] Hadley Wickham,
["The Split-Apply-Combine Strategy for Data Analysis"](https://www.jstatsoft.org/article/view/v040i01),
(2011),
[Journal of Statistical Software](https://www.jstatsoft.org/).

### Packages

[AAp1] Anton Antonov,
[DSL::English Raku package](https://github.com/antononcube/Raku-DSL-English-DataQueryWorkflows),
(2020-2022),
[GitHub/antononcube](https://github.com/antononcube).

[AAp2] Anton Antonov,
[DSL::Bulgarian Raku package](https://github.com/antononcube/Raku-DSL-Bulgarian),
(2022),
[GitHub/antononcube](https://github.com/antononcube).

### Videos

[AAv1] Anton Antonov,
["Multi-language Data-Wrangling Conversational Agent"](https://www.youtube.com/watch?v=pQk5jwoMSxs),
(2020),
[Wolfram Technology Conference 2020, YouTube/Wolfram](https://www.youtube.com/channel/UCJekgf6k62CQHdENWf2NgAQ).

