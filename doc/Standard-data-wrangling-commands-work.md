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

#### Anscombe quartet

See ["Anscombe's quartet"](https://en.wikipedia.org/wiki/Anscombe%27s_quartet).

We can retrieve the Anscombe dataset using `example-dataset` provided by "Data::ExampleDatasets":

```perl6
my @dfAnscombe = |example-dataset('anscombe');
dimensions(@dfAnscombe)
```

### Parameters

```perl6
my $examplesTarget = 'Raku';
```

------

## Multi-language

```perl6
my $command0 = 'use dfStarwars; group by species; counts;';
<Python Raku R R::tidyverse WL>.map({ say "\n{$_}:\n", ToDataQueryWorkflowCode($command0, target => $_) });
```

```perl6
<Bulgarian Korean Russian Spanish>.map({ say "\n{$_}:\n", ToDataQueryWorkflowCode($command0, target => $_) });
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

------

## Joins

```perl6
my $command2 = "use dfStarwarsFilms;
left join with dfStarwars by 'name';
sort by name, film desc;
echo data summary;
take pipeline value";

ToDataQueryWorkflowCode($command2, target => $examplesTarget)
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

------

### Complicated workflows

```perl6
to-pretty-table(@dfAnscombe)
```

```perl6
my $command6 =
        'use dfAnscombe;
convert to long form;
separate the data column Variable into Variable and Set with separator pattern "";
to wide form for id columns Set and AutomaticKey variable column Variable and value column Value';

ToDataQueryWorkflowCode($command6, target => $examplesTarget)
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

