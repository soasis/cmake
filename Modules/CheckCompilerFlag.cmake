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
	endif
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
