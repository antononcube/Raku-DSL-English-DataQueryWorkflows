use v6.d;

use DSL::English::DataQueryWorkflows::Grammar;
use DSL::Shared::Actions::SQL::PredicateSpecification;
use DSL::Shared::Actions::English::SQL::PipelineCommand;

class DSL::English::DataQueryWorkflows::Actions::SQL::Standard
		is DSL::Shared::Actions::SQL::PredicateSpecification
		is DSL::Shared::Actions::English::SQL::PipelineCommand {

	has Str $.name = 'DSL-English-DataQueryWorkflows-SQL-Standard';

	sub to-unquoted(Str $ss is copy) {
		if $ss ~~ / ^ '\'' (.*) '\'' $ / { return ~$0; }
		if $ss ~~ / ^ '"' (.*) '"' $ / { return ~$0; }
		return $ss;
	}

	# Top
	method TOP($/) { make $/.values[0].made; }

	# workflow-command-list
	method workflow-commands-list($/) {
		my @parts = $/.values>>.made;

		if @parts.elems == 1 {
			make @parts.head ~~ Pair ?? @parts.head.key !! @parts.head;
			return;
		}

		for @parts -> $p {
			if $p !~~ Pair { die "Parsing result is not a pair: ⎡$p⎦" }
		}

		# At this point we know @parts is a list of pairs

		my @res;

		@res.push( @parts.Hash<select> // 'SELECT *' );
		@res.push( @parts.Hash<data-load> // 'FROM #tbl' );
		if @parts.Hash<join> { @res.push( @parts.Hash<join> ); }
		if @parts.Hash<where> { @res.push( @parts.Hash<where> ); }
		if @parts.Hash<order-by> { @res.push( @parts.Hash<order-by> ); }

		make @res.join("\n");
	}

	# workflow-command
	method workflow-command($/) { make $/.values[0].made; }

	# Overriding DSL::Shared::Actions::R::PredicateSpecification::predicate-simple :
	# if with quotes using the universal as.name(...).
	method predicate-simple($/) {
		my Str $objCol =
				self.is-single-quoted($<lhs>.made) || self.is-double-quoted($<lhs>.made)
				?? 'as.name(' ~ $<lhs>.made ~ ')'
				!! $<lhs>.made;

		if $<predicate-relation>.made eq '%!in%' {
			make '!( ' ~ $objCol ~ ' %in% ' ~ $<rhs>.made ~ ')';
		} elsif $<predicate-relation>.made eq 'like' {
			make 'grepl( pattern = ' ~ $<rhs>.made ~ ', x = ' ~ $objCol ~ ')';
		} else {
			make $objCol ~ ' ' ~ $<predicate-relation>.made ~ ' ' ~ $<rhs>.made;
		}
	}

	# General
	method variable-names-list($/) { make $<variable-name>>>.made.join(', '); }
	method quoted-variable-names-list($/) { make $<quoted-variable-name>>>.made.join(', '); }
	method mixed-quoted-variable-names-list($/) { make $<mixed-quoted-variable-name>>>.made.join(', '); }

	# Column specs
	method column-specs-list($/) { make $<column-spec>>>.made.join(', '); }
	method column-spec($/) {  make $/.values[0].made; }
	method column-name-spec($/) { make $<mixed-quoted-variable-name>.made.&to-unquoted; }

	# Load data
	method data-load-command($/) { make 'data-load' => $/.values[0].made; }
	method load-data-table($/) { make 'FROM ' ~ $<data-location-spec>.made.&to-unquoted }
	method data-location-spec($/) { make $/.Str; }
	method use-data-table($/) {
		# In case we want to copy the table
		#  make 'SELECT * INTO #tbl FROM ' ~ $<mixed-quoted-variable-name>.made;
		make 'FROM ' ~ $<mixed-quoted-variable-name>.made.&to-unquoted;
	}

	# Distinct command
	method distinct-command($/) { make $/.values[0].made; }
	method distinct-simple-command($/) { make 'DISTINCT'; }

	# Missing treatment command
	method missing-treatment-command($/) { make $/.values[0].made; }
	method drop-incomplete-cases-command($/) { make 'na.omit()'; }
	method replace-missing-command($/) {
		my $na = $<replace-missing-rhs> ?? $<replace-missing-rhs>.made !! '"NA"';
		make '"Not implemented"';
	}
	method replace-missing-rhs($/) { make $/.values[0].made; }

	# Replace command
	method replace-command($/) { make '"Not implemented"'; }

	# Select command
	method select-command($/) { make 'select' => $/.values[0].made; }
	method select-columns-simple($/) { make 'SELECT ' ~ $/.values[0].made; }
	method select-columns-by-two-lists($/) {
		# I am not very comfortable with splitting the made string here, but it works.
		# Maybe it is better to no not join the elements in <variable-names-list>.
		# Note that here with subst we assume no single quotes are in <mixed-quoted-variable-names-list>.made .
		my @currentNames = $<current>.made.subst(:g, '"', '').split(', ');
		my @newNames = $<new>.made.subst(:g, '"', '').split(', ');

		if @currentNames.elems != @newNames.elems {
			note 'Same number of current and new column names are expected for column selection with renaming.';
			make '"FAILED"';
		} else {
			my $pairs = do for @currentNames Z @newNames -> ($c, $n) { $n ~ ' = ' ~ $c };
			make 'SELECT ' ~ $pairs.join(', ');
		}
	}
	method select-columns-by-pairs($/) { make 'SELECT ' ~ $<as-pairs-list>.made; }

	# Filter commands
	method filter-command($/) { make 'where' => 'WHERE ' ~ $<filter-spec>.made; }
	method filter-spec($/) { make $<predicates-list>.made; }

	# Mutate command
	method mutate-command($/) { make 'mutate' => $/.values[0].made; }
	method mutate-by-two-lists($/) {
		my @currentNames = $<current>.made.subst(:g, '"', '').split(', ');
		my @newNames = $<new>.made.subst(:g, '"', '').split(', ');

		if @currentNames.elems != @newNames.elems {
			note 'Same number of current and new column names are expected for mutation by two lists.';
			make '"FAILED"';
		} else {
			my $pairs = do for @currentNames Z @newNames -> ($c, $n) { $n ~ ' TO ' ~ $c };
			make $pairs.map({ 'ALTER TABLE tbl RENAME COLUMN ' ~ $_  }).join("\n");
		}
	}
	method mutate-by-pairs($/) { make $/.values[0].made.map({ 'ALTER TABLE tbl RENAME COLUMN ' ~ $_  }).join("\n"); }

	# Group command
	method group-command($/) { make 'group' => $/.values[0].made; }
	method group-by-command($/) { make 'GROUP BY ' ~ $/.values[0].made; }
	method group-map-command($/) { make '"Not implemented"'; }

	# Ungroup command
	method ungroup-command($/) { 'ungroup' => make $/.values[0].made; }
	method ungroup-simple-command($/) { make '"Not implemented"'; }

	# Arrange command
	method arrange-command($/) { make 'order-by' => $/.values[0].made; }
	method arrange-simple-command($/) {
		make $<reverse-sort-phrase> || $<descending-adjective> ?? 'ORDER BY DESC' !! 'ORDER BY';
	}
	method arrange-by-spec($/) { make $/.values[0].made; }
	method arrange-by-command-ascending($/) { make 'ORDER BY ' ~ $<arrange-by-spec>.made; }
	method arrange-by-command-descending($/) { make 'ORDER BY ' ~ $<arrange-by-spec>.made ~ ' DESC'; }

	# Rename columns command
	method rename-columns-command($/) { make $/.values[0].made; }
	method rename-columns-by-two-lists($/) {
		# I am not very comfortable with splitting the made string here, but it works.
		# Maybe it is better to no not join the elements in <variable-names-list>.
		# Note that here with subst we assume no single quotes are in <mixed-quoted-variable-names-list>.made .
		my @currentNames = $<current>.made.subst(:g, '"', '').split(', ');
		my @newNames = $<new>.made.subst(:g, '"', '').split(', ');

		if @currentNames.elems != @newNames.elems {
			note 'Same number of current and new column names are expected for column renaming.';
			make 'SELECT *';
		} else {
			my $pairs = do for @currentNames Z @newNames -> ($c, $n) { $n ~ ' = ' ~ $c };
			make 'SELECT ' ~ $pairs.join(', ');
		}
	}
	method rename-columns-by-pairs($/) { make 'dplyr::rename(' ~ $<as-pairs-list>.made ~ ')'; }

	# Drop columns command
	method drop-columns-command($/) { make $/.values[0].made; }
	method drop-columns-simple($/) {
		# Note that here we assume no single quotes are in <mixed-quoted-variable-names-list>.made .
		my @todrop = $<todrop>.made.subst(:g, '"', '').split(', ');
		make @todrop.map({ 'ALTER TABLE tbl DROP COLUMN ' ~  $_ }).join(";\n")
	}

	# Statistics command
	method statistics-command($/) { make $/.values[0].made; }
	method data-dimensions-command($/) { make 'SELECT COUNT(*)'; }
	method count-command($/) { make 'SELECT COUNT(*)'; }
	method echo-count-command($/) {
		make '( function(x) { print(x %>% dplyr::count()); x } )';
	}
	method data-summary-command($/) { make '( function(x) { print(summary(x)); x } )'; }
	method glimpse-data($/) { make 'dplyr::glimpse()'; }
	method skim-data($/) {
		make 'skimr::skim()';
	}

	# Summarize command
	method summarize-command($/) { make $/.values[0].made; }
	method summarize-by-pairs($/) { make 'dplyr::summarize(' ~ $/.values[0].made ~ ')'; }
	method summarize-all-command($/) {
		if $<summarize-funcs-spec> {
			make 'dplyr::summarise_all( .funs = ' ~ $<summarize-funcs-spec>.made ~ ' )';
		} else {
			make 'dplyr::summarise_all(mean)';
		}
	}
	method summarize-at-command($/) {
		my $cols = 'c(' ~ map( { '"' ~ $_ ~ '"' }, $<cols>.made.split(', ') ).join(', ') ~ ')';
		if $<summarize-funcs-spec> {
			make 'dplyr::summarise_at( .vars = ' ~ $cols ~ ', ' ~ '.funs = ' ~ $<summarize-funcs-spec>.made ~ ' )';
		} else {
			make 'dplyr::summarise_at( .vars = ' ~ $cols ~ ', .funs = c( Min = function(.) min(., na.rm = T), Max = function(.) max(., na.rm = T), Mean = function(.) mean(., na.rm = T), Median = function(.) median(., na.rm = T), Sum = function(.) sum(., na.rm = T) ) )';
		}
	}
	method summarize-funcs-spec($/) { make 'c(' ~ map( { $_ ~ ' = ' ~ $_ }, $<variable-name-or-wl-expr-list>.made ).join(', ') ~ ')'; }

	# Join command
	method join-command($/) { make $/.values[0].made; }

	method join-by-spec($/) {
		if $<mixed-quoted-variable-names-list> {
			make $/.values[0].made.&to-unquoted.split(', ').join(', ');
		} else {
			make $/.values[0].made;
		}
	}

	method full-join-spec($/)  {
		if $<join-by-spec> {
			make 'dplyr::full_join(' ~ $<dataset-name>.made ~ ', by = ' ~ $<join-by-spec>.made ~ ')';
		} else {
			make 'dplyr::full_join(' ~ $<dataset-name>.made ~ ')';
		}
	}

	method inner-join-spec($/)  {
		make 'join' => do if $<join-by-spec> {
			'INNER JOIN ' ~ $<dataset-name>.made ~ ' ON ' ~ $<join-by-spec>.made;
		} else {
			'INNER JOIN ' ~ $<dataset-name>.made;
		}
	}

	method left-join-spec($/)  {
		make 'join' => do if $<join-by-spec> {
			'LEFT JOIN ' ~ $<dataset-name>.made ~ ' ON ' ~ $<join-by-spec>.made;
		} else {
			'LEFT JOIN ' ~ $<dataset-name>.made;
		}
	}

	method right-join-spec($/)  {
		make 'join' => do if $<join-by-spec> {
			'RIGHT JOIN ' ~ $<dataset-name>.made ~ ' ON ' ~ $<join-by-spec>.made;
		} else {
			'RIGHT JOIN ' ~ $<dataset-name>.made;
		}
	}

	method semi-join-spec($/)  {
		my $sql = 'tbl WHERE EXISTS (SELECT 1 FROM $OTHER WHERE tbl.$ON = $OTHER.$ON)';

		make 'join' => do if $<join-by-spec> {
			$sql.substs('$OTHER', $<dataset-name>.made, :g).subtst('$ON', $<join-by-spec>.made, :g);
		} else {
			$sql.substs('$OTHER', $<dataset-name>.made, :g).subtst('$ON', 'id', :g);
		}
	}

	# Cross tabulate command
	method cross-tabulation-command($/) { make $/.values[0].made; }
	method cross-tabulate-command($/) { $<cross-tabulation-formula>.made }
	method contingency-matrix-command($/) { $<cross-tabulation-formula>.made }
	method cross-tabulation-formula($/) { make $/.values[0].made; }
	method cross-tabulation-double-formula($/) {
		if $<values-variable-name> {
			make '(function(x) as.data.frame(xtabs( formula = ' ~ $<values-variable-name>.made ~ ' ~ ' ~ $<rows-variable-name>.made ~ ' + ' ~ $<columns-variable-name>.made ~ ', data = x ), stringsAsFactors=FALSE ))';
		} else {
			make '(function(x) as.data.frame(xtabs( formula = ~ ' ~ $<rows-variable-name>.made ~ ' + ' ~ $<columns-variable-name>.made ~ ', data = x ), stringsAsFactors=FALSE ))';
		}
	}
	method cross-tabulation-single-formula($/) {
		if $<values-variable-name> {
			make '(function(x) as.data.frame(xtabs( formula = ' ~ $<values-variable-name>.made ~ ' ~ ' ~ $<rows-variable-name>.made ~ ', data = x ), stringsAsFactors=FALSE ))';
		} else {
			make '(function(x) as.data.frame(xtabs( formula = ~ ' ~ $<rows-variable-name>.made ~ ', data = x ), stringsAsFactors=FALSE ))';
		}
	}
	method rows-variable-name($/) { make $/.values[0].made.subst(:g, '"', ''); }
	method columns-variable-name($/) { make $/.values[0].made.subst(:g, '"', ''); }
	method values-variable-name($/) { make $/.values[0].made.subst(:g, '"', ''); }

	# Reshape command
	method reshape-command($/) { make $/.values[0].made; }

	# Pivot longer command
	method pivot-longer-command($/) {
		if $<pivot-longer-arguments-list> {
			make 'tidyr::pivot_longer( ' ~ $<pivot-longer-arguments-list>.made ~ ' )';
		} else {
			make 'dplyr::mutate_all(.funs = as.character) %>% tidyr::pivot_longer( cols = dplyr::everything(), names_to = "Variable", values_to = "Value")';
		}
	}
	method pivot-longer-arguments-list($/) { make $<pivot-longer-argument>>>.made.join(', '); }
	method pivot-longer-argument($/) { make $/.values[0].made; }

	method pivot-longer-id-columns-spec($/) {
		warn 'The R-tidyverse function tidyr::pivot_longer does not use identifier columns.';
		make '';
	}

	method pivot-longer-columns-spec($/) { make 'cols = c( ' ~ $/.values[0].made ~ ' )'; }

	method pivot-longer-variable-column-name-spec($/) { make 'names_to = ' ~ $/.values[0].made; }

	method pivot-longer-value-column-name-spec($/) { make 'values_to = ' ~ $/.values[0].made; }

	# Pivot wider command
	method pivot-wider-command($/) { make 'tidyr::pivot_wider(' ~ $<pivot-wider-arguments-list>.made ~ ' )'; }
	method pivot-wider-arguments-list($/) { make $<pivot-wider-argument>>>.made.join(', '); }
	method pivot-wider-argument($/) { make $/.values[0].made; }

	method pivot-wider-id-columns-spec($/) { make 'id_cols = c( ' ~ $/.values[0].made ~ ' )'; }

	method pivot-wider-variable-column-spec($/) { make 'names_from = ' ~ $/.values[0].made; }

	method pivot-wider-value-column-spec($/) { make 'values_from = ' ~ $/.values[0].made; }

	# Separate string column command
	method separate-column-command($/) {
		my $intocols = map( { '"' ~ $_.subst(:g, '"', '') ~ '"' }, $<into>.made.split(', ') ).join(', ');
		if $<sep> {
			make 'tidyr::separate( col = ' ~ $<col>.made ~ ', into = c(' ~ $intocols ~ '), sep = ' ~ $<sep>.made ~ ' )';
		} else {
			make 'tidyr::separate( col = ' ~ $<col>.made ~ ', into = c(' ~ $intocols ~ ') )';
		}
	}
	method separator-spec($/) { make $/.values[0].made; }

	# Make dictionary command
	method make-dictionary-command($/) { make 'SELECT ' ~ $<keycol>.made ~', ' ~ $<valcol>.made ~ ' )';}

	# Probably have to be in DSL::Shared::Actions .
	# Assign-pairs and as-pairs
	method assign-pairs-list($/) { make $<assign-pair>>>.made.join(', '); }
	method as-pairs-list($/)     { make $<as-pair>>>.made.join(', '); }
	method assign-pair($/) { make $<assign-pair-lhs>.made ~ ' = ' ~ $<assign-pair-rhs>.made; }
	method as-pair($/)     { make $<assign-pair-lhs>.made ~ ' = ' ~ $<assign-pair-rhs>.made; }
	method assign-pair-lhs($/) { make $/.values[0].made.subst(:g, '"', ''); }
	method assign-pair-rhs($/) {
		if $<mixed-quoted-variable-name> {
			make $/.values[0].made.subst(:g, '"', '');
		} else {
			make $/.values[0].made
		}
	}

	# Correspondence pairs
	method key-pairs-list($/) { make $<key-pair>>>.made.join(', '); }
	method key-pair($/) { make $<key-pair-lhs>.made ~ ' = ' ~ $<key-pair-rhs>.made; }
	method key-pair-lhs($/) { make '"' ~ $/.values[0].made.subst(:g, '"', '') ~ '"'; }
	method key-pair-rhs($/) { make '"' ~ $/.values[0].made.subst(:g, '"', '') ~ '"'; }

	# Pipeline command
	## Object
	method assign-pipeline-object-to($/) { make '(function(x) { assign( x = "' ~ $/.values[0].made ~ '", value = x, envir = .GlobalEnv ); x })'; }

	## Value
	method assign-pipeline-value-to($/) { make self.assign-pipeline-object-to($/); }
	method pipeline-command($/) { make $/.values[0].made; }
	method take-pipeline-value($/) { make 'as.data.frame()'; }
	method echo-pipeline-value($/) { make '(function(x) { print(x); x})'; }

	method echo-command($/) { make '(function(x){ print( ' ~ $<echo-message-spec>.made ~ ' ); x })'; }
	method echo-message-spec($/) { make $/.values[0].made; }
	method echo-words-list($/) { make '"' ~ $<variable-name>>>.made.join(' ') ~ '"'; }
	method echo-variable($/) { make $/.Str; }
	method echo-text($/) { make $/.Str; }

	## Setup code
	method setup-code-command($/) { make 'SETUPCODE' => ''; }
}
