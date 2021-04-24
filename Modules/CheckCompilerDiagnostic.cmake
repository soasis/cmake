# =============================================================================
#
# ztd.cmake
# Copyright © 2021 JeanHeyd "ThePhD" Meneide and Shepherd's Oasis, LLC
# Contact: opensource@soasis.org
#
# Commercial License Usage
# Licensees holding valid commercial ztd.cmake licenses may use this file in
# accordance with the commercial license agreement provided with the
# Software or, alternatively, in accordance with the terms contained in
# a written agreement between you and Shepherd's Oasis, LLC.
# For licensing terms and conditions see your agreement. For
# further information contact opensource@soasis.org.
#
# Apache License Version 2 Usage
# Alternatively, this file may be used under the terms of Apache License
# Version 2.0 (the "License") for non-commercial use; you may not use this
# file except in compliance with the License. You may obtain a copy of the
# License at
#
#		http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# ============================================================================>

include_guard(GLOBAL)

include(CheckCXXCompilerFlag)
include(CheckCCompilerFlag)

#[[
Given a diagnostic name and flag, like
check_cxx_compiler_diagnostic(pig MSVC 1312)
or
check_cxx_compiler_diagnostic(pig GCC acab)
we check if the given flag works C++ compiler. If it does, we then generate
a --warn, --allow, --deny, and --forbid prefixed set of variables. Users are
then free to simply apply them to targets at will.
]]
function (check_compiler_diagnostic diagnostic)
	cmake_parse_arguments(diagnostic "" "GCC MSVC" "" ${ARGN})
	if (NOT diagnostic_GCC)
		set(diagnostic_GCC ${diagnostic})
	endif()
	if (NOT diagnostic_MSVC)
		set(diagnostic_MSVC ${diagnostic})
	endif()
	string(MAKE_C_IDENTIFIER "${diagnostic}" suffix)
	string(TOUPPER "${suffix}" suffix)
	get_property(enabled-languages GLOBAL PROPERTY ENABLED_LANGUAGES)
	if (CXX IN_LIST enabled-languages)
		if (MSVC)
			check_cxx_compiler_flag(-w1${diagnostic_MSVC} CXX_DIAGNOSTIC_${suffix})
		else()
			check_cxx_compiler_flag(-W${diagnostic_GCC} CXX_DIAGNOSTIC_${suffix})
		endif()
	endif()
	if (C IN_LIST enabled-languages)
		if (MSVC)
			check_c_compiler_flag(-w1${diagnostic_MSVC} C_DIAGNOSTIC_${suffix})
		else()
			check_c_compiler_flag(-W${diagnostic_GCC} C_DIAGNOSTIC_${suffix})
		endif()
	endif()
	string(CONCAT when $<OR:
		$<AND:$<BOOL:${CXX_DIAGNOSTIC_${suffix}}>,$<COMPILE_LANGUAGE:CXX>>,
		$<AND:$<BOOL:${C_DIAGNOSTIC_${suffix}}>,$<COMPILE_LANGUAGE:C>>
	>)
	set(forbid_prefix $<IF:$<BOOL:${MSVC}>,-we,-Werror=>)
	set(allow_prefix $<IF:$<BOOL:${MSVC}>,-wd,-Wno->)
	set(warn_prefix $<IF:$<BOOL:${MSVC}>,-w1,-W>)

	set(--forbid-${diagnostic} $<${when}:${forbid_prefix}${diagnostic}> PARENT_SCOPE)
	set(--allow-${diagnostic} $<${when}:${allow_prefix}${diagnostic}> PARENT_SCOPE)
	# Set these warnings to level 1 warnings, so they appear by default
	set(--warn-${diagnostic} $<${when}:${warn_prefix}${diagnostic}> PARENT_SCOPE)

	set(--deny-${diagnostic} ${--forbid-${diagnostic}} PARENT_SCOPE)
endfunction()
