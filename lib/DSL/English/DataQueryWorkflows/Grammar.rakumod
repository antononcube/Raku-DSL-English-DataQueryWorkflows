=begin comment
#==============================================================================
#
#   Data transformation workflows grammar in Raku Perl 6
#   Copyright (C) 2018  Anton Antonov
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
#   For more details about Raku Perl6 see https://perl6.org/ .
#
#==============================================================================
=end comment

use v6;

use DSL::Shared::Roles::English::CommonParts;
use DSL::Shared::Roles::English::ListManagementCommand;
use DSL::Shared::Roles::English::PipelineCommand;
use DSL::Shared::Roles::ErrorHandling;
use DSL::Shared::Roles::PredicateSpecification;

use DSL::English::DataQueryWorkflows::Grammarish;
use DSL::English::DataQueryWorkflows::Grammar::DataQueryPhrases;

grammar DSL::English::DataQueryWorkflows::Grammar
        does DSL::English::DataQueryWorkflows::Grammarish
        does DSL::Shared::Roles::ErrorHandling
        does DSL::English::DataQueryWorkflows::Grammar::DataQueryPhrases
        does DSL::Shared::Roles::English::ListManagementCommand
        does DSL::Shared::Roles::PredicateSpecification
        does DSL::Shared::Roles::English::PipelineCommand {

}
