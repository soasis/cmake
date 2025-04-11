# =============================================================================
#
# ztd.cmake
# Copyright © JeanHeyd "ThePhD" Meneide and Shepherd's Oasis, LLC
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
# https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# ============================================================================>

include_guard(GLOBAL)

#[[
Performs basic, convenient top-level project configurations, such as sensible unified output directories,
better object path maximums, and more. Not required, but suggested for local development and CI.s
]]
function(ztd_tools_top_level_project_config)
	# sensible output directories that don't clobber anything and everything
	set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_SYSTEM_PROCESSOR}/${CMAKE_BUILD_TYPE}/lib" PARENT_SCOPE)
	set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_SYSTEM_PROCESSOR}/${CMAKE_BUILD_TYPE}/bin" PARENT_SCOPE)
	set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_SYSTEM_PROCESSOR}/${CMAKE_BUILD_TYPE}/bin" PARENT_SCOPE)
	# make sure out object file names aren't piss-garbage
	if (NOT CMAKE_OBJECT_PATH_MAX OR CMAKE_OBJECT_PATH_MAX LESS_EQUAL "1024")
		set(CMAKE_OBJECT_PATH_MAX 1024 PARENT_SCOPE)
	endif()
	# Set context messaging
	set(CMAKE_MESSAGE_CONTEXT_SHOW YES PARENT_SCOPE)
	set(CMAKE_MESSAGE_CONTEXT ${PROJECT_NAME} PARENT_SCOPE)
	# remove crappy warning flags that get hard-coded by lower versions of CMake
	if (MSVC)
		string(REGEX REPLACE "/W[0-4]" "" CMAKE_C_FLAGS ${CMAKE_C_FLAGS})
		set(CMAKE_C_FLAGS ${CMAKE_C_FLAGS} PARENT_SCOPE)
		string(REGEX REPLACE "/W[0-4]" "" CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS})
		set(CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS} PARENT_SCOPE)
	endif()
endfunction()
