=begin comment
#==============================================================================
#
#   Data Query Workflows Bulgarian DSL actions in Raku (Perl 6)
#   Copyright (C) 2020  Anton Antonov
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#   Written by Anton Antonov,
#   antononcube @ gmai l . c om,
#   Windermere, Florida, USA.
#
#==============================================================================
#
#   For more details about Raku (Perl6) see https://raku.org/ .
#
#==============================================================================
=end comment

use v6;
use DSL::English::DataQueryWorkflows::Grammar;
use DSL::English::DataQueryWorkflows::Actions::Bulgarian::Predicate;
use DSL::Shared::Actions::English::PipelineCommand;

unit module DSL::English::DataQueryWorkflows::Actions::Bulgarian::Standard;

class DSL::English::DataQueryWorkflows::Actions::Bulgarian::Standard
		is DSL::Shared::Actions::English::PipelineCommand
        is DSL::English::DataQueryWorkflows::Actions::Bulgarian::Predicate {

	has Str $.name = 'DSL-English-DataQueryWorkflows-Bulgarian-Standard';

    method TOP($/) { make $/.values[0].made; }

	# General
	method variable-names-list($/) { make $<variable-name>>>.made.join(', '); }
	method quoted-variable-names-list($/) { make $<quoted-variable-name>>>.made.join(', '); }
	method mixed-quoted-variable-names-list($/) { make $<mixed-quoted-variable-name>>>.made.join(', '); }

	# Column specs
    method column-specs-list($/) { make $<column-spec>>>.made.join(', '); }
    method column-spec($/) {  make $/.values[0].made; }
    method column-name-spec($/) { make '"' ~ $<mixed-quoted-variable-name>.made.subst(:g, '"', '') ~ '"'; }

	# Load data
	method data-load-command($/) { make $/.values[0].made; }
	method load-data-table($/) { make 'зареди таблицата: ' ~ $<data-location-spec>.made; }
	method data-location-spec($/) { make '\"' ~ $/.Str ~ '\"'; }
	method use-data-table($/) { make 'използвай таблицата: ' ~ $<variable-name>.made; }

	# Distinct command
	method distinct-command($/) { make $/.values[0].made; }
	method distinct-simple-command($/) { make 'уникални редове'; }

	# Missing treatment command
	method missing-treatment-command($/) { make $/.values[0].made; }
	method drop-incomplete-cases-command($/) { make 'премахни непълни редове'; }
	method replace-missing-command($/) { make 'замести липсващи стойности с ' ~ $<replace-missing-rhs>.made; }
    method replace-missing-rhs($/) { make $/.values[0].made; }

	# Select command
	method select-command($/) { make $/.values[0].made; }
	method select-columns-simple($/) { make 'избери колоните: ' ~ $/.values[0].made; }
	method select-columns-by-two-lists($/) { make 'избери колоните ' ~ $<current>.made ~ ' и преименувай като ' ~ $<new>.made; }
    method select-columns-by-pairs($/) { make 'преименувай и избери колоните с ' ~ $/.values[0].made; }

	# Filter commands
	method filter-command($/) { make 'филтрирай с предиката: ' ~ $<filter-spec>.made; }
	method filter-spec($/) { make $<predicates-list>.made; }

	# Mutate command
	method mutate-command($/) { make $/.values[0].made; }
	method mutate-by-two-lists($/) { make 'присвои колоните ' ~ $<current>.made ~ ' на ' ~ $<new>.made; }
	method mutate-by-pairs($/) { make 'присвои: ' ~ $/.values[0].made; }

    # Group command
    method group-command($/) { make $/.values[0].made; }
	method group-by-command($/) { make 'групирай с колоните: ' ~ $/.values[0]; }
	method group-map-command($/) { make 'приложи към всяка група: ' ~ $/.values[0].made; }

	# Ungroup command
	method ungroup-command($/) { make $/.values[0].made; }
	method ungroup-simple-command($/) { make 'раз-групирай'; }

	# Arrange command
	method arrange-command($/) { make $/.values[0].made; }
	method arrange-simple-command($/) {
        make $<reverse-sort-phrase> || $<descending> ?? 'сортирай в низходящ ред' !! 'сортирай';
    }
	method arrange-by-spec($/) { make $/.values[0].made; }
	method arrange-by-command-ascending($/) { make 'сортирай с колоните: ' ~ $<arrange-by-spec>.made; }
	method arrange-by-command-descending($/) { make 'сортирай в низходящ ред с колоните: ' ~ $<arrange-by-spec>.made; }

    # Rename columns command
    method rename-columns-command($/) { make $/.values[0].made; }
    method rename-columns-by-two-lists($/) {
        make 'преименувай колоните ' ~ $<current>.made ~ ' като ' ~ $<new>.made;
    }
    method rename-columns-by-pairs($/) { make 'преименувай колоните с ' ~ $/.values[0].made; }

    # Drop columns command
    method drop-columns-command($/) { make $/.values[0].made; }
    method drop-columns-simple($/) {
        make 'премахни колоните ' ~ $<todrop>.made;
    }

	# Statistics command
	method statistics-command($/) { make $/.values[0].made; }
	method data-dimensions-command($/) { make 'покажи размерите'; }
	method count-command($/) { make 'намери размера на под-групите'; }
	method data-summary-command($/) { make 'опиши обекта'; }
	method glimpse-data($/) { make 'покажи визия на обекта'; }
	method summarize-all-command($/) {
		if $<summarize-funcs-spec> {
			make 'приложи по всички колони функцийте: ' ~ $<summarize-funcs-spec>.made;
		} else {
			make 'намери средните стойности на всички колони';
		}
	}
	method summarize-at-command($/) { make 'сумаризирай колоните: ' ~ $<cols>.made ~ ' с функциите: ' ~ $<summarize-funcs-spec>.made; }
	method summarize-funcs-spec($/) { make $<variable-name-or-wl-expr-list>.made.join(', '); }

	# Join command
	method join-command($/) { make $/.values[0].made; }

	method join-by-spec($/) { make '(' ~ $/.values[0].made ~ ')'; }

	method full-join-spec($/)  {
		if $<join-by-spec> {
			make 'външно съединение с ' ~ $<dataset-name>.made ~ ' според ' ~ $<join-by-spec>.made ~ ')';
		} else {
			make 'външно съединение с ' ~ $<dataset-name>.made ~ ')';
		}
	}

	method inner-join-spec($/)  {
		if $<join-by-spec> {
			make 'вътрешно съединение с ' ~ $<dataset-name>.made ~ ' според ' ~ $<join-by-spec>.made ~ ')';
		} else {
			make 'вътрешно съединение с ' ~ $<dataset-name>.made ~ ')';
		}
	}

	method left-join-spec($/)  {
		if $<join-by-spec> {
			make 'ляво съединение с ' ~ $<dataset-name>.made ~ ' според ' ~ $<join-by-spec>.made ~ ')';
		} else {
			make 'ляво съединение с ' ~ $<dataset-name>.made ~ ')';
		}
	}

	method right-join-spec($/)  {
		if $<join-by-spec> {
			make 'дясно съединение с ' ~ $<dataset-name>.made ~ ' според ' ~ $<join-by-spec>.made ~ ')';
		} else {
			make 'дясно съединение с ' ~ $<dataset-name>.made ~ ')';
		}
	}

	method semi-join-spec($/)  {
		if $<join-by-spec> {
			make 'полу-съединение с ' ~ $<dataset-name>.made ~ ' според ' ~ $<join-by-spec>.made ~ ')';
		} else {
			make 'полу-съединение с ' ~ $<dataset-name>.made ~ ')';
		}
	}

	# Cross tabulate command
	method cross-tabulation-command($/) { make $/.values[0].made; }
	method cross-tabulate-command($/) { $<cross-tabulation-formula>.made }
	method contingency-matrix-command($/) { $<cross-tabulation-formula>.made }
	method cross-tabulation-formula($/) { make $/.values[0].made; }
	method cross-tabulation-double-formula($/) {
		if $<values-variable-name> {
			make 'направи кръстосана таблица с редове от ' ~ $<rows-variable-name>.made ~ ', колони от ' ~ $<columns-variable-name>.made ~ ' и стойности от ' ~ $<values-variable-name>;
		} else {
			make 'направи кръстосана таблица с редове от ' ~ $<rows-variable-name>.made ~ ', колони от ' ~ $<columns-variable-name>.made;
		}
	}
	method cross-tabulation-single-formula($/) {
		if $<values-variable-name> {
			make 'направи кръстосана таблица с редове от ' ~ $<rows-variable-name>.made ~ ' и стойности от ' ~ $<values-variable-name>;
		} else {
			make 'направи кръстосана таблица с редове от ' ~ $<rows-variable-name>.made;
		}
	}
    method rows-variable-name($/) { make $/.values[0].made; }
    method columns-variable-name($/) { make $/.values[0].made; }
    method values-variable-name($/) { make $/.values[0].made; }

	# Reshape command
    method reshape-command($/) { make $/.values[0].made; }

	# Pivot longer command
    method pivot-longer-command($/) {
		if  $<pivot-longer-arguments-list> {
			make 'преобразувай в тясна форма ' ~ $<pivot-longer-arguments-list>.made;
		} else {
			make 'преобразувай в тясна форма';
		}
	}
    method pivot-longer-arguments-list($/) { make $<pivot-longer-argument>>>.made.join(', '); }
    method pivot-longer-argument($/) { make $/.values[0].made; }

    method pivot-longer-id-columns-spec($/) { make 'id колоните ' ~ $/.values[0].made; }

    method pivot-longer-columns-spec($/) { make 'колоните ' ~ $/.values[0].made; }

    method pivot-longer-variable-column-name-spec($/) { make 'променлива колона ' ~ $/.values[0].made; }

    method pivot-longer-value-column-name-spec($/) { make 'стойностна колона ' ~ $/.values[0].made; }

    # Pivot wider command
    method pivot-wider-command($/) { make 'преобразувай я широка форма ' ~ $<pivot-wider-arguments-list>.made; }
    method pivot-wider-arguments-list($/) { make $<pivot-wider-argument>>>.made.join(', '); }
    method pivot-wider-argument($/) { make $/.values[0].made; }

    method pivot-wider-id-columns-spec($/) { make 'идентификаторни колони ' ~ $/.values[0].made; }

    method pivot-wider-variable-column-spec($/) { make 'променлива колона ' ~ $/.values[0].made; }

    method pivot-wider-value-column-spec($/) { make 'стойностна колона ' ~ $/.values[0].made; }

	# Make dictionary command
    method make-dictionary-command($/) { make 'направи речник от колона '  ~ $<keycol>.made ~' към колона ' ~ $<valcol>.made;}

    # Probably have to be in DSL::Shared::Actions .
    # Assign-pairs and as-pairs
	method assign-pairs-list($/) { make $<assign-pair>>>.made.join(', '); }
	method as-pairs-list($/)     { make $<as-pair>>>.made.join(', '); }
	method assign-pair($/) { make $<assign-pair-lhs>.made ~ ' = ' ~ $<assign-pair-rhs>.made; }
	method as-pair($/)     { make $<assign-pair-lhs>.made ~ ' = ' ~ $<assign-pair-rhs>.made; }
	method assign-pair-lhs($/) { make $/.values[0].made; }
	method assign-pair-rhs($/) {
        if $<mixed-quoted-variable-name> {
            make '"' ~ $/.values[0].made.subst(:g, '"', '') ~ '"';
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
    method pipeline-command($/) { make $/.values[0].made; }
    method take-pipeline-value($/) { make 'вземи обекта'; }
    method echo-pipeline-value($/) { make 'ехо на поточната стойност'; }

    method echo-command($/) { make 'отпечатай съобщението: ' ~ $<echo-message-spec>.made; }
    method echo-message-spec($/) { make $/.values[0].made; }
    method echo-words-list($/) { make '"' ~ $<variable-name>>>.made.join(' ') ~ '"'; }
    method echo-variable($/) { make $/.Str; }
    method echo-text($/) { make $/.Str; }
}
