use DSL::Shared::Utilities::FuzzyMatching;

# Data query specific phrases
role DSL::English::DataQueryWorkflows::Grammar::DataQueryPhrases {
    # Tokens

    proto token arrange-verb {*}
    token arrange-verb:sym<English> { :i 'arrange' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'arrange', 2) }> }

    proto token ascending-adjective {*}
    token ascending-adjective:sym<English> { :i 'ascending' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'ascending', 2) }> }

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
    token descending-adjective:sym<English> { :i 'descending' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'descending', 2) }> }

    proto token dictionary-noun {*}
    token dictionary-noun:sym<English> { :i 'dictionary' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'dictionary', 2) }> }

    proto token distinct-adjective {*}
    token distinct-adjective:sym<English> { :i 'distinct' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'distinct', 2) }> }

    proto token divider-noun {*}
    token divider-noun:sym<English> { :i 'divider' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'divider', 2) }> }

    proto token duplicate-adjective {*}
    token duplicate-adjective:sym<English> { :i 'duplicate' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'duplicate', 2) }> }

    proto token duplicates-noun {*}
    token duplicates-noun:sym<English> { :i 'duplicates' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'duplicates', 2) }> }

    proto token form-noun {*}
    token form-noun:sym<English> { :i 'form' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'form', 2) }> }

    proto token format-noun {*}
    token format-noun:sym<English> { :i 'format' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'format', 2) }> }

    proto token formula-noun {*}
    token formula-noun:sym<English> { :i 'formula' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'formula', 2) }> }

    proto token full-adjective {*}
    token full-adjective:sym<English> { :i 'full' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'full', 2) }> }

    proto token glimpse-verb {*}
    token glimpse-verb:sym<English> { :i 'glimpse' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'glimpse', 2) }> }

    proto token group-verb {*}
    token group-verb:sym<English> { :i 'group' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'group', 2) }> }

    proto token inner-adjective {*}
    token inner-adjective:sym<English> { :i 'inner' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'inner', 2) }> }

    proto token join-noun {*}
    token join-noun:sym<English> { :i 'join' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'join', 2) }> }

    proto token keep-verb {*}
    token keep-verb:sym<English> { :i 'keep' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'keep', 2) }> }

    proto token left-adjective {*}
    token left-adjective:sym<English> { :i 'left' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'left', 2) }> }

    proto token long-adjective {*}
    token long-adjective:sym<English> { :i 'long' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'long', 2) }> }

    proto token longer-adjective {*}
    token longer-adjective:sym<English> { :i 'longer' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'longer', 2) }> }

    proto token map-verb {*}
    token map-verb:sym<English> { :i 'map' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'map', 1) }> }

    proto token mapping-noun {*}
    token mapping-noun:sym<English> { :i 'mapping' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'mapping', 2) }> }

    proto token melt-verb {*}
    token melt-verb:sym<English> { :i 'melt' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'melt', 2) }> }

    proto token merge-noun {*}
    token merge-noun:sym<English> { <merge-verb> }

    proto token merge-verb {*}
    token merge-verb:sym<English> { :i 'merge' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'merge', 2) }> }

    proto token mutate-verb {*}
    token mutate-verb:sym<English> { :i 'mutate' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'mutate', 2) }> }

    proto token narrow-adjective {*}
    token narrow-adjective:sym<English> { :i 'narrow' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'narrow', 2) }> }

    proto token omit-directive {*}
    token omit-directive:sym<English> { :i 'omit' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'omit', 2) }> | 'exclude' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'exclude', 2) }> }

    proto token only-adverb {*}
    token only-adverb:sym<English> { :i 'only' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'only', 2) }> }

    proto token order-verb {*}
    token order-verb:sym<English> { :i 'order' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'order', 2) }> }

    proto token pivot-verb {*}
    token pivot-verb:sym<English> { :i 'pivot' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'pivot', 2) }> }

    proto token rename-verb {*}
    token rename-verb:sym<English> { :i 'rename' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'rename', 2) }> }

    proto token right-adjective {*}
    token right-adjective:sym<English> { :i 'right' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'right', 2) }> }

    proto token safe-adjective {*}
    token safe-adjective:sym<English> { :i 'safe' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'safe', 2) }> }

    proto token safely-adverb {*}
    token safely-adverb:sym<English> { :i 'safely' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'safely', 2) }> }

    proto token select-verb {*}
    token select-verb:sym<English> { :i 'select' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'select', 2) }> }

    proto token semi-adjective {*}
    token semi-adjective:sym<English> { :i 'semi' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'semi', 2) }> }

    proto token separator-noun {*}
    token separator-noun:sym<English> { :i 'separator' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'separator', 2) }> }

    proto token skim-verb {*}
    token skim-verb:sym<English> { :i 'skim' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'skim', 2) }> }

    proto token skimming-noun {*}
    token skimming-noun:sym<English> { :i 'skimming' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'skimming', 2) }> }

    proto token sort-verb {*}
    token sort-verb:sym<English> { :i 'sort' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'sort', 2) }> }

    proto token splitter-noun {*}
    token splitter-noun:sym<English> { :i 'splitter' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'splitter', 2) }> }

    proto token splitting-noun {*}
    token splitting-noun:sym<English> { :i 'splitting' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'splitting', 2) }> }

    proto token summarise-verb {*}
    token summarise-verb:sym<English> { :i 'summarise' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'summarise', 2) }> }

    proto token summarize-verb {*}
    token summarize-verb:sym<English> { :i 'summarize' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'summarize', 2) }> }

    proto token tabulate-verb {*}
    token tabulate-verb:sym<English> { :i 'tabulate' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'tabulate', 2) }> }

    proto token ungroup-verb {*}
    token ungroup-verb:sym<English> { :i 'ungroup' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'ungroup', 2) }> }

    proto token unique-adjective {*}
    token unique-adjective:sym<English> { :i 'unique' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'unique', 2) }> }

    proto token wide-adjective {*}
    token wide-adjective:sym<English> { :i 'wide' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'wide', 2) }> }

    proto token wider-adjective {*}
    token wider-adjective:sym<English> { :i 'wider' | ([\w]+) <?{ is-fuzzy-match($0.Str, 'wider', 2) }> }

    # Rules
    rule contingency-matrix-phrase { <contingency-noun> [ <matrix-noun> | <table-noun> ] }
    rule cross-tabulate-phrase { <cross-verb> <tabulate-verb> }
    rule keep-only-phrase { <keep-verb> <only-adverb>? }
    rule with-formula-phrase { <with-preposition> <the-determiner>? <formula-noun> }

    # True dplyr/tidyverse commands

    proto token ascending-phrase {*}
    token ascending-phrase:sym<English> { :i  <ascending-adjective> | 'asc'  }

    proto token descending-phrase {*}
    token descending-phrase:sym<English> { :i  <descending-adjective> | 'desc'  }

    rule arrange-by-phrase { <arrange-directive> [ <by-preposition> | <using-preposition> | <with-preposition> ] }
    rule arrange-directive { <arrange-verb> | <order-verb> | <sort-verb> }
    rule data-phrase { <.the-determiner>? <data> }
    rule dictionary-phrase { <.association-noun> | <.dictionary-noun> | <.mapping-noun> }
    rule filter-phrase { <filter-verb> | <select-verb> }
    rule format-phrase { <form-noun> | <format-noun> }
    rule group-by { <group-verb> [ <by-preposition> | <using-preposition> ] }
    rule group-map { <group-verb> [ <mapping-noun> | <map-verb> ] | <apply-verb> <per-preposition> <group-verb> }
    rule id-columns-phrase { [ <id-noun> | <identifier-noun> | <identifier-adjective> ] <columns> }
    rule join-phrase { <join-noun> | <merge-verb> | <merge-noun> }
    rule longer-phrase { <longer-adjective> | <long-adjective> | <narrow-adjective> }
    rule pivot-columns-phrase    { [ <pivot-verb> | <variable-noun> ]? <the-determiner>? <columns> }
    rule pivot-id-columns-phrase { [ <pivot-verb> | <variable-noun> ]? <the-determiner>? <id-columns-phrase> }
    rule rename-directive { <rename-verb> }
    rule reverse-sort-phrase { <reverse-adjective> [ <sort-verb> | <order-verb> ] }

    rule safely-directive { <safe-adjective> | <safely-adverb> }
    rule select { <select-verb> | <take-verb> | <keep-only-phrase> }
    rule separator-phrase { <separator-noun> | <divider-noun> | <splitter-noun> | <splitting-noun> }
    rule string-column-phrase { [ <string-noun> | <character-noun> | <text-noun> ] <column-noun> }
    rule to-long-form-phrase { <pivot-verb> [ <to-preposition> | <into-preposition> ]? <longer-phrase> <format-phrase>? | [ <to-preposition> | <into-preposition> ] <longer-phrase> <format-phrase> | <melt-verb>  }
    rule to-wide-form-phrase { <pivot-verb> [ <to-preposition> | <into-preposition> ]? <wider-phrase>  <format-phrase>? | [ <to-preposition> | <into-preposition> ] <wider-phrase>  <format-phrase> | <cast-verb>  }
    rule value-column-name-phrase { <value-column-phrase> <name-noun> }
    rule value-column-phrase { <value-noun> <column-noun>? }
    rule variable-column-name-phrase { <variable-column-phrase> <name-noun> }
    rule variable-column-phrase { <variable-noun> <column-noun>? }
    rule wider-phrase  { <wider-adjective>  | <wide-adjective> | <broad-adjective> }
}

