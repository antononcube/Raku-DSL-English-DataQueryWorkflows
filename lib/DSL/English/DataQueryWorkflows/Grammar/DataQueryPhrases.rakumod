use v6;

use DSL::Shared::Roles::English::PipelineCommand;
use DSL::Shared::Utilities::FuzzyMatching;

# Data query specific phrases
role DSL::English::DataQueryWorkflows::Grammar::DataQueryPhrases
        does DSL::Shared::Roles::English::PipelineCommand {
    # Tokens
    token arrange-verb { 'arrange' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'arrange') }> }
    token ascending-adjective { 'ascending' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'ascending') }> }
    token association-noun { 'association' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'association') }> }
    token broad-adjective { 'broad' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'broad') }> }
    token cases-noun { 'cases' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'cases') }> }
    token cast-verb { 'cast' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'cast') }> }
    token character-noun { 'character' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'character') }> }
    token combine-verb { 'combine' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'combine') }> }
    token complete-adjective { 'complete' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'complete') }> }
    token cross-verb { 'cross' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'cross') }> }
    token descending-adjective { 'descending' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'descending') }> }
    token dictionary-noun { 'dictionary' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'dictionary') }> }
    token distinct-adjective { 'distinct' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'distinct') }> }
    token divider-noun { 'divider' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'divider') }> }
    token duplicate-adjective { 'duplicate' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'duplicate') }> }
    token duplicates-noun { 'duplicates' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'duplicates') }> }
    token filter-verb { 'filter' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'filter') }> }
    token form-noun { 'form' | ([\w]+) <?{ $0.Str ne 'format' and is-fuzzy-match( $0.Str, 'form') }> }
    token format-noun { 'format' | ([\w]+) <?{ $0.Str ne 'form' and is-fuzzy-match( $0.Str, 'format') }> }
    token formula-noun { 'formula' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'formula') }> }
    token full-adjective { 'full' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'full') }> }
    token glimpse-verb { 'glimpse' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'glimpse') }> }
    token group-verb { 'group' | ([\w]+) <?{ $0.Str ne 'ungroup' and is-fuzzy-match( $0.Str, 'group') }> }
    token inner-adjective { 'inner' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'inner') }> }
    token join-noun { 'join' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'join') }> }
    token keep-verb { 'keep' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'keep') }> }
    token left-adjective { 'left' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'left') }> }
    token long-adjective { 'long' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'long') }> }
    token longer-adjective { 'longer' | ([\w]+) <?{ $0.Str ne 'long' and is-fuzzy-match( $0.Str, 'longer') }> }
    token map-verb { 'map' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'map') }> }
    token mapping-noun { 'mapping' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'mapping') }> }
    token melt-verb { 'melt' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'melt') }> }
    token mutate-verb { 'mutate' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'mutate') }> }
    token narrow-adjective { 'narrow' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'narrow') }> }
    token omit-directive { 'omit' | 'exclude' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'exclude') }> }
    token only-adverb { 'only' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'only') }> }
    token order-verb { 'order' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'order') }> }
    token pivot-verb { 'pivot' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'pivot') }> }
    token rename-verb { 'rename' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'rename') }> }
    token replace-verb { 'replace' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'replace') }> }
    token right-adjective { 'right' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'right') }> }
    token safe-adjective { 'safe' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'safe') }> }
    token safely-adverb { 'safely' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'safely') }> }
    token select-verb { 'select' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'select') }> }
    token semi-adjective { 'semi' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'semi') }> }
    token separator-noun { 'separator' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'separator') }> }
    token sort-verb { 'sort' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'sort') }> }
    token splitter-noun { 'splitter' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'splitter') }> }
    token splitting-noun { 'splitting' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'splitting') }> }
    token summarise-verb { 'summarise' | ([\w]+) <?{ $0.Str ne 'summarize' and is-fuzzy-match( $0.Str, 'summarise') }>}
    token summarize-verb { 'summarize' | ([\w]+) <?{ $0.Str ne 'summarise' and is-fuzzy-match( $0.Str, 'summarize') }> }
    token tabulate-verb { 'tabulate' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'tabulate') }> }
    token ungroup-verb { 'ungroup' | ([\w]+) <?{ $0.Str ne 'group' and is-fuzzy-match( $0.Str, 'ungroup') }> }
    token unique-adjective { 'unique' | ([\w]+) <?{ is-fuzzy-match( $0.Str, 'unique') }> }
    token wide-adjective { 'wide' | ([\w]+) <?{ $0.Str ne 'wider' and is-fuzzy-match( $0.Str, 'wide') }> }
    token wider-adjective { 'wider' | ([\w]+) <?{ $0.Str ne 'wide' and is-fuzzy-match( $0.Str, 'wider') }> }

    rule for-which-phrase { <for-preposition> <which-determiner> | <that-pronoun> <adhere-verb> <to-preposition> }
    rule complete-cases-phrase { <complete-adjective> <cases-noun> }
    rule contingency-matrix-phrase { <contingency-noun> [ <matrix-noun> | <table-noun> ] }
    rule cross-tabulate-phrase { <cross-verb> <tabulate-verb> }
    rule keep-only-phrase { <keep-verb> <only-adverb>? }
    rule with-formula-phrase { <with-preposition> <the-determiner>? <formula-noun> }

    # True dplyr/tidyverse commands
    token ascending { <ascending-adjective> | 'asc' }
    token descending { <descending-adjective> | 'desc' }
    token mutate { <mutate-verb> }
    token order { <order-verb> }

    rule arrange-by-phrase { <arrange-directive> [ <by-preposition> | <using-preposition> | <with-preposition> ] }
    rule arrange-directive { <arrange-verb> | <order-verb> | <sort-verb> }
    rule data-phrase { <.the-determiner>? <data> }
    rule dictionary-phrase { <.association-noun> | <.dictionary-noun> | <.mapping-noun> }
    rule filter { <filter-verb> | <select-verb> }
    rule format-phrase { <form-noun> | <format-noun> }
    rule group-by { <group-verb> [ <by-preposition> | <using-preposition> ] }
    rule group-map { <group-verb> [ <mapping-noun> | <map-verb> ] | <apply-verb> <per-preposition> <group-verb> }
    rule id-columns-phrase { [ <id-noun> | <identifier-noun> ] <columns> }
    rule pivot-columns-phrase    { [ <pivot-verb> | <variable-noun> ]? <the-determiner>? <columns> }
    rule pivot-id-columns-phrase { [ <pivot-verb> | <variable-noun> ]? <the-determiner>? <id-columns-phrase> }
    rule rename-directive { <rename-verb> }
    rule reverse-sort-phrase { <reverse-adjective> [ <sort-verb> | <order-verb> ] }
    rule safely-directive { <safe-adjective> | <safely-adverb> }
    rule select { <select-verb> | <take-verb> | <keep-only-phrase> }
    rule separator-phrase { <separator-noun> | <divider-noun> | <splitter-noun> | <splitting-noun> }
    rule string-column-phrase { [ <string-noun> | <character-noun> | <text-noun> ] <column-noun> }
    rule longer-phrase { <longer-adjective> | <long-adjective> | <narrow-adjective> }
    rule wider-phrase  { <wider-adjective>  | <wide-adjective> | <broad-adjective> }
    rule to-long-form-phrase { <pivot-verb> <to-preposition>? <longer-phrase> <format-phrase>? | <to-preposition> <longer-phrase> <format-phrase> | <melt-verb>  }
    rule to-wide-form-phrase { <pivot-verb> <to-preposition>? <wider-phrase>  <format-phrase>? | <to-preposition> <wider-phrase>  <format-phrase> | <cast-verb>  }
    rule value-column-name-phrase { <value-column-phrase> <name-noun> }
    rule value-column-phrase { <value-noun> <column-noun>? }
    rule variable-column-name-phrase { <variable-column-phrase> <name-noun> }
    rule variable-column-phrase { <variable-noun> <column-noun>? }
}

