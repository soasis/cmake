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

set(ztd_cmake_inclusion_test_config_file [==[
// =============================================================================
//
// ztd.cmake
// Copyright © JeanHeyd "ThePhD" Meneide and Shepherd's Oasis, LLC
// Contact: opensource@soasis.org
//
// Commercial License Usage
// Licensees holding valid commercial ztd.thread licenses may use this file in
// accordance with the commercial license agreement provided with the
// Software or, alternatively, in accordance with the terms contained in
// a written agreement between you and Shepherd's Oasis, LLC.
// For licensing terms and conditions see your agreement. For
// further information contact opensource@soasis.org.
//
// Apache License Version 2 Usage
// Alternatively, this file may be used under the terms of Apache License
// Version 2.0 (the "License") for non-commercial use; you may not use this
// file except in compliance with the License. You may obtain a copy of the
// License at
//
// https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// ============================================================================ //

#include <@INCLUDE_FILE@>

]==])

set(ztd_cmake_inclusion_test_main_file [==[
// =============================================================================
//
// ztd.cmake
// Copyright © JeanHeyd "ThePhD" Meneide and Shepherd's Oasis, LLC
// Contact: opensource@soasis.org
//
// Commercial License Usage
// Licensees holding valid commercial ztd.thread licenses may use this file in
// accordance with the commercial license agreement provided with the
// Software or, alternatively, in accordance with the terms contained in
// a written agreement between you and Shepherd's Oasis, LLC.
// For licensing terms and conditions see your agreement. For
// further information contact opensource@soasis.org.
//
// Apache License Version 2 Usage
// Alternatively, this file may be used under the terms of Apache License
// Version 2.0 (the "License") for non-commercial use; you may not use this
// file except in compliance with the License. You may obtain a copy of the
// License at
//
// https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// ============================================================================ //

int main() { return 0; }

]==])

#[[
Generates a set of tests whose job is to include a single file.
]]
function (generate_inclusion_test)
	set(options)
	set(oneValueArgs ROOT NAME)
	set(multiValueArgs LINK_LIBRARIES)
	cmake_parse_arguments(PARSE_ARGV 0 arg
		"${options}" "${oneValueArgs}" "${multiValueArgs}"
	)

	cmake_path(ABSOLUTE_PATH arg_ROOT BASE_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} NORMALIZE OUTPUT_VARIABLE ${arg_ROOT})
	file(GLOB_RECURSE inclusion_test_c_files
		LIST_DIRECTORIES false
		CONFIGURE_DEPENDS
		${arg_ROOT}/**.h)
	file(GLOB_RECURSE inclusion_test_c++_files
		LIST_DIRECTORIES false
		CONFIGURE_DEPENDS
		${arg_ROOT}/**.hpp
		${arg_ROOT}/**.hxx
		${arg_ROOT}/**.h++
		${arg_ROOT}/**.hh)
	list(FILTER inclusion_test_c_files EXCLUDE REGEX "/detail/")
	list(FILTER inclusion_test_c++_files EXCLUDE REGEX "/detail/")
	foreach(c_file ${inclusion_test_c_files})
		cmake_path(CONVERT ${c_file} TO_CMAKE_PATH_LIST c_file NORMALIZE)
		cmake_path(RELATIVE_PATH c_file BASE_DIRECTORY ${arg_ROOT} OUTPUT_VARIABLE base_c_file)
		set(INCLUDE_FILE ${c_file})
		set(generated_c_file "${CMAKE_CURRENT_BINARY_DIR}/source/${base_c_file}.c")
		set(generated_c_c++_file "${CMAKE_CURRENT_BINARY_DIR}/source/${base_c_file}.c.cpp")
		file(CONFIGURE OUTPUT ${generated_c_file}
			CONTENT "${ztd_cmake_inclusion_test_config_file}"
			@ONLY)
		list(APPEND inclusion_test_generated_files ${generated_c_file})
		file(CONFIGURE OUTPUT ${generated_c_c++_file}
			CONTENT "${ztd_cmake_inclusion_test_config_file}"
			@ONLY)
		list(APPEND inclusion_test_generated_files ${generated_c_c++_file})
	endforeach()
	foreach(c++_file ${inclusion_test_c++_files})
		cmake_path(CONVERT ${c++_file} TO_CMAKE_PATH_LIST c++_file NORMALIZE)
		cmake_path(RELATIVE_PATH c++_file BASE_DIRECTORY ${arg_ROOT} OUTPUT_VARIABLE base_c++_file)
		set(INCLUDE_FILE ${c++_file})
		set(generated_c++_file "${CMAKE_CURRENT_BINARY_DIR}/source/${base_c++_file}.cpp")
		file(CONFIGURE OUTPUT ${generated_c++_file}
			CONTENT "${ztd_cmake_inclusion_test_config_file}"
			@ONLY)
		list(APPEND inclusion_test_generated_files ${generated_c++_file})
	endforeach()
	set(generated_main_file "${CMAKE_CURRENT_BINARY_DIR}/source/main.c")
	file(CONFIGURE OUTPUT ${generated_main_file}
		CONTENT "${ztd_cmake_inclusion_test_main_file}"
		@ONLY)
	list(APPEND inclusion_test_generated_files ${generated_main_file})
	
	add_executable(${arg_NAME} ${inclusion_test_generated_files})
	target_link_libraries(${arg_NAME}
		PRIVATE
		${arg_LINK_LIBRARIES}
	)
	add_test(NAME ztd.thread.tests.inclusion COMMAND ztd.thread.tests.inclusion)
endfunction()
