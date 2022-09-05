=begin comment
#==============================================================================
#
#   Data Query Workflows Russian DSL actions in Raku (Perl 6)
#   Copyright (C) 2022  Anton Antonov
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
#   ʇǝu˙oǝʇsod@ǝqnɔuouoʇuɐ,
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
use DSL::English::DataQueryWorkflows::Actions::Russian::Predicate;
use DSL::Shared::Actions::English::PipelineCommand;
use DSL::Shared::Actions::Russian::Standard::ListManagementCommand;
use DSL::Shared::Actions::Russian::Standard::PipelineCommand;

class DSL::English::DataQueryWorkflows::Actions::Russian::Standard
		does DSL::Shared::Actions::Russian::Standard::ListManagementCommand
		does DSL::Shared::Actions::Russian::Standard::PipelineCommand
		is DSL::Shared::Actions::English::PipelineCommand
        is DSL::English::DataQueryWorkflows::Actions::Russian::Predicate {

	has Str $.name = 'DSL-English-DataQueryWorkflows-Russian-Standard';

    # Top
    method TOP($/) { make $/.values[0].made; }

    # workflow-command-list
    method workflow-commands-list($/) { make $/.values>>.made.join(";\n"); }

    # workflow-command
    method workflow-command($/) { make $/.values[0].made; }

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
	method load-data-table($/) { make 'загрузить таблицу: ' ~ $<data-location-spec>.made; }
	method data-location-spec($/) {
		make $<regex-pattern-spec> ?? $<regex-pattern-spec>.made !! '"' ~ self.unquote($/.Str) ~ '"';
	}
	method use-data-table($/) { make 'использовать таблицу: ' ~ $<mixed-quoted-variable-name>.made; }

	# Distinct command
	method distinct-command($/) { make $/.values[0].made; }
	method distinct-simple-command($/) { make 'уникальные строки'; }

	# Missing treatment command
	method missing-treatment-command($/) { make $/.values[0].made; }
	method drop-incomplete-cases-command($/) { make 'удалить неполные строки'; }
	method replace-missing-command($/) {
		my $na = $<replace-missing-rhs> ?? $<replace-missing-rhs>.made !! '"NA"';
		make 'заменить отсутствующие значения на ' ~ $na;
	}
    method replace-missing-rhs($/) { make $/.values[0].made; }

	# Replace command
    method replace-command($/) { make 'заменить ' ~ $<lhs>.made ~ ' с ' ~ $<rhs>.made ; }

	# Select command
	method select-command($/) { make $/.values[0].made; }
	method select-columns-simple($/) { make 'выбрать столбцы: ' ~ $/.values[0].made; }
	method select-columns-by-two-lists($/) { make 'выбрать столбцы ' ~ $<current>.made ~ ' и переименовать как ' ~ $<new>.made; }
    method select-columns-by-pairs($/) { make 'преименувай и избери колоните с ' ~ $/.values[0].made; }

	# Filter commands
	method filter-command($/) { make 'фильтровать с предикатом: ' ~ $<filter-spec>.made; }
	method filter-spec($/) { make $<predicates-list>.made; }

	# Mutate command
	method mutate-command($/) { make $/.values[0].made; }
	method mutate-by-two-lists($/) { make 'присваивать столбцы ' ~ $<current>.made ~ ' на ' ~ $<new>.made; }
	method mutate-by-pairs($/) { make 'присваивать: ' ~ $/.values[0].made; }

    # Group command
    method group-command($/) { make $/.values[0].made; }
	method group-by-command($/) { make 'групировать с колонками: ' ~ $/.values[0]; }
	method group-map-command($/) { make 'применить к каждой группе: ' ~ $/.values[0].made; }

	# Ungroup command
	method ungroup-command($/) { make $/.values[0].made; }
	method ungroup-simple-command($/) { make 'раз-групировай'; }

	# Arrange command
	method arrange-command($/) { make $/.values[0].made; }
	method arrange-simple-command($/) {
        make $<reverse-sort-phrase> || $<descending-phrase> ?? 'сортировать в порядке убывания' !! 'сортировать';
    }
	method arrange-by-spec($/) { make $/.values[0].made; }
	method arrange-by-command-ascending($/) { make 'сортировать по столбцам: ' ~ $<arrange-by-spec>.made; }
	method arrange-by-command-descending($/) { make 'сортировать в порядке убывания по столбцам: ' ~ $<arrange-by-spec>.made; }

    # Rename columns command
    method rename-columns-command($/) { make $/.values[0].made; }
    method rename-columns-by-two-lists($/) {
        make 'переименовать столбцы ' ~ $<current>.made ~ ' как ' ~ $<new>.made;
    }
    method rename-columns-by-pairs($/) { make 'переименовать столбцы с ' ~ $/.values[0].made; }

    # Drop columns command
    method drop-columns-command($/) { make $/.values[0].made; }
    method drop-columns-simple($/) {
        make 'удалить столбцы ' ~ $<todrop>.made;
    }

	# Statistics command
	method statistics-command($/) { make $/.values[0].made; }
	method data-dimensions-command($/) { make 'показать размеры'; }
	method count-command($/) { make 'найти число'; }
	method echo-count-command($/) { make 'показать число'; }
	method data-summary-command($/) { make 'описать объект'; }
	method glimpse-data($/) { make 'показать видение объекта'; }
	method column-names-command($/) { make 'показать имена столбцов'; }
	method row-names-command($/) { make 'показать имена строк'; }

	# Summarize command
    method summarize-command($/) { make $/.values[0].made; }
	method summarize-by-pairs($/) { make 'обобщить по формулам: ' ~ $/.values[0].made; }
	method summarize-all-command($/) {
		if $<summarize-funcs-spec> {
			make 'применить ко всем столбцам функции: ' ~ $<summarize-funcs-spec>.made;
		} else {
			make 'найти средние значения всех столбцов';
		}
	}
	method summarize-at-command($/) { make 'подведите итоги по столбцам: ' ~ $<cols>.made ~ ' с функции: ' ~ $<summarize-funcs-spec>.made; }
	method summarize-funcs-spec($/) { make $<variable-name-or-wl-expr-list>.made.join(', '); }

	# Join command
	method join-command($/) { make $/.values[0].made; }

	method join-by-spec($/) { make '(' ~ $/.values[0].made ~ ')'; }

	method full-join-spec($/)  {
		if $<join-by-spec> {
			make 'внешнее соединение с ' ~ $<dataset-name>.made ~ ' согласно ' ~ $<join-by-spec>.made;
		} else {
			make 'внешнее соединение с ' ~ $<dataset-name>.made;
		}
	}

	method inner-join-spec($/)  {
		if $<join-by-spec> {
			make 'внутреннее соединение с ' ~ $<dataset-name>.made ~ ' согласно ' ~ $<join-by-spec>.made;
		} else {
			make 'внутреннее соединение с ' ~ $<dataset-name>.made;
		}
	}

	method left-join-spec($/)  {
		if $<join-by-spec> {
			make 'левое соединение с ' ~ $<dataset-name>.made ~ ' согласно ' ~ $<join-by-spec>.made;
		} else {
			make 'левое соединение с ' ~ $<dataset-name>.made;
		}
	}

	method right-join-spec($/)  {
		if $<join-by-spec> {
			make 'правое соединение с ' ~ $<dataset-name>.made ~ ' согласно ' ~ $<join-by-spec>.made;
		} else {
			make 'правое соединение с ' ~ $<dataset-name>.made;
		}
	}

	method semi-join-spec($/)  {
		if $<join-by-spec> {
			make 'полусоединение с ' ~ $<dataset-name>.made ~ ' согласно ' ~ $<join-by-spec>.made;
		} else {
			make 'полусоединение с ' ~ $<dataset-name>.made;
		}
	}

	# Cross tabulate command
	method cross-tabulation-command($/) { make $/.values[0].made; }
	method cross-tabulate-command($/) { $<cross-tabulation-formula>.made }
	method contingency-matrix-command($/) { $<cross-tabulation-formula>.made }
	method cross-tabulation-formula($/) { make $/.values[0].made; }
	method cross-tabulation-double-formula($/) {
		if $<values-variable-name> {
			make 'составить перекрестную таблицу со строками ' ~ $<rows-variable-name>.made ~ ', столбцами ' ~ $<columns-variable-name>.made ~ ' и значениями ' ~ $<values-variable-name>;
		} else {
			make 'составить перекрестную таблицу со строками ' ~ $<rows-variable-name>.made ~ ', столбцами ' ~ $<columns-variable-name>.made;
		}
	}
	method cross-tabulation-single-formula($/) {
		if $<values-variable-name> {
			make 'составить перекрестную таблицу со строками ' ~ $<rows-variable-name>.made ~ ' и значениями ' ~ $<values-variable-name>;
		} else {
			make 'составить перекрестную таблицу со строками ' ~ $<rows-variable-name>.made;
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
			make 'перевести в узкую форму ' ~ $<pivot-longer-arguments-list>.made;
		} else {
			make 'перевести в узкую форму';
		}
	}
    method pivot-longer-arguments-list($/) { make $<pivot-longer-argument>>>.made.join(', '); }
    method pivot-longer-argument($/) { make $/.values[0].made; }

    method pivot-longer-id-columns-spec($/) { make 'id столбцы ' ~ $/.values[0].made; }

    method pivot-longer-columns-spec($/) { make 'столбцы ' ~ $/.values[0].made; }

    method pivot-longer-variable-column-name-spec($/) { make 'переменная колонка ' ~ $/.values[0].made; }

    method pivot-longer-value-column-name-spec($/) { make 'стойностна колона ' ~ $/.values[0].made; }

    # Pivot wider command
    method pivot-wider-command($/) { make 'преобразувай я широка форма ' ~ $<pivot-wider-arguments-list>.made; }
    method pivot-wider-arguments-list($/) { make $<pivot-wider-argument>>>.made.join(', '); }
    method pivot-wider-argument($/) { make $/.values[0].made; }

    method pivot-wider-id-columns-spec($/) { make 'идентификаторни колони ' ~ $/.values[0].made; }

    method pivot-wider-variable-column-spec($/) { make 'променлива колона ' ~ $/.values[0].made; }

    method pivot-wider-value-column-spec($/) { make 'столбец значений ' ~ $/.values[0].made; }

	# Separate string column command
	method separate-column-command($/) {
		my $intocols = map( { '"' ~ $_.subst(:g, '"', '') ~ '"' }, $<into>.made.split(', ') ).join(', ');

		if $<sep> {
			make 'разделить значения столбца ' ~ $<col>.made ~ ' на столбцы ' ~ $intocols ~ ', с помощью разделителя ' ~ $<sep>.made;
		} else {
			make 'разделить значения столбца ' ~ $<col>.made ~ ' по столбцы ' ~ $intocols;
		}
	}
	method separator-spec($/) { make $/.values[0].made; }

	# Make dictionary command
    method make-dictionary-command($/) { make 'сделать словарь из столбца  '  ~ $<keycol>.made ~ '  в столбец ' ~ $<valcol>.made;}

	# Pull column command
	method pull-column-command($/) { make 'извлечь значения из столбца ' ~ $<column-name-spec>.made; }
}
