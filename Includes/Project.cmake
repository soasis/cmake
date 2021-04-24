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

include_guard(DIRECTORY)

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
check_compiler_flag(warn-errors MSVC /WX GCC -Werror)
check_compiler_flag(utf8-literal-encoding MSVC /execution-charset:utf-8 GCC -fexec-charset=utf-8)
check_compiler_flag(utf8-source-encoding MSVC /source-charset:utf-8 GCC -finput-charset=utf-8)
check_compiler_flag(extra-constexpr-depth MSVC /constexpr:depth2147483647 GCC -fconstexpr-depth=2147483647 CLANG -fconstexpr-depth=2147483647)
check_compiler_flag(extra-constexpr-steps MSVC /constexpr:steps2147483647 GCC -fconstexpr-ops-limit=2147483647 CLANG -fconstexpr-steps=2147483647)
check_compiler_flag(template-debugging-mode GCC -ftemplate-backtrace-limit=0)
