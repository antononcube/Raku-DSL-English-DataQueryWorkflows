# Data Query Workflows

## Introduction

This Raku (Perl 6) package has grammar and action classes for the parsing and interpretation of natural
Domain Specific Language (DSL) commands that specify data queries in the style of Standard Query Language (SQL) or
[RStudio](https://rstudio.com)'s library [`tidyverse`](https://tidyverse.tidyverse.org).

The interpreters (actions) have as targets different programming languages (and packages in them.)

The currently implemented programming-language-and-package targets are:
Julia::DataFrames, Mathematica, Python::pandas, R::base, R::tidyverse, Raku::Reshapers.

There are also interpreters to natural languages: Bulgarian, English, Korean, Russian, Spanish.

------

## Installation

From GitHub:

```
zef install https://github.com/antononcube/Raku-DSL-English-DataQueryWorkflows.git
```

-------

## Current state

The following diagram:

- Summarizes the data wrangling capabilities envisioned for this package 
- Represents the Raku parsers and interpreters in this package with the hexagon
- Indicates future plans with dashed lines


![](https://raw.githubusercontent.com/antononcube/RakuForPrediction-book/main/Diagrams/DSLs-Interpreter-for-Data-Wrangling-August-2022-state.png)

**Remark:** The grammar of this package is extended to parse Bulgarian DSL commands
with the package 
["DSL::Bulgarian"](https://github.com/antononcube/Raku-DSL-Bulgarian), 
[AAp4].

-------

## Workflows considered

The following flow-chart encompasses the data transformations workflows we consider:

![](https://raw.githubusercontent.com/antononcube/ConversationalAgents/master/ConceptualDiagrams/Tabular-data-transformation-workflows.png)

Here are some properties of the methodology / flow chart:

- The flow chart is for tabular datasets, or for lists (arrays) or dictionaries (hashes) of tabular datasets
- In the flow chart only the data loading and summary analysis are not optional
- All other steps are optional
- Transformations like inner-joins are represented by the block “Combine groups”
- It is assumed that in real applications several iterations (loops) have to be run over the flow chart

In the world of the programming language R the orange blocks represent the so called
Split-Transform-Combine pattern;
see the article "The Split-Apply-Combine Strategy for Data Analysis" by Hadley Wickham, [HW1].

For more data query workflows design details see the article 
["Introduction to data wrangling with Raku"](https://rakuforprediction.wordpress.com/2021/12/31/introduction-to-data-wrangling-with-raku/), 
[AA1] or its translation (and upgrade) in Bulgarian, [AA2].

------

## Examples

Here is example code:

```perl6
use DSL::English::DataQueryWorkflows;

say ToDataQueryWorkflowCode('select mass & height', 'R-tidyverse');
```
```
# dplyr::select(mass, height)
```

Here is a longer data wrangling command:

```perl6
my $command = 'use starwars;
select species, mass & height;
group by species;
arrange by the variables species and mass descending';
```
```
# use starwars;
# select species, mass & height;
# group by species;
# arrange by the variables species and mass descending
```
Here we translate that command into executable code for Julia, Mathematica, Python, R, and Raku:

```perl6
{say $_.key,  ":\n", $_.value, "\n"} for <Julia Mathematica Python R R::tidyverse Raku>.map({ $_ => ToDataQueryWorkflowCode($command, $_ ) });
```
```
# Julia:
# obj = starwars
# obj = obj[ : , [:species, :mass, :height]]
# obj = groupby( obj, [:species] )
# obj = sort( obj, [:species, :mass], rev=true )
# 
# Mathematica:
# obj = starwars
# obj = Map[ KeyTake[ #, {"species", "mass", "height"} ]&, obj]
# obj = GroupBy[ obj, #["species"]& ]
# obj = ReverseSortBy[ #, {#["species"], #["mass"]}& ]& /@ obj
# 
# Python:
# obj = starwars.copy()
# obj = obj[["species", "mass", "height"]]
# obj = obj.groupby(["species"])
# obj = obj.sort_values( ["species", "mass"], ascending = False )
# 
# R:
# obj <- starwars ;
# obj <- obj[, c("species", "mass", "height")] ;
# obj <- split( x = obj, f = "species" ) ;
# obj <- obj[ rev(order(obj[ ,c("species", "mass")])), ]
# 
# R::tidyverse:
# starwars %>%
# dplyr::select(species, mass, height) %>%
# dplyr::group_by(species) %>%
# dplyr::arrange(desc(species, mass))
# 
# Raku:
# $obj = starwars ;
# $obj = select-columns($obj, ("species", "mass", "height") ) ;
# $obj = group-by( $obj, "species") ;
# $obj = $obj>>.sort({ ($_{"species"}, $_{"mass"}) })>>.reverse
```

Here we translate to other human languages:

```perl6
{say $_.key,  ":\n", $_.value, "\n"} for <Bulgarian English Korean Russian Spanish>.map({ $_ => ToDataQueryWorkflowCode($command, $_ ) });
```
```
# Bulgarian:
# използвай таблицата: starwars
# избери колоните: "species", "mass", "height"
# групирай с колоните: species
# сортирай в низходящ ред с колоните: "species", "mass"
# 
# English:
# use the data table: starwars
# select the columns: "species", "mass", "height"
# group by the columns: species
# sort in descending order with the columns: "species", "mass"
# 
# Korean:
# 테이블 사용: starwars
# "species", "mass", "height" 열 선택
# 열로 그룹화: species
# 열과 함께 내림차순으로 정렬: "species", "mass"
# 
# Russian:
# использовать таблицу: starwars
# выбрать столбцы: "species", "mass", "height"
# групировать с колонками: species
# сортировать в порядке убывания по столбцам: "species", "mass"
# 
# Spanish:
# utilizar la tabla: starwars
# escoger columnas: "species", "mass", "height"
# agrupar con columnas: "species"
# ordenar en orden descendente con columnas: "species", "mass"
```

Additional examples can be found in this file:
[DataQueryWorkflows-examples.raku](./examples/DataQueryWorkflows-examples.raku).

-------

## Testing

There are three types of unit tests for:

1. Parsing abilities; see [example](./t/Basic-commands.rakutest)

2. Interpretation into correct expected code; see [example](./t/Basic-commands-R-tidyverse.rakutest)

3. Data transformation correctness;
   see [example](https://github.com/antononcube/R-packages/tree/master/DataQueryWorkflowsTests)

The unit tests R-package [AAp2] can be used to test both R and Python translations and equivalence between them.

There is a similar WL package, [AAp3].
(The WL unit tests package *can* have unit tests for Julia, Python, R -- not implemented yet.)

------

## On naming of translation packages

WL has a `System` context where usually the built-in functions reside. WL adepts know this, but others do not.
(Every WL package provides a context for its functions.)

My naming convention for the translation files so far is `<programming language>::<package name>`. 
And I do not want to break that invariant.

Knowing the package is not essential when invoking the functions. For example `ToDataQueryWorkflowCode[_,"R"]` produces
same results as `ToDataQueryWorkflowCode[_,"R-base"]`, etc.

------

## Versions

The original version of this Raku package was developed/hosted at
[ [AAp1](https://github.com/antononcube/ConversationalAgents/tree/master/Packages/Perl6/DataQueryWorkflows) ].

A dedicated GitHub repository was made in order to make the installation with Raku's `zef` more direct.
(As shown above.)

------

## TODO

- [ ] Implement SQL actions.

- [ ] Implement [Swift::TabularData](https://developer.apple.com/documentation/tabulardata) actions.
  
- [ ] Implement [Raku::Dan](https://github.com/p6steve/raku-Dan) actions.

- [ ] Make sure "round trip" translations work. 

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
[Data Query Workflows Raku Package](https://github.com/antononcube/ConversationalAgents/tree/master/Packages/Perl6/DataQueryWorkflows)
,
(2020),
[ConversationalAgents at GitHub/antononcube](https://github.com/antononcube/ConversationalAgents).

[AAp2] Anton Antonov,
[Data Query Workflows Tests](https://github.com/antononcube/R-packages/tree/master/DataQueryWorkflowsTests),
(2020),
[R-packages at GitHub/antononcube](https://github.com/antononcube/R-packages).

[AAp3] Anton Antonov,
[Data Query Workflows Mathematica Unit Tests](https://github.com/antononcube/ConversationalAgents/blob/master/UnitTests/WL/DataQueryWorkflows-Unit-Tests.wlt),
(2020),
[ConversationalAgents at GitHub/antononcube](https://github.com/antononcube/ConversationalAgents).

[AAp4] Anton Antonov,
[DSL::Bulgarian Raku package](https://github.com/antononcube/Raku-DSL-Bulgarian),
(2022),
[GitHub/antononcube](https://github.com/antononcube).

### Videos

[AAv1] Anton Antonov, 
["Raku for Prediction"](https://conf.raku.org/talk/157), 
(2021), 
[The Raku Conference 2021](https://conf.raku.org/).

[AAv2] Anton Antonov, 
["Multi-language Data-Wrangling Conversational Agent"], 
(2020), 
[Wolfram Technology Conference 2020, YouTube/Wolfram](https://www.youtube.com/channel/UCJekgf6k62CQHdENWf2NgAQ).