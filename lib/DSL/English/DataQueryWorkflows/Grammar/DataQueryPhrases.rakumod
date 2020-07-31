use v6;

use DSL::Shared::Roles::English::CommonParts;
use DSL::Shared::Utilities::FuzzyMatching;

# Data query specific phrases
role DSL::English::DataQueryWorkflows::Grammar::DataQueryPhrases
        does DSL::Shared::Roles::English::CommonParts {
    # Tokens
    token arrange-verb { 'arrange' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'arrange') }> }
    token ascending-adjective { 'ascending' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'ascending') }> }
    token combine-verb { 'combine' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'combine') }> }
    token cross-verb { 'cross' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'cross') }> }
    token descending-adjective { 'descending' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'descending') }> }
    token filter-verb { 'filter' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'filter') }> }
    token format-noun { 'format' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'format') }> }
    token formula-noun { 'formula' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'formula') }> }
    token full-adjective { 'full' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'full') }> }
    token glimpse-verb { 'glimpse' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'glimpse') }> }
    token group-verb { 'group' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'group') }> }
    token join-noun { 'join' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'join') }> }
    token inner-adjective { 'inner' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'inner') }> }
    token left-adjective { 'left' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'left') }> }
    token melt-verb { 'melt' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'melt') }> }
    token mutate-verb { 'mutate' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'mutate') }> }
    token order-verb { 'order' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'order') }> }
    token pivot-verb { 'pivot' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'pivot') }> }
    token rename-verb { 'rename' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'rename') }> }
    token right-adjective { 'right' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'right') }> }
    token select-verb { 'select' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'select') }> }
    token semi-adjective { 'semi' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'semi') }> }
    token sort-verb { 'sort' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'sort') }> }
    token summarise-verb { 'summarise' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'summarise') }> }
    token summarize-verb { 'summarize' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'summarize') }> }
    token tabulate-verb { 'tabulate' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'tabulate') }> }
    token ungroup-verb { 'ungroup' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'ungroup') }> }

    rule for-which-phrase { <for-preposition> <which-determiner> | <that-pronoun> <adhere-verb> <to-preposition> }
    rule cross-tabulate-phrase { <cross-verb> <tabulate-verb> }
    rule contingency-matrix-phrase { <contingency-noun> [ <matrix-noun> | <table-noun> ] }
    rule with-formula-phrase { <with-preposition> <the-determiner>? <formula-noun> }

    # True dplyr; see comments below.
    token ascending { <ascending-adjective> | 'asc' }
    token descending { <descending-adjective> | 'desc' }
    token mutate { <mutate-verb> }
    token order { <order-verb> }

    rule arrange { [ <arrange-verb> | <order-verb> | <sort-verb> ] [ <by-preposition> | <using-preposition> ]? }
    rule data-phrase { <.the-determiner>? <data> }
    rule filter { <filter-verb> | <select-verb> }
    rule group-by { <group-verb> [ <by-preposition> | <using-preposition> ] }
    rule select { <select-verb> | 'keep' 'only'? }
    rule pivot-columns-phrase { <pivot-verb>? <columns> }
    rule rename-directive { <rename-verb> }
    rule to-long-form-phrase { <pivot-verb> 'longer' | <to-preposition> [ 'long' | 'narrow' ] [ 'form' | <format-noun> ] | <melt-verb>  }
    rule variable-column-name-phrase { <variable-noun> <column-noun>? <name-noun> }
    rule value-column-name-phrase { <value-noun> <column-noun>? <name-noun> }
}

