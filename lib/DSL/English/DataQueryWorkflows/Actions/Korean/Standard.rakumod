=begin comment
#==============================================================================
#
#   Data Query Workflows Korean DSL actions in Raku (Perl 6)
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
use DSL::Shared::Actions::CommonStructures;
use DSL::English::DataQueryWorkflows::Actions::Korean::Predicate;

unit module DSL::English::DataQueryWorkflows::Actions::Korean::Standard;

class DSL::English::DataQueryWorkflows::Actions::Korean::Standard
		is DSL::Shared::Actions::CommonStructures
        is DSL::English::DataQueryWorkflows::Actions::Korean::Predicate {

    method TOP($/) { make $/.values[0].made; }

	# General
	method variable-names-list($/) { make $<variable-name>>>.made.join(', '); }
	method quoted-variable-names-list($/) { make $<quoted-variable-name>>>.made.join(', '); }
	method mixed-quoted-variable-names-list($/) { make $<mixed-quoted-variable-name>>>.made.join(', '); }

	# Load data
	method data-load-command($/) { make $/.values[0].made; }
	method load-data-table($/) { make '테이블로드: ' ~ $<data-location-spec>.made; }
	method data-location-spec($/) { make '\"' ~ $/.Str ~ '\"'; }
	method use-data-table($/) { make '테이블 사용: ' ~ $<variable-name>.made; }

	# Distinct command
	method distinct-command($/) { make $/.values[0].made; }
	method distinct-simple-command($/) { make '고유 행'; }

	# Missing treatment command
	method missing-treatment-command($/) { make $/.values[0].made; }
	method drop-incomplete-cases-command($/) { make '불완전한 행 제거'; }
	method replace-missing-command($/) { make '결 측값 제거 ' ~ $<replace-missing-rhs>.made; }

	# Select command
	method select-command($/) { make '열을 선택: ' ~ $/.values[0].made; }
	method select-plain-variables($/) { make $<variable-names-list>.made; }
	method select-mixed-quoted-variables($/) { make $<mixed-quoted-variable-names-list>.made; }

	# Filter commands
	method filter-command($/) { make '술어로 필터링: ' ~ $<filter-spec>.made; }
	method filter-spec($/) { make $<predicates-list>.made; }

	# Mutate command
	method mutate-command($/) { make '양수인: ' ~ $<assign-pairs-list>.made; }
	method assign-pairs-list($/) { make $<assign-pair>>>.made.join(', '); }
	method assign-pair($/) { make $<assign-pair-lhs>.made ~ ' = ' ~ $<assign-pair-rhs>.made; }
	method assign-pair-lhs($/) { make $/.values[0].made; }
	method assign-pair-rhs($/) { make $/.values[0].made; }

	# Group command
	method group-command($/) { make '열로 그룹화: ' ~ $<variable-names-list>.made; }

	# Ungroup command
	method ungroup-command($/) { make $/.values[0].made; }
	method ungroup-simple-command($/) { make '그룹 해제'; }

	# Arrange command
	method arrange-command($/) { make $/.values[0].made; }
	method arrange-simple-spec($/) { make $<mixed-quoted-variable-names-list>.made; }
	method arrange-command-ascending($/) { make '열로 정렬: ' ~ $<arrange-simple-spec>.made; }
	method arrange-command-descending($/) { make '열과 함께 내림차순으로 정렬: ' ~ $<arrange-simple-spec>.made; }

    # Rename columns command
    method rename-columns-command($/) { make $/.values[0].made; }
    method rename-columns-simple($/) {
        make '열 이름 바꾸기 ' ~ $<current>.made ~ ' 같이 ' ~ $<new>.made;
    }

    # Drop columns command
    method drop-columns-command($/) { make $/.values[0].made; }
    method drop-columns-simple($/) {
        make '기둥을 제거 ' ~ $<todrop>.made;
    }

	# Statistics command
	method statistics-command($/) { make $/.values[0].made; }
	method count-command($/) { make '하위 그룹의 크기 찾기'; }
	method summarize-data($/) { make '목적을 요약하다'; }
	method glimpse-data($/) { make '물체를 엿볼 수있다'; }
	method summarize-all-command($/) {
		if $<summarize-all-funcs-spec> {
			make '모든 열에 ' ~ $<summarize-all-funcs-spec>.made ~ ' 함수 적용';
		} else {
			make '모든 열의 평균값 찾기';
		}
	}
	method summarize-all-funcs-spec($/) { make $<variable-names-list>.made; }

	# Join command
	method join-command($/) { make $/.values[0].made; }

	method join-by-spec($/) { make 'c(' ~ $/.values[0].made ~ ')'; }

	method full-join-spec($/)  {
		if $<join-by-spec> {
			make '완전 조인 ' ~ $<dataset-name>.made ~ ' 으로 ' ~ $<join-by-spec>.made ~ ')';
		} else {
			make '완전 조인 ' ~ $<dataset-name>.made ~ ')';
		}
	}

	method inner-join-spec($/)  {
		if $<join-by-spec> {
			make '내부 결합 ' ~ $<dataset-name>.made ~ ' 으로 ' ~ $<join-by-spec>.made ~ ')';
		} else {
			make '내부 결합 ' ~ $<dataset-name>.made ~ ')';
		}
	}

	method left-join-spec($/)  {
		if $<join-by-spec> {
			make '왼쪽 결합 ' ~ $<dataset-name>.made ~ ' 으로 ' ~ $<join-by-spec>.made ~ ')';
		} else {
			make '왼쪽 결합  ' ~ $<dataset-name>.made ~ ')';
		}
	}

	method right-join-spec($/)  {
		if $<join-by-spec> {
			make '바로 결합 ' ~ $<dataset-name>.made ~ ' 으로 ' ~ $<join-by-spec>.made ~ ')';
		} else {
			make '바로 결합 ' ~ $<dataset-name>.made ~ ')';
		}
	}

	method semi-join-spec($/)  {
		if $<join-by-spec> {
			make '세미 조인 ' ~ $<dataset-name>.made ~ ' 으로 ' ~ $<join-by-spec>.made ~ ')';
		} else {
			make '세미 조인 ' ~ $<dataset-name>.made ~ ')';
		}
	}

	# Cross tabulate command
	method cross-tabulation-command($/) { make $/.values[0].made; }
	method cross-tabulate-command($/) { $<cross-tabulation-formula>.made }
	method contingency-matrix-command($/) { $<cross-tabulation-formula>.made }
	method cross-tabulation-formula($/) { make $/.values[0].made; }
	method cross-tabulation-double-formula($/) {
		if $<values-variable-name> {
			make '행과 교차 표로 작성 ' ~ $<rows-variable-name>.made ~ ', 열 ' ~ $<columns-variable-name>.made ~ ' 및 값 ' ~ $<values-variable-name>;
		} else {
			make '행과 교차 표로 작성 ' ~ $<rows-variable-name>.made ~ ', 열 ' ~ $<columns-variable-name>.made;
		}
	}
	method cross-tabulation-single-formula($/) {
		if $<values-variable-name> {
			make '행과 교차 표로 작성 ' ~ $<rows-variable-name>.made ~ ', 및 값 ' ~ $<values-variable-name>;
		} else {
			make '행과 교차 표로 작성 ' ~ $<rows-variable-name>.made;
		}
	}
    method rows-variable-name($/) { make $/.values[0].made; }
    method columns-variable-name($/) { make $/.values[0].made; }
    method values-variable-name($/) { make $/.values[0].made; }

	# Reshape command
    method reshape-command($/) { make $/.values[0].made; }

	# Pivot longer command
    method pivot-longer-command($/) { make '좁은 형태로 변신하다 ' ~ $<pivot-longer-arguments-list>.made; }
    method pivot-longer-arguments-list($/) { make $<pivot-longer-argument>>>.made.join(', '); }
    method pivot-longer-argument($/) { make $/.values[0].made; }

    method pivot-longer-columns-spec($/) { make '열 ' ~ $<mixed-quoted-variable-names-list>.made; }

    method pivot-longer-variable-column-spec($/) { make '가변 열 ' ~ $<quoted-variable-name>.made; }

    method pivot-longer-value-column-spec($/) { make '값 열 ' ~ $<quoted-variable-name>.made; }

    # Pivot wider command
    method pivot-wider-command($/) { make '넓은 형태로 변신하다 ' ~ $<pivot-wider-arguments-list>.made; }
    method pivot-wider-arguments-list($/) { make $<pivot-wider-argument>>>.made.join(', '); }
    method pivot-wider-argument($/) { make $/.values[0].made; }

    method pivot-wider-id-columns-spec($/) { make '식별자 열 ' ~ $<mixed-quoted-variable-names-list>.made ~ ' )'; }

    method pivot-wider-variable-column-spec($/) { make '가변 열 ' ~ $<quoted-variable-name>.made; }

    method pivot-wider-value-column-spec($/) { make '값 열 ' ~ $<quoted-variable-name>.made; }

    # Pipeline command
    method pipeline-command($/) { make $/.values[0].made; }
    method take-pipeline-value($/) { make '물건을 가져 가다'; }
    method echo-pipeline-value($/) { make '파이프 라인 값을 에코'; }

    method echo-command($/) { make '메시지를 인쇄: ' ~ $<echo-message-spec>.made; }
    method echo-message-spec($/) { make $/.values[0].made; }
    method echo-words-list($/) { make '"' ~ $<variable-name>>>.made.join(' ') ~ '"'; }
    method echo-variable($/) { make $/.Str; }
    method echo-text($/) { make $/.Str; }
}