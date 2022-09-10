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
#   ʇǝu˙oǝʇsod@ǝqnɔuouoʇuɐ,
#   Windermere, Florida, USA.
#
#==============================================================================
#
#   For more details about Raku (Perl6) see https://raku.org/ .
#
#==============================================================================
=end comment

use v6.d;

use DSL::English::DataQueryWorkflows::Actions::General;
use DSL::English::DataQueryWorkflows::Actions::Korean::Predicate;
use DSL::Shared::Actions::English::PipelineCommand;

class DSL::English::DataQueryWorkflows::Actions::Korean::Standard
		does DSL::English::DataQueryWorkflows::Actions::General
		is DSL::Shared::Actions::English::PipelineCommand
        is DSL::English::DataQueryWorkflows::Actions::Korean::Predicate {

	has Str $.name = 'DSL-English-DataQueryWorkflows-Korean-Standard';

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
	method load-data-table($/) { make '테이블로드: ' ~ $<data-location-spec>.made; }
	method data-location-spec($/) {
		make $<regex-pattern-spec> ?? $<regex-pattern-spec>.made !! '"' ~ self.unquote($/.Str) ~ '"';
	}
	method use-data-table($/) { make '테이블 사용: ' ~ $<mixed-quoted-variable-name>.made; }

	# Distinct command
	method distinct-command($/) { make $/.values[0].made; }
	method distinct-simple-command($/) { make '고유 행'; }

	# Missing treatment command
	method missing-treatment-command($/) { make $/.values[0].made; }
	method drop-incomplete-cases-command($/) { make '불완전한 행 제거'; }
	method replace-missing-command($/) {
		my $na = $<replace-missing-rhs> ?? $<replace-missing-rhs>.made !! '"NA"';
		make '결 측값 제거 ' ~ $na;
	}
    method replace-missing-rhs($/) { make $/.values[0].made; }

	# Replace command
    method replace-command($/) { make $<lhs>.made ~ ' 를 ' ~ $<rhs>.made ~ ' 로 대체'; }

	# Select command
	method select-command($/) { make $/.values[0].made; }
	method select-columns-simple($/) { make $/.values[0].made ~ ' 열 선택'; }
	method select-columns-by-two-lists($/) { make $<current>.made ~ ' 열을 선택하고 ' ~ $<new>.made ~ ' 로 이름을 바꿉니다'; }
    method select-columns-by-pairs($/) { make $/.values[0].made ~ ' 로 열을 선택하고 이름을 바꿉니다' ; }

	# Filter commands
	method filter-command($/) { make '술어로 필터링: ' ~ $<filter-spec>.made; }
	method filter-spec($/) { make $<predicates-list>.made; }

	# Mutate command
	method mutate-command($/) { make $/.values[0].made; }
	method mutate-by-two-lists($/) { $<current>.made ~ ' 열을 ' ~ $<new>.made ~ ' 에 할당';}
	method mutate-by-pairs($/) { make '양수인: ' ~ $/.values[0].made;  }

    # Group command
    method group-command($/) { make $/.values[0].made; }
	method group-by-command($/) { make '열로 그룹화: ' ~ $/.values[0]; }
	method group-map-command($/) { make '각 그룹 ' ~ $/.values[0].made ~ ' 에 적용 '; }

	# Ungroup command
	method ungroup-command($/) { make $/.values[0].made; }
	method ungroup-simple-command($/) { make '그룹 해제'; }

	# Arrange command
	method arrange-command($/) { make $/.values[0].made; }
	method arrange-simple-command($/) {
        make $<reverse-sort-phrase> || $<descending-phrase> ?? '역 정렬' !! '종류';
    }
	method arrange-by-spec($/) { make $/.values[0].made; }
	method arrange-by-command-ascending($/) { make '열로 정렬: ' ~ $<arrange-by-spec>.made; }
	method arrange-by-command-descending($/) { make '열과 함께 내림차순으로 정렬: ' ~ $<arrange-by-spec>.made; }

    # Rename columns command
    method rename-columns-command($/) { make $/.values[0].made; }
    method rename-columns-by-two-lists($/) {
        make '열 이름 바꾸기 ' ~ $<current>.made ~ ' 같이 ' ~ $<new>.made;
    }
    method rename-columns-by-pairs($/) { make $/.values[0].made ~ ' 로 열 이름 바꾸기'; }

    # Drop columns command
    method drop-columns-command($/) { make $/.values[0].made; }
    method drop-columns-simple($/) {
        make '기둥을 제거 ' ~ $<todrop>.made;
    }

	# Statistics command
	method statistics-command($/) { make $/.values[0].made; }
	method data-dimensions-command($/) { make '치수 표시'; }
	method count-command($/) { make '하위 그룹의 크기 찾기'; }
	method echo-count-command($/) { make '쇼 카운트'; }
	method data-summary-command($/) { make '목적을 요약하다'; }
	method glimpse-data($/) { make '물체를 엿볼 수있다'; }

	# Summarize command
    method summarize-command($/) { make $/.values[0].made; }
	method summarize-by-pairs($/) { make '열로 요약 : ' ~ $/.values[0].made; }
	method summarize-all-command($/) {
		if $<summarize-funcs-spec> {
			make '모든 열에 ' ~ $<summarize-funcs-spec>.made ~ ' 함수 적용';
		} else {
			make '모든 열의 평균값 찾기';
		}
	}
	method summarize-at-command($/) { make '함수 ' ~ $<summarize-funcs-spec>.made ~' 를 사용하여 ' ~ $<cols>.made ~ ' 열 요약'; }
    method summarize-funcs-spec($/) { make $<variable-name-or-wl-expr-list>.made.join(', '); }

	# Join command
	method join-command($/) { make $/.values[0].made; }

	method join-by-spec($/) { make '(' ~ $/.values[0].made ~ ')'; }

	method full-join-spec($/)  {
		if $<join-by-spec> {
			make '완전 조인 ' ~ $<dataset-name>.made ~ ' 으로 ' ~ $<join-by-spec>.made;
		} else {
			make '완전 조인 ' ~ $<dataset-name>.made;
		}
	}

	method inner-join-spec($/)  {
		if $<join-by-spec> {
			make '내부 결합 ' ~ $<dataset-name>.made ~ ' 으로 ' ~ $<join-by-spec>.made;
		} else {
			make '내부 결합 ' ~ $<dataset-name>.made;
		}
	}

	method left-join-spec($/)  {
		if $<join-by-spec> {
			make '왼쪽 결합 ' ~ $<dataset-name>.made ~ ' 으로 ' ~ $<join-by-spec>.made;
		} else {
			make '왼쪽 결합  ' ~ $<dataset-name>.made;
		}
	}

	method right-join-spec($/)  {
		if $<join-by-spec> {
			make '바로 결합 ' ~ $<dataset-name>.made ~ ' 으로 ' ~ $<join-by-spec>.made;
		} else {
			make '바로 결합 ' ~ $<dataset-name>.made;
		}
	}

	method semi-join-spec($/)  {
		if $<join-by-spec> {
			make '세미 조인 ' ~ $<dataset-name>.made ~ ' 으로 ' ~ $<join-by-spec>.made;
		} else {
			make '세미 조인 ' ~ $<dataset-name>.made;
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
    method pivot-longer-command($/) {
		if  $<pivot-longer-arguments-list> {
			make $<pivot-longer-arguments-list>.made ~ ' 를 사용하여 긴 형식으로 변환';
		} else {
			make '긴 형식으로 변환';
		}
	}
    method pivot-longer-arguments-list($/) { make $<pivot-longer-argument>>>.made.join(', '); }
    method pivot-longer-argument($/) { make $/.values[0].made; }

    method pivot-longer-id-columns-spec($/) { make 'id 열 ' ~ $/.values[0].made; }

	method pivot-longer-columns-spec($/) { make '열 ' ~ $/.values[0].made; }

    method pivot-longer-variable-column-name-spec($/) { make '가변 열 ' ~ $/.values[0].made; }

    method pivot-longer-value-column-name-spec($/) { make '값 열 ' ~ $/.values[0].made; }

    # Pivot wider command
    method pivot-wider-command($/) { make '넓은 형태로 변신하다 ' ~ $<pivot-wider-arguments-list>.made; }
    method pivot-wider-arguments-list($/) { make $<pivot-wider-argument>>>.made.join(', '); }
    method pivot-wider-argument($/) { make $/.values[0].made; }

    method pivot-wider-id-columns-spec($/) { make '식별자 열 ' ~ $/.values[0].made; }

    method pivot-wider-variable-column-spec($/) { make '가변 열 ' ~ $/.values[0].made; }

    method pivot-wider-value-column-spec($/) { make '값 열 ' ~ $/.values[0].made; }

	# Separate string column command
	method separate-column-command($/) {
		my $intocols = map( { '"' ~ $_.subst(:g, '"', '') ~ '"' }, $<into>.made.split(', ') ).join(', ');
		make '문자열 열 ' ~ $<col>.made ~ ' 의 값을 ' ~ $intocols ~ ' 열로 분할';
	}
	method separator-spec($/) { make $/.values[0].made; }

	# Make dictionary command
    method make-dictionary-command($/) { make $<keycol>.made ~ ' 열을 ' ~ $<valcol>.made ~ ' 열로 사전 매핑합니다';}

	# Pull column command
	method pull-column-command($/) { make $<column-name-spec>.made ~ ' 열의 값 가져오기'; }

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
    method take-pipeline-value($/) { make '물건을 가져 가다'; }
    method echo-pipeline-value($/) { make '파이프 라인 값을 에코'; }

    method echo-command($/) { make '메시지를 인쇄: ' ~ $<echo-message-spec>.made; }
    method echo-message-spec($/) { make $/.values[0].made; }
    method echo-words-list($/) { make '"' ~ $<variable-name>>>.made.join(' ') ~ '"'; }
    method echo-variable($/) { make $/.Str; }
    method echo-text($/) { make $/.Str; }
}
