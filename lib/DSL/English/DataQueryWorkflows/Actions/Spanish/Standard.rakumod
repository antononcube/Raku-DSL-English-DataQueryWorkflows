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
use DSL::English::DataQueryWorkflows::Actions::Spanish::Predicate;

unit module DSL::English::DataQueryWorkflows::Actions::Spanish::Standard;

class DSL::English::DataQueryWorkflows::Actions::Spanish::Standard
        is DSL::English::DataQueryWorkflows::Actions::Spanish::Predicate {

    method TOP($/) { make $/.values[0].made; }

	# General
	method dataset-name($/) { make $/.Str; }
	method variable-name($/) { make $/.Str; }
	method list-separator($/) { make ','; }
	method variable-names-list($/) { make $<variable-name>>>.made.join(', '); }
	method quoted-variable-names-list($/) { make $<quoted-variable-name>>>.made.join(', '); }
	method mixed-quoted-variable-names-list($/) { make $<mixed-quoted-variable-name>>>.made.join(', '); }
	method integer-value($/) { make $/.Str; }
	method number-value($/) { make $/.Str; }
	method wl-expr($/) { make $/.Str.substr(1,*-1); }
	method quoted-variable-name($/) { make $/.values[0].made; }
	method mixed-quoted-variable-name($/) { make $/.values[0].made; }
	method single-quoted-variable-name($/) { make '"' ~ $<variable-name>.made ~ '"'; }
	method double-quoted-variable-name($/) { make '"' ~ $<variable-name>.made ~ '"'; }

	# Trivial
	method trivial-parameter($/) { make $/.values[0].made; }
	method trivial-parameter-none($/) { make 'missing'; }
	method trivial-parameter-empty($/) { make '[]'; }
	method trivial-parameter-automatic($/) { make 'Null'; }
	method trivial-parameter-false($/) { make 'false'; }
	method trivial-parameter-true($/) { make 'true'; }

	# Load data
	method data-load-command($/) { make $/.values[0].made; }
	method load-data-table($/) { make 'cargar la tabla: ' ~ $<data-location-spec>.made; }
	method data-location-spec($/) { make '\"' ~ $/.Str ~ '\"'; }
	method use-data-table($/) { make 'utilizar la tabla: ' ~ $<variable-name>.made; }

	# Distinct command
	method distinct-command($/) { make $/.values[0].made; }
	method distinct-simple-command($/) { make 'filas únicas'; }

	# Missing treatment command
	method missing-treatment-command($/) { make $/.values[0].made; }
	method drop-incomplete-cases-command($/) { make 'eliminar las filas incompletas'; }
	method replace-missing-command($/) { make 'reemplazar los valores perdidos con ' ~ $<replace-missing-rhs>.made; }

	# Select command
	method select-command($/) { make 'escoger columnas: ' ~ $/.values[0].made; }
	method select-plain-variables($/) { make $<variable-names-list>.made; }
	method select-mixed-quoted-variables($/) { make $<mixed-quoted-variable-names-list>.made; }

	# Filter commands
	method filter-command($/) { make 'filtrar con la condicion: ' ~ $<filter-spec>.made; }
	method filter-spec($/) { make $<predicates-list>.made; }

	# Mutate command
	method mutate-command($/) { make 'apropiado: ' ~ $<assign-pairs-list>.made; }
	method assign-pairs-list($/) { make $<assign-pair>>>.made.join(', '); }
	method assign-pair($/) { make $<assign-pair-lhs>.made ~ ' = ' ~ $<assign-pair-rhs>.made; }
	method assign-pair-lhs($/) { make $/.values[0].made; }
	method assign-pair-rhs($/) { make $/.values[0].made; }

	# Group command
	method group-command($/) { make 'agrupar con columnas: ' ~ $<variable-names-list>.made; }

	# Ungroup command
	method ungroup-command($/) { make $/.values[0].made; }
	method ungroup-simple-command($/) { make 'desagrupar'; }

	# Arrange command
	method arrange-command($/) { make $/.values[0].made; }
	method arrange-simple-spec($/) { make $<mixed-quoted-variable-names-list>.made; }
	method arrange-command-ascending($/) { make 'ordenar con columnas: ' ~ $<arrange-simple-spec>.made; }
	method arrange-command-descending($/) { make 'ordenar en orden descendente con columnas: ' ~ $<arrange-simple-spec>.made; }

	# Statistics command
	method statistics-command($/) { make $/.values[0].made; }
	method count-command($/) { make 'encontrar el tamaño de los subgrupos'; }
	method summarize-data($/) { make 'describe el objeto'; }
	method glimpse-data($/) { make 'vislumbrar el objeto'; }
	method summarize-all-command($/) { make 'encontrar los promedios de todas las columnas'; }

	# Join command
	method join-command($/) { make $/.values[0].made; }

	method join-by-spec($/) { make 'c(' ~ $/.values[0].made ~ ')'; }

	method full-join-spec($/)  {
		if $<join-by-spec> {
			make 'externamente compuesto con ' ~ $<dataset-name>.made ~ ' de acuerdo a ' ~ $<join-by-spec>.made ~ ')';
		} else {
			make 'externamente compuesto con ' ~ $<dataset-name>.made ~ ')';
		}
	}

	method inner-join-spec($/)  {
		if $<join-by-spec> {
			make 'internamente compuesto con ' ~ $<dataset-name>.made ~ ' de acuerdo a ' ~ $<join-by-spec>.made ~ ')';
		} else {
			make 'internamente compuesto con ' ~ $<dataset-name>.made ~ ')';
		}
	}

	method left-join-spec($/)  {
		if $<join-by-spec> {
			make 'izquierda compuesto con ' ~ $<dataset-name>.made ~ ' de acuerdo a ' ~ $<join-by-spec>.made ~ ')';
		} else {
			make 'izquierda compuesto con ' ~ $<dataset-name>.made ~ ')';
		}
	}

	method right-join-spec($/)  {
		if $<join-by-spec> {
			make 'derecha compuesto con ' ~ $<dataset-name>.made ~ ' de acuerdo a ' ~ $<join-by-spec>.made ~ ')';
		} else {
			make 'derecha compuesto con ' ~ $<dataset-name>.made ~ ')';
		}
	}

	method semi-join-spec($/)  {
		if $<join-by-spec> {
			make 'semi-compuesto con ' ~ $<dataset-name>.made ~ ' de acuerdo a ' ~ $<join-by-spec>.made ~ ')';
		} else {
			make 'semi-compuesto con ' ~ $<dataset-name>.made ~ ')';
		}
	}

	# Cross tabulate command
	method cross-tabulation-command($/) { make $/.values[0].made; }
	method cross-tabulate-command($/) { $<cross-tabulation-formula>.made }
	method contingency-matrix-command($/) { $<cross-tabulation-formula>.made }
	method cross-tabulation-formula($/) {
		if $<values-variable-name> {
			make 'hacer una tabla cruzada con filas de ' ~ $<rows-variable-name>.made ~ ', columnas de ' ~ $<columns-variable-name>.made ~ ' y valores de ' ~ $<values-variable-name>;
		} else {
			make 'hacer una tabla cruzada con filas de  ' ~ $<rows-variable-name>.made ~ ', columnas de ' ~ $<columns-variable-name>.made;
		}
	}
	method rows-variable-name($/) { make $<variable-name>.made; }
	method columns-variable-name($/) { make $<variable-name>.made; }
	method values-variable-name($/) { make $<variable-name>.made; }

	# Reshape command
    method reshape-command($/) { make $/.values[0].made; }

	# Pivot longer command
    method pivot-longer-command($/) { make 'convertir a la forma estrecha ' ~ $<pivot-longer-arguments-list>.made; }
    method pivot-longer-arguments-list($/) { make $<pivot-longer-argument>>>.made.join(', '); }
    method pivot-longer-argument($/) { make $/.values[0].made; }

    method pivot-longer-columns-spec($/) { make 'columnas ' ~ $<mixed-quoted-variable-names-list>.made; }

    method pivot-longer-variable-column-spec($/) { make 'colonna variabile ' ~ $<quoted-variable-name>.made; }

    method pivot-longer-value-column-spec($/) { make 'colonna dei valori ' ~ $<quoted-variable-name>.made; }

    # Pivot wider command
    method pivot-wider-command($/) { make 'convertire in forma ampia ' ~ $<pivot-wider-arguments-list>.made; }
    method pivot-wider-arguments-list($/) { make $<pivot-wider-argument>>>.made.join(', '); }
    method pivot-wider-argument($/) { make $/.values[0].made; }

    method pivot-wider-id-columns-spec($/) { make 'colonne identificative ' ~ $<mixed-quoted-variable-names-list>.made ~ ' )'; }

    method pivot-wider-variable-column-spec($/) { make 'colonna variabile ' ~ $<quoted-variable-name>.made; }

    method pivot-wider-value-column-spec($/) { make 'colonna dei valori ' ~ $<quoted-variable-name>.made; }

    # Pipeline command
    method pipeline-command($/) { make $/.values[0].made; }
    method take-pipeline-value($/) { make 'toma el objeto'; }
    method echo-pipeline-value($/) { make 'valor de la tubería de eco'; }

    method echo-command($/) { make 'mensaje impreso: ' ~ $<echo-message-spec>.made; }
    method echo-message-spec($/) { make $/.values[0].made; }
    method echo-words-list($/) { make '"' ~ $<variable-name>>>.made.join(' ') ~ '"'; }
    method echo-variable($/) { make $/.Str; }
    method echo-text($/) { make $/.Str; }
}
