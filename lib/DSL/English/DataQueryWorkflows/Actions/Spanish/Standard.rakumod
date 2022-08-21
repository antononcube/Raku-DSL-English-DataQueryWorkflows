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
use DSL::English::DataQueryWorkflows::Actions::Spanish::Predicate;
use DSL::Shared::Actions::English::PipelineCommand;
use DSL::Shared::Actions::Spanish::Standard::ListManagementCommand;
use DSL::Shared::Actions::Spanish::Standard::PipelineCommand;

class DSL::English::DataQueryWorkflows::Actions::Spanish::Standard
		does DSL::Shared::Actions::Spanish::Standard::ListManagementCommand
		does DSL::Shared::Actions::Spanish::Standard::PipelineCommand
		is DSL::Shared::Actions::English::PipelineCommand
        is DSL::English::DataQueryWorkflows::Actions::Spanish::Predicate {

	has Str $.name = 'DSL-English-DataQueryWorkflows-Spanish-Standard';

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
	method load-data-table($/) { make 'cargar la tabla: ' ~ $<data-location-spec>.made; }
	method data-location-spec($/) {
		make $<regex-pattern-spec> ?? $<regex-pattern-spec>.made !! '"' ~ self.unquote($/.Str) ~ '"';
	}
	method use-data-table($/) { make 'utilizar la tabla: ' ~ $<mixed-quoted-variable-name>.made; }

	# Distinct command
	method distinct-command($/) { make $/.values[0].made; }
	method distinct-simple-command($/) { make 'filas únicas'; }

	# Missing treatment command
	method missing-treatment-command($/) { make $/.values[0].made; }
	method drop-incomplete-cases-command($/) { make 'eliminar las filas incompletas'; }
	method replace-missing-command($/) {
		my $na = $<replace-missing-rhs> ?? $<replace-missing-rhs>.made !! '"NA"';
		make 'reemplazar los valores perdidos con ' ~ $na;
	}
    method replace-missing-rhs($/) { make $/.values[0].made; }

	# Replace command
    method replace-command($/) { make 'reemplazar ' ~ $<lhs>.made ~ ' con ' ~ $<rhs>.made ; }

	# Select command
	method select-command($/) { make $/.values[0].made; }
	method select-columns-simple($/) { make 'escoger columnas: '  ~ $/.values[0].made; }
	method select-columns-by-two-lists($/) { make 'seleccione las columnas ' ~ $<current>.made ~ ' y cambie el nombre a ' ~ $<new>.made; }
    method select-columns-by-pairs($/) { make 'cambiar el nombre y seleccionar las columnas ' ~ $/.values[0].made; }

	# Filter commands
	method filter-command($/) { make 'filtrar con la condicion: ' ~ $<filter-spec>.made; }
	method filter-spec($/) { make $<predicates-list>.made; }

	# Mutate command
	method mutate-command($/) { make $/.values[0].made; }
	method mutate-by-two-lists($/) { 'asignar las columnas ' ~ $<current>.made ~ ' a ' ~ $<new>.made;}
	method mutate-by-pairs($/) { make 'apropiado: ' ~  $/.values[0].made; }

    # Group command
    method group-command($/) { make $/.values[0].made; }
	method group-by-command($/) { make 'agrupar con columnas: ' ~ $/.values[0].made; }
	method group-map-command($/) { make 'aplicar a cada grupo: ' ~ $/.values[0].made; }

	# Ungroup command
	method ungroup-command($/) { make $/.values[0].made; }
	method ungroup-simple-command($/) { make 'desagrupar'; }

	# Arrange command
	method arrange-command($/) { make $/.values[0].made; }
	method arrange-simple-command($/) {
        make $<reverse-sort-phrase> || $<descending-phrase> ?? 'orden descendente' !! 'ordenar';
    }
	method arrange-by-spec($/) { make $/.values[0].made; }
	method arrange-by-command-ascending($/) { make 'ordenar con columnas: ' ~ $<arrange-by-spec>.made; }
	method arrange-by-command-descending($/) { make 'ordenar en orden descendente con columnas: ' ~ $<arrange-by-spec>.made; }

	# Rename columns command
    method rename-columns-command($/) { make $/.values[0].made; }
    method rename-columns-by-two-lists($/) {
        make 'renombrar las columnas ' ~ $<current>.made ~ ' como ' ~ $<new>.made;
    }
    method rename-columns-by-pairs($/) { make 'renombrar las columnas con ' ~ $/.values[0].made; }

    # Drop columns command
    method drop-columns-command($/) { make $/.values[0].made; }
    method drop-columns-simple($/) {
        make 'quitar las columnas ' ~ $<todrop>.made;
    }

	# Statistics command
	method statistics-command($/) { make $/.values[0].made; }
	method data-dimensions-command($/) { make 'mostrar dimensiones'; }
	method count-command($/) { make 'encontrar recuentos'; }
	method echo-count-command($/) { make 'mostrar recuentos'; }
	method data-summary-command($/) { make 'describe el objeto'; }
	method glimpse-data($/) { make 'vislumbrar el objeto'; }
	method column-names-command($/) { make 'mostrar los nombres de las columnas'; }
	method row-names-command($/) { make 'mostrar nombres de líneas'; }

	# Summarize command
    method summarize-command($/) { make $/.values[0].made; }
	method summarize-by-pairs($/) { make 'resumir con las columnas: ' ~ $/.values[0].made; }
	method summarize-all-command($/) {
		if $<summarize-funcs-spec> {
			make 'aplicar sobre todas las columnas las funciones: ' ~ $<summarize-funcs-spec>.made;
		} else {
			make 'encontrar los promedios de todas las columnas';
		}
	}
	method summarize-at-command($/) { make 'resumir las columnas: ' ~ $<cols>.made ~ ' con las funciones: ' ~ $<summarize-funcs-spec>.made; }
    method summarize-funcs-spec($/) { make $<variable-name-or-wl-expr-list>.made.join(', '); }

	# Join command
	method join-command($/) { make $/.values[0].made; }

	method join-by-spec($/) { make '(' ~ $/.values[0].made ~ ')'; }

	method full-join-spec($/)  {
		if $<join-by-spec> {
			make 'externamente compuesto con ' ~ $<dataset-name>.made ~ ' de acuerdo a ' ~ $<join-by-spec>.made;
		} else {
			make 'externamente compuesto con ' ~ $<dataset-name>.made;
		}
	}

	method inner-join-spec($/)  {
		if $<join-by-spec> {
			make 'internamente compuesto con ' ~ $<dataset-name>.made ~ ' de acuerdo a ' ~ $<join-by-spec>.made;
		} else {
			make 'internamente compuesto con ' ~ $<dataset-name>.made;
		}
	}

	method left-join-spec($/)  {
		if $<join-by-spec> {
			make 'izquierda compuesto con ' ~ $<dataset-name>.made ~ ' de acuerdo a ' ~ $<join-by-spec>.made;
		} else {
			make 'izquierda compuesto con ' ~ $<dataset-name>.made;
		}
	}

	method right-join-spec($/)  {
		if $<join-by-spec> {
			make 'derecha compuesto con ' ~ $<dataset-name>.made ~ ' de acuerdo a ' ~ $<join-by-spec>.made;
		} else {
			make 'derecha compuesto con ' ~ $<dataset-name>.made;
		}
	}

	method semi-join-spec($/)  {
		if $<join-by-spec> {
			make 'semi-compuesto con ' ~ $<dataset-name>.made ~ ' de acuerdo a ' ~ $<join-by-spec>.made;
		} else {
			make 'semi-compuesto con ' ~ $<dataset-name>.made;
		}
	}

	# Cross tabulate command
	method cross-tabulation-command($/) { make $/.values[0].made; }
	method cross-tabulate-command($/) { $<cross-tabulation-formula>.made }
	method contingency-matrix-command($/) { $<cross-tabulation-formula>.made }
	method cross-tabulation-formula($/) { make $/.values[0].made; }
	method cross-tabulation-double-formula($/) {
		if $<values-variable-name> {
			make 'hacer una tabla cruzada con filas de ' ~ $<rows-variable-name>.made ~ ', columnas de ' ~ $<columns-variable-name>.made ~ ' y valores de ' ~ $<values-variable-name>;
		} else {
			make 'hacer una tabla cruzada con filas de ' ~ $<rows-variable-name>.made ~ ', columnas de ' ~ $<columns-variable-name>.made;
		}
	}
	method cross-tabulation-single-formula($/) {
		if $<values-variable-name> {
			make 'hacer una tabla cruzada con filas de ' ~ $<rows-variable-name>.made ~ ' y valores de ' ~ $<values-variable-name>;
		} else {
			make 'hacer una tabla cruzada con filas de ' ~ $<rows-variable-name>.made;
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
			make 'convertir a formato largo con ' ~ $<pivot-longer-arguments-list>.made;
		} else {
			make 'convertir a formato largo';
		}
	}
    method pivot-longer-arguments-list($/) { make $<pivot-longer-argument>>>.made.join(', '); }
    method pivot-longer-argument($/) { make $/.values[0].made; }

	method pivot-longer-id-columns-spec($/) { make 'columnas ' ~ $/.values[0].made; }

    method pivot-longer-columns-spec($/) { make 'columnas ' ~ $/.values[0].made; }

    method pivot-longer-variable-column-name-spec($/) { make 'colonna variabile ' ~ $/.values[0].made; }

    method pivot-longer-value-column-name-spec($/) { make 'colonna dei valori ' ~ $/.values[0].made; }

    # Pivot wider command
    method pivot-wider-command($/) { make 'convertire in forma ampia ' ~ $<pivot-wider-arguments-list>.made; }
    method pivot-wider-arguments-list($/) { make $<pivot-wider-argument>>>.made.join(', '); }
    method pivot-wider-argument($/) { make $/.values[0].made; }

    method pivot-wider-id-columns-spec($/) { make 'colonne identificative ' ~$/.values[0].made; }

    method pivot-wider-variable-column-spec($/) { make 'colonna variabile ' ~ $/.values[0].made; }

    method pivot-wider-value-column-spec($/) { make 'colonna dei valori ' ~ $/.values[0].made; }

	# Separate string column command
	method separate-column-command($/) {
		my $intocols = map( { '"' ~ $_.subst(:g, '"', '') ~ '"' }, $<into>.made.split(', ') ).join(', ');
		make 'dividir los valores de la columna de cadena ' ~ $<col>.made ~ ' en las columnas ' ~ $intocols;
	}
	method separator-spec($/) { make $/.values[0].made; }

	# Make dictionary command
    method make-dictionary-command($/) { make 'hacer que el diccionario mapee la columna ' ~ $<keycol>.made ~ ' a la columna ' ~ $<valcol>.made; }

	# Pull column command
	method pull-column-command($/) { make 'extraer los valores de la columna ' ~ $<column-name-spec>.made; }

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
    method take-pipeline-value($/) { make 'toma el objeto'; }
    method echo-pipeline-value($/) { make 'valor de la tubería de eco'; }

    method echo-command($/) { make 'mensaje impreso: ' ~ $<echo-message-spec>.made; }
    method echo-message-spec($/) { make $/.values[0].made; }
    method echo-words-list($/) { make '"' ~ $<variable-name>>>.made.join(' ') ~ '"'; }
    method echo-variable($/) { make $/.Str; }
    method echo-text($/) { make $/.Str; }
}
