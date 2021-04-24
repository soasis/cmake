inclde_guard(DIRECTORY)

list(PREPEND CMAKE_MODULE_PATH "${ZTD_CMAKE_PACKAGES}")
list(PREPEND CMAKE_MODULE_PATH "${ZTD_CMAKE_MODULES}")
list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake")
list(APPEND CMAKE_MESSAGE_CONTEXT "${PROJECT_NAME}")

# # Standard Project version
if (NOT CMAKE_CXX_STANDARD GREATER_EQUAL 20)
	set(CMAKE_CXX_STANDARD 20)
endif()

if (NOT CMAKE_C_STANDARD GREATER_EQUAL 11)
	set(CMAKE_C_STANDARD 11)
endif()



# # CMake and ztd Includes
# CMake
include(CheckCXXCompilerFlag)
include(CheckCCompilerFlag)
include(CheckIPOSupported)
include(CMakeDependentOption)
include(CMakePrintHelpers)
include(GNUInstallDirs)
include(FeatureSummary)
include(FetchContent)
include(CTest)
# ztd
include(CheckCompilerDiagnostic)
include(CheckCompilerFlag)
include(FindVersion)

# # Check environment/prepare generator expressions
# normal flags
check_compiler_flag(disable-permissive MSVC /permissive- GCC -pedantic)
# Warning flags
check_compiler_flag(warn-pedantic MSVC /permissive- GCC -pedantic)
check_compiler_flag(warn-all MSVC /W4 GCC -Wall)
check_compiler_flag(warn-all MSVC /permissive- GCC -pedantic)
check_compiler_flag(warn-errors MSVC /WX GCC -Werror)
check_compiler_flag(utf8-literal-encoding MSVC /execution-charset:utf-8 GCC -fexec-charset=utf-8)
check_compiler_flag(utf8-source-encoding MSVC /source-charset:utf-8 GCC -finput-charset=utf-8)

string(CONCAT --extra-constexpr-power
	$<IF:$<BOOL:${MSVC}>,
		/constexpr:steps2147483647,
		$<IF:$<BOOL:${CLANG}>,
			-fconstexpr-steps=2147483647,
			-fconstexpr-depth=2147483647
		>
	>
)
string(CONCAT --template-debugging-mode
	$<IF:$<BOOL:${MSVC}>,
		,
		$<IF:$<BOOL:${CLANG}>,
			-ftemplate-backtrack-limit=0,
			-ftemplate-backtrace-limit=0
		>
	>
)
