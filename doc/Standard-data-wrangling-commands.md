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
#my @dfStarwarsFilms = example-dataset("https://raw.githubusercontent.com/antononcube/R-packages/master/DataQueryWorkflowsTests/inst/extdata/dfStarwarsFilms.csv");
#my @dfStarwarsStarships = example-dataset("https://raw.githubusercontent.com/antononcube/R-packages/master/DataQueryWorkflowsTests/inst/extdata/dfStarwarsStarships.csv");
#my @dfStarwarsVehicles = example-dataset("https://raw.githubusercontent.com/antononcube/R-packages/master/DataQueryWorkflowsTests/inst/extdata/dfStarwarsVehicles.csv");
#
#(@ @dfStarwars, @dfStarwarsFilms, @dfStarwarsStarships, @dfStarwarsVehicles).map({ dimensions($_) })
```
```
# [{birth_year => 19, eye_color => blue, gender => masculine, hair_color => blond, height => 172, homeworld => Tatooine, mass => 77, name => Luke Skywalker, sex => male, skin_color => fair, species => Human} {birth_year => 112, eye_color => yellow, gender => masculine, hair_color => (Any), height => 167, homeworld => Tatooine, mass => 75, name => C-3PO, sex => none, skin_color => gold, species => Droid} {birth_year => 33, eye_color => red, gender => masculine, hair_color => (Any), height => 96, homeworld => Naboo, mass => 32, name => R2-D2, sex => none, skin_color => white, blue, species => Droid} {birth_year => 41.9, eye_color => yellow, gender => masculine, hair_color => none, height => 202, homeworld => Tatooine, mass => 136, name => Darth Vader, sex => male, skin_color => white, species => Human} {birth_year => 19, eye_color => brown, gender => feminine, hair_color => brown, height => 150, homeworld => Alderaan, mass => 49, name => Leia Organa, sex => female, skin_color => light, species => Human} {birth_year => 52, eye_color => blue, gender => masculine, hair_color => brown, grey, height => 178, homeworld => Tatooine, mass => 120, name => Owen Lars, sex => male, skin_color => light, species => Human} {birth_year => 47, eye_color => blue, gender => feminine, hair_color => brown, height => 165, homeworld => Tatooine, mass => 75, name => Beru Whitesun lars, sex => female, skin_color => light, species => Human} {birth_year => (Any), eye_color => red, gender => masculine, hair_color => (Any), height => 97, homeworld => Tatooine, mass => 32, name => R5-D4, sex => none, skin_color => white, red, species => Droid} {birth_year => 24, eye_color => brown, gender => masculine, hair_color => black, height => 183, homeworld => Tatooine, mass => 84, name => Biggs Darklighter, sex => male, skin_color => light, species => Human} {birth_year => 57, eye_color => blue-gray, gender => masculine, hair_color => auburn, white, height => 182, homeworld => Stewjon, mass => 77, name => Obi-Wan Kenobi, sex => male, skin_color => fair, species => Human} {birth_year => 41.9, eye_color => blue, gender => masculine, hair_color => blond, height => 188, homeworld => Tatooine, mass => 84, name => Anakin Skywalker, sex => male, skin_color => fair, species => Human} {birth_year => 64, eye_color => blue, gender => masculine, hair_color => auburn, grey, height => 180, homeworld => Eriadu, mass => (Any), name => Wilhuff Tarkin, sex => male, skin_color => fair, species => Human} {birth_year => 200, eye_color => blue, gender => masculine, hair_color => brown, height => 228, homeworld => Kashyyyk, mass => 112, name => Chewbacca, sex => male, skin_color => unknown, species => Wookiee} {birth_year => 29, eye_color => brown, gender => masculine, hair_color => brown, height => 180, homeworld => Corellia, mass => 80, name => Han Solo, sex => male, skin_color => fair, species => Human} {birth_year => 44, eye_color => black, gender => masculine, hair_color => (Any), height => 173, homeworld => Rodia, mass => 74, name => Greedo, sex => male, skin_color => green, species => Rodian} {birth_year => 600, eye_color => orange, gender => masculine, hair_color => (Any), height => 175, homeworld => Nal Hutta, mass => 1358, name => Jabba Desilijic Tiure, sex => hermaphroditic, skin_color => green-tan, brown, species => Hutt} {birth_year => 21, eye_color => hazel, gender => masculine, hair_color => brown, height => 170, homeworld => Corellia, mass => 77, name => Wedge Antilles, sex => male, skin_color => fair, species => Human} {birth_year => (Any), eye_color => blue, gender => masculine, hair_color => brown, height => 180, homeworld => Bestine IV, mass => 110, name => Jek Tono Porkins, sex => male, skin_color => fair, species => Human} {birth_year => 896, eye_color => brown, gender => masculine, hair_color => white, height => 66, homeworld => (Any), mass => 17, name => Yoda, sex => male, skin_color => green, species => Yoda's species} {birth_year => 82, eye_color => yellow, gender => masculine, hair_color => grey, height => 170, homeworld => Naboo, mass => 75, name => Palpatine, sex => male, skin_color => pale, species => Human} {birth_year => 31.5, eye_color => brown, gender => masculine, hair_color => black, height => 183, homeworld => Kamino, mass => 78.2, name => Boba Fett, sex => male, skin_color => fair, species => Human} {birth_year => 15, eye_color => red, gender => masculine, hair_color => none, height => 200, homeworld => (Any), mass => 140, name => IG-88, sex => none, skin_color => metal, species => Droid} {birth_year => 53, eye_color => red, gender => masculine, hair_color => none, height => 190, homeworld => Trandosha, mass => 113, name => Bossk, sex => male, skin_color => green, species => Trandoshan} {birth_year => 31, eye_color => brown, gender => masculine, hair_color => black, height => 177, homeworld => Socorro, mass => 79, name => Lando Calrissian, sex => male, skin_color => dark, species => Human} {birth_year => 37, eye_color => blue, gender => masculine, hair_color => none, height => 175, homeworld => Bespin, mass => 79, name => Lobot, sex => male, skin_color => light, species => Human} {birth_year => 41, eye_color => orange, gender => masculine, hair_color => none, height => 180, homeworld => Mon Cala, mass => 83, name => Ackbar, sex => male, skin_color => brown mottle, species => Mon Calamari} {birth_year => 48, eye_color => blue, gender => feminine, hair_color => auburn, height => 150, homeworld => Chandrila, mass => (Any), name => Mon Mothma, sex => female, skin_color => fair, species => Human} {birth_year => (Any), eye_color => brown, gender => masculine, hair_color => brown, height => (Any), homeworld => (Any), mass => (Any), name => Arvel Crynyd, sex => male, skin_color => fair, species => Human} {birth_year => 8, eye_color => brown, gender => masculine, hair_color => brown, height => 88, homeworld => Endor, mass => 20, name => Wicket Systri Warrick, sex => male, skin_color => brown, species => Ewok} {birth_year => (Any), eye_color => black, gender => masculine, hair_color => none, height => 160, homeworld => Sullust, mass => 68, name => Nien Nunb, sex => male, skin_color => grey, species => Sullustan} {birth_year => 92, eye_color => blue, gender => masculine, hair_color => brown, height => 193, homeworld => (Any), mass => 89, name => Qui-Gon Jinn, sex => male, skin_color => fair, species => Human} {birth_year => (Any), eye_color => red, gender => masculine, hair_color => none, height => 191, homeworld => Cato Neimoidia, mass => 90, name => Nute Gunray, sex => male, skin_color => mottled green, species => Neimodian} {birth_year => 91, eye_color => blue, gender => masculine, hair_color => blond, height => 170, homeworld => Coruscant, mass => (Any), name => Finis Valorum, sex => male, skin_color => fair, species => Human} {birth_year => 52, eye_color => orange, gender => masculine, hair_color => none, height => 196, homeworld => Naboo, mass => 66, name => Jar Jar Binks, sex => male, skin_color => orange, species => Gungan} {birth_year => (Any), eye_color => orange, gender => masculine, hair_color => none, height => 224, homeworld => Naboo, mass => 82, name => Roos Tarpals, sex => male, skin_color => grey, species => Gungan} {birth_year => (Any), eye_color => orange, gender => masculine, hair_color => none, height => 206, homeworld => Naboo, mass => (Any), name => Rugor Nass, sex => male, skin_color => green, species => Gungan} {birth_year => (Any), eye_color => blue, gender => (Any), hair_color => brown, height => 183, homeworld => Naboo, mass => (Any), name => Ric Olié, sex => (Any), skin_color => fair, species => (Any)} {birth_year => (Any), eye_color => yellow, gender => masculine, hair_color => black, height => 137, homeworld => Toydaria, mass => (Any), name => Watto, sex => male, skin_color => blue, grey, species => Toydarian} {birth_year => (Any), eye_color => orange, gender => masculine, hair_color => none, height => 112, homeworld => Malastare, mass => 40, name => Sebulba, sex => male, skin_color => grey, red, species => Dug} {birth_year => 62, eye_color => brown, gender => (Any), hair_color => black, height => 183, homeworld => Naboo, mass => (Any), name => Quarsh Panaka, sex => (Any), skin_color => dark, species => (Any)} {birth_year => 72, eye_color => brown, gender => feminine, hair_color => black, height => 163, homeworld => Tatooine, mass => (Any), name => Shmi Skywalker, sex => female, skin_color => fair, species => Human} {birth_year => 54, eye_color => yellow, gender => masculine, hair_color => none, height => 175, homeworld => Dathomir, mass => 80, name => Darth Maul, sex => male, skin_color => red, species => Zabrak} {birth_year => (Any), eye_color => pink, gender => masculine, hair_color => none, height => 180, homeworld => Ryloth, mass => (Any), name => Bib Fortuna, sex => male, skin_color => pale, species => Twi'lek} {birth_year => 48, eye_color => hazel, gender => feminine, hair_color => none, height => 178, homeworld => Ryloth, mass => 55, name => Ayla Secura, sex => female, skin_color => blue, species => Twi'lek} {birth_year => (Any), eye_color => yellow, gender => masculine, hair_color => none, height => 94, homeworld => Vulpter, mass => 45, name => Dud Bolt, sex => male, skin_color => blue, grey, species => Vulptereen} {birth_year => (Any), eye_color => black, gender => masculine, hair_color => none, height => 122, homeworld => Troiken, mass => (Any), name => Gasgano, sex => male, skin_color => white, blue, species => Xexto} {birth_year => (Any), eye_color => orange, gender => masculine, hair_color => none, height => 163, homeworld => Tund, mass => 65, name => Ben Quadinaros, sex => male, skin_color => grey, green, yellow, species => Toong} {birth_year => 72, eye_color => brown, gender => masculine, hair_color => none, height => 188, homeworld => Haruun Kal, mass => 84, name => Mace Windu, sex => male, skin_color => dark, species => Human} {birth_year => 92, eye_color => yellow, gender => masculine, hair_color => white, height => 198, homeworld => Cerea, mass => 82, name => Ki-Adi-Mundi, sex => male, skin_color => pale, species => Cerean} {birth_year => (Any), eye_color => black, gender => masculine, hair_color => none, height => 196, homeworld => Glee Anselm, mass => 87, name => Kit Fisto, sex => male, skin_color => green, species => Nautolan} {birth_year => (Any), eye_color => brown, gender => masculine, hair_color => black, height => 171, homeworld => Iridonia, mass => (Any), name => Eeth Koth, sex => male, skin_color => brown, species => Zabrak} {birth_year => (Any), eye_color => blue, gender => feminine, hair_color => none, height => 184, homeworld => Coruscant, mass => 50, name => Adi Gallia, sex => female, skin_color => dark, species => Tholothian} {birth_year => (Any), eye_color => orange, gender => masculine, hair_color => none, height => 188, homeworld => Iktotch, mass => (Any), name => Saesee Tiin, sex => male, skin_color => pale, species => Iktotchi} {birth_year => (Any), eye_color => yellow, gender => masculine, hair_color => none, height => 264, homeworld => Quermia, mass => (Any), name => Yarael Poof, sex => male, skin_color => white, species => Quermian} {birth_year => 22, eye_color => black, gender => masculine, hair_color => none, height => 188, homeworld => Dorin, mass => 80, name => Plo Koon, sex => male, skin_color => orange, species => Kel Dor} {birth_year => (Any), eye_color => blue, gender => masculine, hair_color => none, height => 196, homeworld => Champala, mass => (Any), name => Mas Amedda, sex => male, skin_color => blue, species => Chagrian} {birth_year => (Any), eye_color => brown, gender => masculine, hair_color => black, height => 185, homeworld => Naboo, mass => 85, name => Gregar Typho, sex => male, skin_color => dark, species => Human} {birth_year => (Any), eye_color => brown, gender => feminine, hair_color => brown, height => 157, homeworld => Naboo, mass => (Any), name => Cordé, sex => female, skin_color => light, species => Human} {birth_year => 82, eye_color => blue, gender => masculine, hair_color => brown, height => 183, homeworld => Tatooine, mass => (Any), name => Cliegg Lars, sex => male, skin_color => fair, species => Human} {birth_year => (Any), eye_color => yellow, gender => masculine, hair_color => none, height => 183, homeworld => Geonosis, mass => 80, name => Poggle the Lesser, sex => male, skin_color => green, species => Geonosian} {birth_year => 58, eye_color => blue, gender => feminine, hair_color => black, height => 170, homeworld => Mirial, mass => 56.2, name => Luminara Unduli, sex => female, skin_color => yellow, species => Mirialan} {birth_year => 40, eye_color => blue, gender => feminine, hair_color => black, height => 166, homeworld => Mirial, mass => 50, name => Barriss Offee, sex => female, skin_color => yellow, species => Mirialan} {birth_year => (Any), eye_color => brown, gender => feminine, hair_color => brown, height => 165, homeworld => Naboo, mass => (Any), name => Dormé, sex => female, skin_color => light, species => Human} {birth_year => 102, eye_color => brown, gender => masculine, hair_color => white, height => 193, homeworld => Serenno, mass => 80, name => Dooku, sex => male, skin_color => fair, species => Human} {birth_year => 67, eye_color => brown, gender => masculine, hair_color => black, height => 191, homeworld => Alderaan, mass => (Any), name => Bail Prestor Organa, sex => male, skin_color => tan, species => Human} {birth_year => 66, eye_color => brown, gender => masculine, hair_color => black, height => 183, homeworld => Concord Dawn, mass => 79, name => Jango Fett, sex => male, skin_color => tan, species => Human} {birth_year => (Any), eye_color => yellow, gender => feminine, hair_color => blonde, height => 168, homeworld => Zolan, mass => 55, name => Zam Wesell, sex => female, skin_color => fair, green, yellow, species => Clawdite} {birth_year => (Any), eye_color => yellow, gender => masculine, hair_color => none, height => 198, homeworld => Ojom, mass => 102, name => Dexter Jettster, sex => male, skin_color => brown, species => Besalisk} {birth_year => (Any), eye_color => black, gender => masculine, hair_color => none, height => 229, homeworld => Kamino, mass => 88, name => Lama Su, sex => male, skin_color => grey, species => Kaminoan} {birth_year => (Any), eye_color => black, gender => feminine, hair_color => none, height => 213, homeworld => Kamino, mass => (Any), name => Taun We, sex => female, skin_color => grey, species => Kaminoan} {birth_year => (Any), eye_color => blue, gender => feminine, hair_color => white, height => 167, homeworld => Coruscant, mass => (Any), name => Jocasta Nu, sex => female, skin_color => fair, species => Human} {birth_year => (Any), eye_color => unknown, gender => masculine, hair_color => none, height => 79, homeworld => Aleen Minor, mass => 15, name => Ratts Tyerell, sex => male, skin_color => grey, blue, species => Aleena} {birth_year => (Any), eye_color => red, blue, gender => feminine, hair_color => none, height => 96, homeworld => (Any), mass => (Any), name => R4-P17, sex => none, skin_color => silver, red, species => Droid} {birth_year => (Any), eye_color => unknown, gender => masculine, hair_color => none, height => 193, homeworld => Skako, mass => 48, name => Wat Tambor, sex => male, skin_color => green, grey, species => Skakoan} {birth_year => (Any), eye_color => gold, gender => masculine, hair_color => none, height => 191, homeworld => Muunilinst, mass => (Any), name => San Hill, sex => male, skin_color => grey, species => Muun} {birth_year => (Any), eye_color => black, gender => feminine, hair_color => none, height => 178, homeworld => Shili, mass => 57, name => Shaak Ti, sex => female, skin_color => red, blue, white, species => Togruta} {birth_year => (Any), eye_color => green, yellow, gender => masculine, hair_color => none, height => 216, homeworld => Kalee, mass => 159, name => Grievous, sex => male, skin_color => brown, white, species => Kaleesh} {birth_year => (Any), eye_color => blue, gender => masculine, hair_color => brown, height => 234, homeworld => Kashyyyk, mass => 136, name => Tarfful, sex => male, skin_color => brown, species => Wookiee} {birth_year => (Any), eye_color => brown, gender => masculine, hair_color => brown, height => 188, homeworld => Alderaan, mass => 79, name => Raymus Antilles, sex => male, skin_color => light, species => Human} {birth_year => (Any), eye_color => white, gender => (Any), hair_color => none, height => 178, homeworld => Umbara, mass => 48, name => Sly Moore, sex => (Any), skin_color => pale, species => (Any)} {birth_year => (Any), eye_color => black, gender => masculine, hair_color => none, height => 206, homeworld => Utapau, mass => 80, name => Tion Medon, sex => male, skin_color => grey, species => Pau'an} {birth_year => (Any), eye_color => dark, gender => masculine, hair_color => black, height => (Any), homeworld => (Any), mass => (Any), name => Finn, sex => male, skin_color => dark, species => Human} {birth_year => (Any), eye_color => hazel, gender => feminine, hair_color => brown, height => (Any), homeworld => (Any), mass => (Any), name => Rey, sex => female, skin_color => light, species => Human} {birth_year => (Any), eye_color => brown, gender => masculine, hair_color => brown, height => (Any), homeworld => (Any), mass => (Any), name => Poe Dameron, sex => male, skin_color => light, species => Human} {birth_year => (Any), eye_color => black, gender => masculine, hair_color => none, height => (Any), homeworld => (Any), mass => (Any), name => BB8, sex => none, skin_color => none, species => Droid} {birth_year => (Any), eye_color => unknown, gender => (Any), hair_color => unknown, height => (Any), homeworld => (Any), mass => (Any), name => Captain Phasma, sex => (Any), skin_color => unknown, species => (Any)} {birth_year => 46, eye_color => brown, gender => feminine, hair_color => brown, height => 165, homeworld => Naboo, mass => 45, name => Padmé Amidala, sex => female, skin_color => light, species => Human}]
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

# Using DSL cells

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
#   "DSLFUNCTION": "proto sub ToDataQueryWorkflowCode (Str $command, |) {*}",
#   "DSL": "DSL::English::DataQueryWorkflows",
#   "CODE": "obj = dfStarwars.copy()\nobj = obj.merge( dfStarwarsFilms, on = [\"name\"], how = \"inner\" )\nobj = obj.groupby([\"species\"])\nobj = obj.size()",
#   "DSLTARGET": "Python::pandas",
#   "COMMAND": "DSL TARGET Python::pandas;\ninclude setup code;\nuse dfStarwars;\njoin with dfStarwarsFilms by \"name\"; \ngroup by species; \ncounts;\n",
#   "USERID": "",
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
# +---------------------+----------------------+----------------------+---------------+----------------+-----------------+-----------------+---------------+----------------------+--------------------+---------------+
# | mass                | height               | name                 | eye_color     | species        | gender          | homeworld       | skin_color    | sex                  | birth_year         | hair_color    |
# +---------------------+----------------------+----------------------+---------------+----------------+-----------------+-----------------+---------------+----------------------+--------------------+---------------+
# | Min    => 0         | Min    => 0          | Luke Skywalker => 1  | brown   => 21 | Human    => 35 | masculine => 66 | Naboo     => 11 | fair    => 17 | male           => 60 | Min    => 0        | none    => 37 |
# | 1st-Qu => 0         | 1st-Qu => 163        | Mas Amedda     => 1  | blue    => 19 | Droid    => 6  | feminine  => 17 | Tatooine  => 10 | light   => 11 | female         => 16 | 1st-Qu => 0        | brown   => 18 |
# | Mean   => 65.993103 | Mean   => 162.333333 | Mon Mothma     => 1  | yellow  => 11 | 0        => 4  | 0         => 4  | 0         => 10 | green   => 6  | none           => 6  | Mean   => 43.27931 | black   => 13 |
# | Median => 56.2      | Median => 178        | Obi-Wan Kenobi => 1  | black   => 10 | Gungan   => 3  |                 | Kamino    => 3  | grey    => 6  | 0              => 4  | Median => 0        | 0       => 5  |
# | 3rd-Qu => 80        | 3rd-Qu => 191        | Cliegg Lars    => 1  | orange  => 8  | Twi'lek  => 2  |                 | Alderaan  => 3  | dark    => 6  | hermaphroditic => 1  | 3rd-Qu => 52       | white   => 4  |
# | Max    => 1358      | Max    => 264        | Sly Moore      => 1  | red     => 5  | Kaminoan => 2  |                 | Coruscant => 3  | pale    => 5  |                      | Max    => 896      | blond   => 3  |
# |                     |                      | Rey            => 1  | unknown => 3  | Zabrak   => 2  |                 | Mirial    => 2  | brown   => 4  |                      |                    | unknown => 1  |
# |                     |                      | (Other)        => 80 | (Other) => 10 | (Other)  => 33 |                 | (Other)   => 45 | (Other) => 32 |                      |                    | (Other) => 6  |
# +---------------------+----------------------+----------------------+---------------+----------------+-----------------+-----------------+---------------+----------------------+--------------------+---------------+
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
# +--------+--------+------+------------+-----------+------------+----------------+------------+--------------+-----------+-----------+
# | height |  sex   | mass | skin_color | eye_color |  species   |      name      | birth_year |  hair_color  | homeworld |   gender  |
# +--------+--------+------+------------+-----------+------------+----------------+------------+--------------+-----------+-----------+
# |  183   |   0    |  0   |    dark    |   brown   |     0      | Quarsh Panaka  |     62     |    black     |   Naboo   |     0     |
# |  190   |  male  | 113  |   green    |    red    | Trandoshan |     Bossk      |     53     |     none     | Trandosha | masculine |
# |  184   | female |  50  |    dark    |    blue   | Tholothian |   Adi Gallia   |     0      |     none     | Coruscant |  feminine |
# |  206   |  male  |  80  |    grey    |   black   |   Pau'an   |   Tion Medon   |     0      |     none     |   Utapau  | masculine |
# |   97   |  none  |  32  | white, red |    red    |   Droid    |     R5-D4      |     0      |      0       |  Tatooine | masculine |
# |  196   |  male  |  0   |    blue    |    blue   |  Chagrian  |   Mas Amedda   |     0      |     none     |  Champala | masculine |
# |  180   |  male  |  0   |    fair    |    blue   |   Human    | Wilhuff Tarkin |     64     | auburn, grey |   Eriadu  | masculine |
# +--------+--------+------+------------+-----------+------------+----------------+------------+--------------+-----------+-----------+
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
# +-----------+---------------+-----------+-------------+-------------+
# |           | height.median | mass.mean | height.mean | mass.median |
# +-----------+---------------+-----------+-------------+-------------+
# | Bespin    |   175.000000  | 79.000000 |  175.000000 |  79.000000  |
# | Coruscant |   170.000000  | 16.666667 |  173.666667 |   0.000000  |
# | Endor     |   88.000000   | 20.000000 |  88.000000  |  20.000000  |
# | Kamino    |   213.000000  | 55.400000 |  208.333333 |  78.200000  |
# | Mon Cala  |   180.000000  | 83.000000 |  180.000000 |  83.000000  |
# | Shili     |   178.000000  | 57.000000 |  178.000000 |  57.000000  |
# | Utapau    |   206.000000  | 80.000000 |  206.000000 |  80.000000  |
# +-----------+---------------+-----------+-------------+-------------+
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
# +----------------+--------------+--------------+-------------------+------+
# | passengerClass | passengerSex | passengerAge | passengerSurvival |  id  |
# +----------------+--------------+--------------+-------------------+------+
# |      3rd       |     male     |      20      |        died       | 788  |
# |      1st       |     male     |      40      |        died       | 127  |
# |      3rd       |     male     |      -1      |      survived     | 1004 |
# |      3rd       |     male     |      30      |        died       | 1052 |
# |      1st       |    female    |      -1      |      survived     | 109  |
# |      3rd       |    female    |      -1      |      survived     | 1072 |
# |      1st       |    female    |      50      |      survived     | 248  |
# +----------------+--------------+--------------+-------------------+------+
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
# +----+-----------+----+-----------+----+----+-----------+----------+
# | x3 |     y3    | x1 |     y1    | x4 | x2 |     y4    |    y2    |
# +----+-----------+----+-----------+----+----+-----------+----------+
# | 10 |  7.460000 | 10 |  8.040000 | 8  | 10 |  6.580000 | 9.140000 |
# | 8  |  6.770000 | 8  |  6.950000 | 8  | 8  |  5.760000 | 8.140000 |
# | 13 | 12.740000 | 13 |  7.580000 | 8  | 13 |  7.710000 | 8.740000 |
# | 9  |  7.110000 | 9  |  8.810000 | 8  | 9  |  8.840000 | 8.770000 |
# | 11 |  7.810000 | 11 |  8.330000 | 8  | 11 |  8.470000 | 9.260000 |
# | 14 |  8.840000 | 14 |  9.960000 | 8  | 14 |  7.040000 | 8.100000 |
# | 6  |  6.080000 | 6  |  7.240000 | 8  | 6  |  5.250000 | 6.130000 |
# | 4  |  5.390000 | 4  |  4.260000 | 19 | 4  | 12.500000 | 3.100000 |
# | 12 |  8.150000 | 12 | 10.840000 | 8  | 12 |  5.560000 | 9.130000 |
# | 7  |  6.420000 | 7  |  4.820000 | 8  | 7  |  7.910000 | 7.260000 |
# | 5  |  5.730000 | 5  |  5.680000 | 8  | 5  |  6.890000 | 4.740000 |
# +----+-----------+----+-----------+----+----+-----------+----------+
```

Summarize Anscombe's quartet (using "Data::Summarizers", [AAp3]):

```perl6
records-summary($obj);
```
```
# +--------------------+--------------+--------------+--------------------+--------------+-----------------+--------------------+--------------+
# | y4                 | x3           | x2           | y2                 | x1           | y3              | y1                 | x4           |
# +--------------------+--------------+--------------+--------------------+--------------+-----------------+--------------------+--------------+
# | Min    => 5.25     | Min    => 4  | Min    => 4  | Min    => 3.1      | Min    => 4  | Min    => 5.39  | Min    => 4.26     | Min    => 8  |
# | 1st-Qu => 5.76     | 1st-Qu => 6  | 1st-Qu => 6  | 1st-Qu => 6.13     | 1st-Qu => 6  | 1st-Qu => 6.08  | 1st-Qu => 5.68     | 1st-Qu => 8  |
# | Mean   => 7.500909 | Mean   => 9  | Mean   => 9  | Mean   => 7.500909 | Mean   => 9  | Mean   => 7.5   | Mean   => 7.500909 | Mean   => 9  |
# | Median => 7.04     | Median => 9  | Median => 9  | Median => 8.14     | Median => 9  | Median => 7.11  | Median => 7.58     | Median => 8  |
# | 3rd-Qu => 8.47     | 3rd-Qu => 12 | 3rd-Qu => 12 | 3rd-Qu => 9.13     | 3rd-Qu => 12 | 3rd-Qu => 8.15  | 3rd-Qu => 8.81     | 3rd-Qu => 8  |
# | Max    => 12.5     | Max    => 14 | Max    => 14 | Max    => 9.26     | Max    => 14 | Max    => 12.74 | Max    => 10.84    | Max    => 19 |
# +--------------------+--------------+--------------+--------------------+--------------+-----------------+--------------------+--------------+
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
# +----------+----------+--------------+
# | Variable |  Value   | AutomaticKey |
# +----------+----------+--------------+
# |    x1    |    10    |      0       |
# |    x2    |    10    |      0       |
# |    x4    |    8     |      0       |
# |    y4    | 6.580000 |      0       |
# |    y1    | 8.040000 |      0       |
# |    y3    | 7.460000 |      0       |
# |    x3    |    10    |      0       |
# +----------+----------+--------------+
```

Separate the data column "Variable" into the columns "Variable" and "Set":

```perl6
$obj = separate-column( $obj, "Variable", ("Variable", "Set"), sep => "" ) ;
to-pretty-table($obj.head(7))
```
```
# +----------+----------+-----+--------------+
# | Variable |  Value   | Set | AutomaticKey |
# +----------+----------+-----+--------------+
# |    x     |    10    |  1  |      0       |
# |    x     |    10    |  2  |      0       |
# |    x     |    8     |  4  |      0       |
# |    y     | 6.580000 |  4  |      0       |
# |    y     | 8.040000 |  1  |      0       |
# |    y     | 7.460000 |  3  |      0       |
# |    x     |    10    |  3  |      0       |
# +----------+----------+-----+--------------+
```

Reshape the "pipeline object" into
[wide format](https://en.wikipedia.org/wiki/Wide_and_narrow_data)
using appropriate identifier-, variable-, and value column names:

```perl6
$obj = to-wide-format( $obj, identifierColumns => ("Set", "AutomaticKey"), variablesFrom => "Variable", valuesFrom => "Value" );
to-pretty-table($obj.head(7))
```
```
# +------+----+-----+--------------+
# |  y   | x  | Set | AutomaticKey |
# +------+----+-----+--------------+
# | 8.04 | 10 |  1  |      0       |
# | 6.95 | 8  |  1  |      1       |
# | 7.58 | 13 |  1  |      2       |
# | 8.81 | 9  |  1  |      3       |
# | 8.33 | 11 |  1  |      4       |
# | 9.96 | 14 |  1  |      5       |
# | 7.24 | 6  |  1  |      6       |
# +------+----+-----+--------------+
```

Plot each dataset of Anscombe's quartet (using "Text::Plot", [AAp6]):

```perl6
group-by($obj, 'Set').map({ say "\n", text-list-plot( $_.value.map({ +$_<x> }).List, $_.value.map({ +$_<y> }).List, title => 'Set : ' ~ $_.key) })
```
```
# Set : 2                           
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

