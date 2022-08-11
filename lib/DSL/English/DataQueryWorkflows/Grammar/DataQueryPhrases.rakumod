use DSL::Shared::Utilities::FuzzyMatching;

# Data query specific phrases
role DSL::English::DataQueryWorkflows::Grammar::DataQueryPhrases {
    # Tokens

    proto token arrange-verb {*}
    token arrange-verb:sym<English> { :i 'arrange' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'arrange', 2) }> }

    proto token ascending-adjective {*}
    token ascending-adjective:sym<English> { :i 'ascending' | ([\w]+) <?{ $0.Str ne 'descending' and is-fuzzy-match($0.Str, 'ascending', 2) }> }

    proto token association-noun {*}
    token association-noun:sym<English> { :i 'association' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'association', 2) }> }

    proto token broad-adjective {*}
    token broad-adjective:sym<English> { :i 'broad' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'broad', 2) }> }

    proto token cast-verb {*}
    token cast-verb:sym<English> { :i 'cast' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'cast', 2) }> }

    proto token character-noun {*}
    token character-noun:sym<English> { :i 'character' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'character', 2) }> }

    proto token combine-verb {*}
    token combine-verb:sym<English> { :i 'combine' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'combine', 2) }> }

    proto token cross-verb {*}
    token cross-verb:sym<English> { :i 'cross' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'cross', 2) }> }

    proto token descending-adjective {*}
    token descending-adjective:sym<English> { :i 'descending' | ([\w]+) <?{ $0.Str ne 'ascending' and is-fuzzy-match($0.Str, 'descending', 2) }> }

    proto token distinct-adjective {*}
    token distinct-adjective:sym<English> { :i 'distinct' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'distinct', 2) }> }

    proto token divider-noun {*}
    token divider-noun:sym<English> { :i 'divider' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'divider', 2) }> }

    proto token duplicate-adjective {*}
    token duplicate-adjective:sym<English> { :i 'duplicate' | ([\w]+) <?{ $0.Str ne 'duplicates' and is-fuzzy-match($0.Str, 'duplicate', 2) }> }

    proto token duplicates-noun {*}
    token duplicates-noun:sym<English> { :i 'duplicates' | ([\w]+) <?{ $0.Str ne 'duplicate' and is-fuzzy-match($0.Str, 'duplicates', 2) }> }

    proto token form-noun {*}
    token form-noun:sym<English> { :i 'form' | ([\w]+) <?{ $0.Str !(elem) <format sort> and is-fuzzy-match($0.Str, 'form', 2) }> }

    proto token format-noun {*}
    token format-noun:sym<English> { :i 'format' | ([\w]+) <?{ $0.Str ne 'form' and is-fuzzy-match($0.Str, 'format', 2) }> }

    proto token formula-noun {*}
    token formula-noun:sym<English> { :i 'formula' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'formula', 2) }> }

    proto token full-adjective {*}
    token full-adjective:sym<English> { :i 'full' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'full', 2) }> }

    proto token glimpse-verb {*}
    token glimpse-verb:sym<English> { :i 'glimpse' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'glimpse', 2) }> }

    proto token group-verb {*}
    token group-verb:sym<English> { :i 'group' | ([\w]+) <?{ $0.Str ne 'ungroup' and is-fuzzy-match($0.Str, 'group', 2) }> }

    proto token inner-adjective {*}
    token inner-adjective:sym<English> { :i 'inner' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'inner', 2) }> }

    proto token keep-verb {*}
    token keep-verb:sym<English> { :i 'keep' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'keep', 2) }> }

    proto token long-adjective {*}
    token long-adjective:sym<English> { :i 'long' | ([\w]+) <?{ $0.Str ne 'longer' and is-fuzzy-match($0.Str, 'long', 2) }> }

    proto token longer-adjective {*}
    token longer-adjective:sym<English> { :i 'longer' | ([\w]+) <?{ $0.Str ne 'long' and is-fuzzy-match($0.Str, 'longer', 2) }> }

    proto token map-verb {*}
    token map-verb:sym<English> { :i 'map' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'map', 1) }> }

    proto token mapping-noun {*}
    token mapping-noun:sym<English> { :i 'mapping' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'mapping', 2) }> }

    proto token melt-verb {*}
    token melt-verb:sym<English> { :i 'melt' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'melt', 2) }> }

    proto token merge-noun {*}
    token merge-noun:sym<English> { :i <merge-verb> }

    proto token merge-verb {*}
    token merge-verb:sym<English> { :i 'merge' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'merge', 2) }> }

    proto token mutate-verb {*}
    token mutate-verb:sym<English> { :i 'mutate' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'mutate', 2) }> }

    proto token narrow-adjective {*}
    token narrow-adjective:sym<English> { :i 'narrow' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'narrow', 2) }> }

    proto token narrower-adjective {*}
    token narrower-adjective:sym<English> { :i 'narrow' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'narrow', 2) }> }

    proto token omit-directive {*}
    token omit-directive:sym<English> { :i 'omit' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'omit', 2) }> | 'exclude' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'exclude', 2) }> }

    proto token only-adverb {*}
    token only-adverb:sym<English> { :i 'only' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'only', 2) }> }

    proto token order-verb {*}
    token order-verb:sym<English> { :i 'order' | ([\w]+) <?{ $0.Str ne 'wider' and is-fuzzy-match($0.Str, 'order', 2) }> }

    proto token pivot-verb {*}
    token pivot-verb:sym<English> { :i 'pivot' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'pivot', 2) }> }

    proto token rename-verb {*}
    token rename-verb:sym<English> { :i 'rename' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'rename', 2) }> }

    proto token safe-adjective {*}
    token safe-adjective:sym<English> { :i 'safe' | ([\w]+) <?{ $0.Str ne 'safely' and is-fuzzy-match($0.Str, 'safe', 2) }> }

    proto token safely-adverb {*}
    token safely-adverb:sym<English> { :i 'safely' | ([\w]+) <?{ $0.Str ne 'safe' and is-fuzzy-match($0.Str, 'safely', 2) }> }

    proto token select-verb {*}
    token select-verb:sym<English> { :i 'select' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'select', 2) }> }

    proto token semi-adjective {*}
    token semi-adjective:sym<English> { :i 'semi' | ([\w]+) <?{ $0.Str ne 'skim' and is-fuzzy-match($0.Str, 'semi', 2) }> }

    proto token separator-noun {*}
    token separator-noun:sym<English> { :i 'separator' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'separator', 2) }> }

    proto token skim-verb {*}
    token skim-verb:sym<English> { :i 'skim' | ([\w]+) <?{ $0.Str ne 'semi' and is-fuzzy-match($0.Str, 'skim', 2) }> }

    proto token skimming-noun {*}
    token skimming-noun:sym<English> { :i 'skimming' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'skimming', 2) }> }

    proto token sort-verb {*}
    token sort-verb:sym<English> { :i 'sort' | ([\w]+) <?{ $0.Str ne 'form' and is-fuzzy-match($0.Str, 'sort', 2) }> }

    proto token splitter-noun {*}
    token splitter-noun:sym<English> { :i 'splitter' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'splitter', 2) }> }

    proto token splitting-noun {*}
    token splitting-noun:sym<English> { :i 'splitting' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'splitting', 2) }> }

    proto token summarise-verb {*}
    token summarise-verb:sym<English> { :i 'summarise' | ([\w]+) <?{ $0.Str ne 'summarize' and is-fuzzy-match($0.Str, 'summarise', 2) }> }

    proto token summarize-verb {*}
    token summarize-verb:sym<English> { :i 'summarize' | ([\w]+) <?{ $0.Str ne 'summarise' and is-fuzzy-match($0.Str, 'summarize', 2) }> }

    proto token tabulate-verb {*}
    token tabulate-verb:sym<English> { :i 'tabulate' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'tabulate', 2) }> }

    proto token tabulation-noun {*}
    token tabulation-noun:sym<English> { :i 'tabulation' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'tabulation', 2) }> }

    proto token ungroup-verb {*}
    token ungroup-verb:sym<English> { :i 'ungroup' | ([\w]+) <?{ $0.Str ne 'group' and is-fuzzy-match($0.Str, 'ungroup', 2) }> }

    proto token unique-adjective {*}
    token unique-adjective:sym<English> { :i 'unique' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'unique', 2) }> }

    proto token wide-adjective {*}
    token wide-adjective:sym<English> { :i 'wide' | ([\w]+) <?{ $0.Str ne 'wider' and is-fuzzy-match($0.Str, 'wide', 2) }> }

    proto token wider-adjective {*}
    token wider-adjective:sym<English> { :i 'wider' | ([\w]+) <?{ $0.Str !(elem) <order wide> and is-fuzzy-match($0.Str, 'wider', 2) }> }

    # Rules

    proto rule contingency-matrix-phrase {*}
    rule contingency-matrix-phrase:sym<English> {  <contingency-noun> [ <matrix-noun> | <table-noun> ]  }

    proto rule cross-tabulate-phrase {*}
    rule cross-tabulate-phrase:sym<English> {  <cross-verb> <tabulate-verb>  }

    proto rule cross-tabulation-phrase {*}
    rule cross-tabulation-phrase:sym<English> {  <cross-verb> <tabulation-noun>  }

    proto rule keep-only-phrase {*}
    rule keep-only-phrase:sym<English> {  <keep-verb> <only-adverb>?  }

    proto rule with-formula-phrase {*}
    rule with-formula-phrase:sym<English> {  <with-preposition> <the-determiner>? <formula-noun>  }

    # True dplyr/tidyverse commands

    proto token ascending-phrase {*}
    token ascending-phrase:sym<English> { :i  <ascending-adjective> | 'asc'  }

    proto token descending-phrase {*}
    token descending-phrase:sym<English> { :i  <descending-adjective> | 'desc'  }


    proto rule arrange-by-phrase {*}
    rule arrange-by-phrase:sym<English> {  <arrange-directive> [ <by-preposition> | <using-preposition> | <with-preposition> ]  }

    proto rule arrange-directive {*}
    rule arrange-directive:sym<English> { <arrange-verb> | <order-verb> | <sort-verb> }

    proto rule data-phrase {*}
    rule data-phrase:sym<English> {  <.the-determiner>? <data>  }

    proto rule dictionary-phrase {*}
    rule dictionary-phrase:sym<English> {  <.association-noun> | <.dictionary-noun> | <.mapping-noun>  }

    proto rule filter-phrase {*}
    rule filter-phrase:sym<English> { <filter-verb> | <select-verb> }

    proto rule format-phrase {*}
    rule format-phrase:sym<English> { <form-noun> | <format-noun> }

    proto rule group-by-phrase {*}
    rule group-by-phrase:sym<English> {  <group-verb> [ <by-preposition> <using-preposition>? | <using-preposition> | <over-preposition> ]  }

    proto rule group-map-phrase {*}
    rule group-map-phrase:sym<English> {  <group-verb> [ <mapping-noun> | <map-verb> ] | <apply-verb> <per-preposition> <group-verb>  }

    proto rule id-columns-phrase {*}
    rule id-columns-phrase:sym<English> {  [ <id-noun> | <identifier-noun> | <identifier-adjective> ] <columns>  }

    proto rule join-phrase {*}
    rule join-phrase:sym<English> { <join-noun> | <merge-verb> | <merge-noun> }

    proto rule longer-phrase {*}
    rule longer-phrase:sym<English> { <longer-adjective> | <long-adjective> | <narrow-adjective> }

    proto rule pivot-columns-phrase {*}
    rule pivot-columns-phrase:sym<English> {  [ <pivot-verb> | <variable-noun> ]? <the-determiner>? <columns>  }

    proto rule pivot-id-columns-phrase {*}
    rule pivot-id-columns-phrase:sym<English> {  [ <pivot-verb> | <variable-noun> ]? <the-determiner>? <id-columns-phrase>  }

    proto rule pivot-longer-phrase {*}
    rule pivot-longer-phrase:sym<English> {  <pivot-verb> <longer-phrase>  }

    proto rule pivot-wider-phrase {*}
    rule pivot-wider-phrase:sym<English> {  <pivot-verb> <wider-phrase>  }

    proto rule rename-directive {*}
    rule rename-directive:sym<English> { <rename-verb> }

    proto rule reverse-sort-phrase {*}
    rule reverse-sort-phrase:sym<English> {  <reverse-adjective> [ <sort-verb> | <order-verb> ]  }

    proto rule safely-directive {*}
    rule safely-directive:sym<English> { <safe-adjective> | <safely-adverb> }

    proto rule select {*}
    rule select:sym<English> { <select-verb> | <take-verb> | <keep-only-phrase> }

    proto rule separator-phrase {*}
    rule separator-phrase:sym<English> { 
        <separator-noun> |
        <divider-noun> |
        <splitter-noun> |
        <splitting-noun> }

    proto rule string-column-phrase {*}
    rule string-column-phrase:sym<English> {  [ <string-noun> | <character-noun> | <text-noun> ] <column-noun>  }

    proto rule to-long-form-phrase {*}
    rule to-long-form-phrase:sym<English> {  <pivot-verb> [ <to-preposition> | <into-preposition> ]? <longer-phrase> <format-phrase>? | [ <to-preposition> | <into-preposition> ] <longer-phrase> <format-phrase> | <melt-verb>   }

    proto rule to-wide-form-phrase {*}
    rule to-wide-form-phrase:sym<English> {  <pivot-verb> [ <to-preposition> | <into-preposition> ]? <wider-phrase>  <format-phrase>? | [ <to-preposition> | <into-preposition> ] <wider-phrase>  <format-phrase> | <cast-verb>   }

    proto rule value-column-name-phrase {*}
    rule value-column-name-phrase:sym<English> {  <value-column-phrase> <name-noun>  }

    proto rule value-column-phrase {*}
    rule value-column-phrase:sym<English> {  <value-noun> <column-noun>?  }

    proto rule variable-column-name-phrase {*}
    rule variable-column-name-phrase:sym<English> {  <variable-column-phrase> <name-noun>  }

    proto rule variable-column-phrase {*}
    rule variable-column-phrase:sym<English> {  <variable-noun> <column-noun>?  }

    proto rule wider-phrase {*}
    rule wider-phrase:sym<English> { <wider-adjective> | <wide-adjective> | <broad-adjective> }
}

