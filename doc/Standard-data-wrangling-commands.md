# Standard Data Wrangling Commands

## Introduction

This document demonstrates and exemplifies the abilities of the package
["DSL::English::DataQueryWorkflow"](https://raku.land/zef:antononcube/DSL::English::DataQueryWorkflows)
to produce executable code that fits majority of the data wrangling use cases.

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
["Text::CodeProcessing"](https://raku.land/cpan:ANTONOV/Text::CodeProcessing), [AA3, AAp5].

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
# $obj = to-wide-format( $obj, identifierColumns => ("Set", "AutomaticKey"), variablesFrom => "Variable", valuesFrom => "Value" )
```

#### Execution steps (Raku)

Get a copy of the dataset into a "pipeline object":

```perl6
my $obj = @dfAnscombe;
say to-pretty-table($obj);
```
```
# +----------+----+----+-----------+-----------+----+----+-----------+
# |    y2    | x4 | x3 |     y4    |     y3    | x2 | x1 |     y1    |
# +----------+----+----+-----------+-----------+----+----+-----------+
# | 9.140000 | 8  | 10 |  6.580000 |  7.460000 | 10 | 10 |  8.040000 |
# | 8.140000 | 8  | 8  |  5.760000 |  6.770000 | 8  | 8  |  6.950000 |
# | 8.740000 | 8  | 13 |  7.710000 | 12.740000 | 13 | 13 |  7.580000 |
# | 8.770000 | 8  | 9  |  8.840000 |  7.110000 | 9  | 9  |  8.810000 |
# | 9.260000 | 8  | 11 |  8.470000 |  7.810000 | 11 | 11 |  8.330000 |
# | 8.100000 | 8  | 14 |  7.040000 |  8.840000 | 14 | 14 |  9.960000 |
# | 6.130000 | 8  | 6  |  5.250000 |  6.080000 | 6  | 6  |  7.240000 |
# | 3.100000 | 19 | 4  | 12.500000 |  5.390000 | 4  | 4  |  4.260000 |
# | 9.130000 | 8  | 12 |  5.560000 |  8.150000 | 12 | 12 | 10.840000 |
# | 7.260000 | 8  | 7  |  7.910000 |  6.420000 | 7  | 7  |  4.820000 |
# | 4.740000 | 8  | 5  |  6.890000 |  5.730000 | 5  | 5  |  5.680000 |
# +----------+----+----+-----------+-----------+----+----+-----------+
```

Summarize Anscombe's quartet (using "Data::Summarizers", [AAp3]):

```perl6
records-summary($obj);
```
```
# +--------------+--------------------+--------------+--------------------+--------------+--------------------+--------------+-----------------+
# | x1           | y1                 | x2           | y2                 | x3           | y4                 | x4           | y3              |
# +--------------+--------------------+--------------+--------------------+--------------+--------------------+--------------+-----------------+
# | Min    => 4  | Min    => 4.26     | Min    => 4  | Min    => 3.1      | Min    => 4  | Min    => 5.25     | Min    => 8  | Min    => 5.39  |
# | 1st-Qu => 6  | 1st-Qu => 5.68     | 1st-Qu => 6  | 1st-Qu => 6.13     | 1st-Qu => 6  | 1st-Qu => 5.76     | 1st-Qu => 8  | 1st-Qu => 6.08  |
# | Mean   => 9  | Mean   => 7.500909 | Mean   => 9  | Mean   => 7.500909 | Mean   => 9  | Mean   => 7.500909 | Mean   => 9  | Mean   => 7.5   |
# | Median => 9  | Median => 7.58     | Median => 9  | Median => 8.14     | Median => 9  | Median => 7.04     | Median => 8  | Median => 7.11  |
# | 3rd-Qu => 12 | 3rd-Qu => 8.81     | 3rd-Qu => 12 | 3rd-Qu => 9.13     | 3rd-Qu => 12 | 3rd-Qu => 8.47     | 3rd-Qu => 8  | 3rd-Qu => 8.15  |
# | Max    => 14 | Max    => 10.84    | Max    => 14 | Max    => 9.26     | Max    => 14 | Max    => 12.5     | Max    => 19 | Max    => 12.74 |
# +--------------+--------------------+--------------+--------------------+--------------+--------------------+--------------+-----------------+
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
# |    y1    |      0       | 8.040000 |
# |    x3    |      0       |    10    |
# |    x2    |      0       |    10    |
# |    x1    |      0       |    10    |
# |    y4    |      0       | 6.580000 |
# |    y2    |      0       | 9.140000 |
# |    y3    |      0       | 7.460000 |
# +----------+--------------+----------+
```

Separate the data column "Variable" into the columns "Variable" and "Set":

```perl6
$obj = separate-column( $obj, "Variable", ("Variable", "Set"), sep => "" ) ;
to-pretty-table($obj.head(7))
```
```
# +----------+-----+--------------+----------+
# |  Value   | Set | AutomaticKey | Variable |
# +----------+-----+--------------+----------+
# | 8.040000 |  1  |      0       |    y     |
# |    10    |  3  |      0       |    x     |
# |    10    |  2  |      0       |    x     |
# |    10    |  1  |      0       |    x     |
# | 6.580000 |  4  |      0       |    y     |
# | 9.140000 |  2  |      0       |    y     |
# | 7.460000 |  3  |      0       |    y     |
# +----------+-----+--------------+----------+
```

Reshape the "pipeline object" into
[wide format](https://en.wikipedia.org/wiki/Wide_and_narrow_data)
using appropriate identifier-, variable-, and value column names:

```perl6
$obj = to-wide-format( $obj, identifierColumns => ("Set", "AutomaticKey"), variablesFrom => "Variable", valuesFrom => "Value" );
to-pretty-table($obj.head(7))
```
```
# +----+-----+------+--------------+
# | x  | Set |  y   | AutomaticKey |
# +----+-----+------+--------------+
# | 10 |  1  | 8.04 |      0       |
# | 8  |  1  | 6.95 |      1       |
# | 13 |  1  | 7.58 |      2       |
# | 9  |  1  | 8.81 |      3       |
# | 11 |  1  | 8.33 |      4       |
# | 14 |  1  | 9.96 |      5       |
# | 6  |  1  | 7.24 |      6       |
# +----+-----+------+--------------+
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
[DSL::English Raku package](https://github.com/antononcube/Raku-DSL-English-DataQueryWorkflows),
(2020-2022),
[GitHub/antononcube](https://github.com/antononcube).

[AAp2] Anton Antonov,
[DSL::Bulgarian Raku package](https://github.com/antononcube/Raku-DSL-Bulgarian),
(2022),
[GitHub/antononcube](https://github.com/antononcube).

[AAp1] Anton Antonov,
[Data::Generators Raku package](https://github.com/antononcube/Raku-Data-Generators),
(2021),
[GitHub/antononcube](https://github.com/antononcube).

[AAp2] Anton Antonov,
[Data::Reshapers Raku package](https://github.com/antononcube/Raku-Data-Reshapers),
(2021),
[GitHub/antononcube](https://github.com/antononcube).

[AAp3] Anton Antonov,
[Data::Summarizers Raku package](https://github.com/antononcube/Raku-Data-Summarizers),
(2021),
[GitHub/antononcube](https://github.com/antononcube).

[AAp5] Anton Antonov,
[Text::CodeProcessing Raku package](https://github.com/antononcube/Raku-Text-CodeProcessing),
(2021),
[GitHub/antononcube](https://github.com/antononcube).

[AAp6] Anton Antonov,
[Text::Plot Raku package](https://github.com/antononcube/Raku-Text-Plot),
(2022),
[GitHub/antononcube](https://github.com/antononcube).


### Videos

[AAv1] Anton Antonov,
["Multi-language Data-Wrangling Conversational Agent"](https://www.youtube.com/watch?v=pQk5jwoMSxs),
(2020),
[Wolfram Technology Conference 2020, YouTube/Wolfram](https://www.youtube.com/channel/UCJekgf6k62CQHdENWf2NgAQ).

