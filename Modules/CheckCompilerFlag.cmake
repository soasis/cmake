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
Given a flag name and the actual flag, like
check_cxx_compiler_flag(strict-conformance MSVC /permissive- GCC -pedantic)
we check if the given flag works C++ compiler. If it is, then
--strict-conformance will be the provided flag. MSVC and GCC are the 2 different
"style" of flags to be tested for.
]]
function (check_compiler_flag flag)
	cmake_parse_arguments(flag "" "GCC MSVC" "" ${ARGN})
	if (NOT flag_GCC)
		set(flag_GCC ${flag})
	endif()
	if (NOT flag_MSVC)
		set(flag_MSVC ${flag})
	endif()
	string(MAKE_C_IDENTIFIER "${flag}" suffix)
	string(TOUPPER "${suffix}" suffix)
	get_property(enabled-languages GLOBAL PROPERTY ENABLED_LANGUAGES)
	if (CXX IN_LIST enabled-languages)
		if (MSVC)
			check_cxx_compiler_flag(${flag_MSVC} CXX_CHECK_FLAG_${suffix})
		else()
			check_cxx_compiler_flag(${flag_GCC} CXX_CHECK_FLAG_${suffix})
		endif()
	endif()
	if (C IN_LIST enabled-languages)
		if (MSVC)
			check_c_compiler_flag(${flag_MSVC} C_CHECK_FLAG_${suffix})
		else()
			check_c_compiler_flag(${flag_GCC} C_CHECK_FLAG_${suffix})
		endif()
	endif()
	string(CONCAT when $<OR:
		$<AND:$<BOOL:${CXX_CHECK_FLAG_${suffix}}>,$<COMPILE_LANGUAGE:CXX>>,
		$<AND:$<BOOL:${C_CHECK_FLAG_${suffix}}>,$<COMPILE_LANGUAGE:C>>,
	>)

	set(--${flag} $<${when}:${forbid_prefix}${flag}> PARENT_SCOPE)
endfunction()
