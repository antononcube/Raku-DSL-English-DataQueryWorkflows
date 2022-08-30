# Standard Data Wrangling Commands

## Introduction

This document demonstrates and exemplifies the abilities of the package
["DSL::English::DataQueryWorkflow"](https://raku.land/zef:antononcube/DSL::English::DataQueryWorkflows)
to produce executable code that fits majority of the data wrangling use cases.

------

## Setup

### Load packages

```perl6
use Data::ExampleDatasets;
use Data::Reshapers;
use Data::Summarizers;

use DSL::English::DataQueryWorkflows;
```
```
# (Any)
```

### Load data

*Actual data is not used at this point.*

```perl6
#my @dfTitanic = example-dataset("https://raw.githubusercontent.com/antononcube/MathematicaVsR/master/Data/MathematicaVsR-Data-Titanic.csv");
#my @dfStarwars = example-dataset("https://raw.githubusercontent.com/antononcube/R-packages/master/DataQueryWorkflowsTests/inst/extdata/dfStarwars.csv");
#my @dfStarwarsFilms = example-dataset("https://raw.githubusercontent.com/antononcube/R-packages/master/DataQueryWorkflowsTests/inst/extdata/dfStarwarsFilms.csv");
#my @dfStarwarsStarships = example-dataset("https://raw.githubusercontent.com/antononcube/R-packages/master/DataQueryWorkflowsTests/inst/extdata/dfStarwarsStarships.csv");
#my @dfStarwarsVehicles = example-dataset("https://raw.githubusercontent.com/antononcube/R-packages/master/DataQueryWorkflowsTests/inst/extdata/dfStarwarsVehicles.csv");
#
#(@dfTitanic, @dfStarwars, @dfStarwarsFilms, @dfStarwarsStarships, @dfStarwarsVehicles).map({ dimensions($_) })
```
```
# ()
```

#### Anscombe quartet

See ["Anscombe's quartet"](https://en.wikipedia.org/wiki/Anscombe%27s_quartet).

We can retrieve the Anscombe dataset using `example-dataset` provided by "Data::ExampleDatasets":

```perl6
my @dfAnscombe = |example-dataset('anscombe');
dimensions(@dfAnscombe)
```
```
# (11 8)
```

### Parameters

```perl6
my $examplesTarget = 'Raku';
```
```
# Raku
```

------

## Multi-language

```perl6
my $command0 = 'use dfStarwars; group by species; counts;';
<Python Raku R R::tidyverse WL>.map({ say "\n{$_}:\n", ToDataQueryWorkflowCode($command0, target => $_) });
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

```perl6
<Bulgarian Korean Russian Spanish>.map({ say "\n{$_}:\n", ToDataQueryWorkflowCode($command0, target => $_) });
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

Since there is no expectation to have a dedicated data transformation monad -- in whatever programming language -- 
we can try to make the command sequence parsing to be "aware" of the grouping operations.

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
# +-----------+-----------+----------+----+----+----+----+-----------+
# |     y3    |     y4    |    y2    | x2 | x1 | x4 | x3 |     y1    |
# +-----------+-----------+----------+----+----+----+----+-----------+
# |  7.460000 |  6.580000 | 9.140000 | 10 | 10 | 8  | 10 |  8.040000 |
# |  6.770000 |  5.760000 | 8.140000 | 8  | 8  | 8  | 8  |  6.950000 |
# | 12.740000 |  7.710000 | 8.740000 | 13 | 13 | 8  | 13 |  7.580000 |
# |  7.110000 |  8.840000 | 8.770000 | 9  | 9  | 8  | 9  |  8.810000 |
# |  7.810000 |  8.470000 | 9.260000 | 11 | 11 | 8  | 11 |  8.330000 |
# |  8.840000 |  7.040000 | 8.100000 | 14 | 14 | 8  | 14 |  9.960000 |
# |  6.080000 |  5.250000 | 6.130000 | 6  | 6  | 8  | 6  |  7.240000 |
# |  5.390000 | 12.500000 | 3.100000 | 4  | 4  | 19 | 4  |  4.260000 |
# |  8.150000 |  5.560000 | 9.130000 | 12 | 12 | 8  | 12 | 10.840000 |
# |  6.420000 |  7.910000 | 7.260000 | 7  | 7  | 8  | 7  |  4.820000 |
# |  5.730000 |  6.890000 | 4.740000 | 5  | 5  | 8  | 5  |  5.680000 |
# +-----------+-----------+----------+----+----+----+----+-----------+
```

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

------

## References

### Articles

[AA1] Anton Antonov,
["Introduction to data wrangling with Raku"](https://rakuforprediction.wordpress.com/2021/12/31/introduction-to-data-wrangling-with-raku/),
(2021),
[RakuForPrediction at WordPress](https://rakuforprediction.wordpress.com).

[AA2] Anton Antonov,
["Увод в обработката на данни с Raku"](https://rakuforprediction.wordpress.com/2022/05/24/увод-в-обработката-на-данни-с-raku/),
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

