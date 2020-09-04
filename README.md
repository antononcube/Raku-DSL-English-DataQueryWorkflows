# Data Query Workflows 

Possible alternative name: *"Spoken tidyverse commands"*.  

## In brief

This Raku (Perl 6) package has grammar and action classes for the parsing and
interpretation of natural language commands that specify data queries in the style of
Standard Query Language (SQL) or 
[RStudio](https://rstudio.com)'s
library [`tidyverse`](https://tidyverse.tidyverse.org).

It is envisioned that the interpreters (actions) are going to target different
programming languages: Python, SQL, R, WL, or others.

## Installation

**1.** Install Raku (Perl 6) : https://raku.org/downloads . 

**2.** Make sure you have Zef Module Installer. 
 
   - Type in `zef` in the command line.
   - You can install the Zef Module Installer from : https://github.com/ugexe/zef .

**3.** Open a command line program. (E.g. Terminal on Mac OS X.)

**4.** Run the commands:

```
zef install https://github.com/antononcube/Raku-DSL-Shared.git
zef install https://github.com/antononcube/Raku-DSL-English-DataQueryWorkflows.git
```

## Examples

Here is example code:

    use DSL::English::DataQueryWorkflows;

    say ToDataQueryWorkflowCode('select mass & height', 'R-tidyverse');
    
    # dplyr::select(mass, height) 
    
    #------
    
    ToDataQueryWorkflowCode('
      use starwars;
      select mass & height; 
      mutate bmi = mass/height^2; 
      arrange by the variable bmi descending;
    ', 'R-tidyverse');

    # starwars %>%
    # dplyr::select(mass, height) %>%
    # dplyr::mutate(bmi = mass/height^2) %>%
    # dplyr::arrange(desc(bmi))
    
Additional examples can be found in this file: 
[DataQueryWorkflows-examples.raku](./examples/DataQueryWorkflows-examples.raku).

## Testing

There are three types of unit tests:

1. for parsing abilities; see [example](./t/Basic-commands.t)

2. for interpretation to correct expected code; see [example](./t/Basic-commands-R-tidyverse.t)

3. for data transformation correctness; see [example](https://github.com/antononcube/R-packages/tree/master/DataQueryWorkflowsTests)

The unit tests R-package \[AAp2\] can be used to test both R and Python translations and equivalence between them.

A similar WL package can have unit tests for Julia, Python, R, and WL. (*Not implemented yet...*) 

## On naming of translation packages

WL has a `System` context where usually the built-in functions reside. WL adepts know this, but not that much the rest.
(All WL packages provide a context for their functions.)

The thing is that my naming convention for the translation files so far is `<programming language>::<package name>`.
And I do not want to break that invariant.

Knowing the package is not essential when invoking the functions. 
For example `ToDataQueryWorkflowCode[_,"R"]` produces same results as `ToDataQueryWorkflowCode[_,"R-base"]`, etc.

## Versions

The original version of this Raku package was developed/hosted at 
\[ [AAp1](https://github.com/antononcube/ConversationalAgents/tree/master/Packages/Perl6/DataQueryWorkflows) \].

A dedicated GitHub repository was made in order to make the installation with Raku's `zef` more direct. 
(As shown above.)

## References

\[AAp1\] Anton Antonov, 
[Data Query Workflows Raku Package](https://github.com/antononcube/ConversationalAgents/tree/master/Packages/Perl6/DataQueryWorkflows), 
(2020),
[ConversationalAgents at GitHub/antononcube](https://github.com/antononcube/ConversationalAgents).

\[AAp2\] Anton Antonov,
[Data Query Workflows Tests](https://github.com/antononcube/R-packages/tree/master/DataQueryWorkflowsTests),
(2020),
[R-packages at GitHub/antononcube](https://github.com/antononcube/R-packages).