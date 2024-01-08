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
Generates a custom commands and utility targets necessary for running the given
benchmark executables (presumably Google Benchmark compatible), then makes them
available as targets. Does not add them tl all.
]]
function (ztd_tools_add_benchmark_grapher)
	if (NOT Python3_Interpreter_FOUND)
		# make sure we find Python3
		find_package(Python3 REQUIRED Interpreter)
	endif()

	set(on_off_value ALL)
	set(one_value NAME CONFIG REPETITIONS OUTPUT_DIR)
	set(multi_value NAMES TARGETS CONFIGS OUTPUT_DIRS)
	cmake_parse_arguments(PARSE_ARGV 0 ZTD_TOOLS_ARGS "${on_off_value}" "${one_value}" "${multi_value}")

	if (ZTD_TEXT_TOOLS_ARGS_NAME AND ZTD_TEXT_TOOLS_ARGS_NAMES)
		message(FATAL "[ztd.tools] Either a single NAME or multiple entries in NAMES shall be specified, but not both")
	endif()
	if (ZTD_TEXT_TOOLS_ARGS_CONFIG AND ZTD_TEXT_TOOLS_ARGS_CONFIGS)
		message(FATAL "[ztd.tools] Either a single CONFIG or multiple entries in CONFIGS shall be specified, but not both")
	endif()
	if (ZTD_TEXT_TOOLS_ARGS_OUTPUT_DIR AND ZTD_TEXT_TOOLS_ARGS_OUTPUT_DIRS)
		message(FATAL "[ztd.tools] Either a single OUTPUT_DIR or multiple entries in OUTPUT_DIRS shall be specified, but not both")
	endif()

	set(ZTD_TOOLS_ARGS_ALL_TEXT)
	if (ZTD_TOOLS_ARGS_ALL AND ${ZTD_TOOLS_ARGS_ALL})
		set(ZTD_TOOLS_ARGS_ALL_TEXT ALL)
	endif()

	if (NOT ZTD_TOOLS_ARGS_REPETITIONS)
		if (ZTD_TOOLS_BENCHMARKS_REPETITIONS)
			set(ZTD_TOOLS_ARGS_REPETITIONS ${ZTD_TOOLS_BENCHMARKS_REPETITIONS})
		else()
			set(ZTD_TOOLS_ARGS_REPETITIONS 50)
		endif()
	endif()
	if (NOT ZTD_TOOLS_ARGS_NAMES)
		if (ZTD_TOOLS_ARGS_NAME)
			set(ZTD_TOOLS_ARGS_NAMES ${ZTD_TOOLS_ARGS_NAME})
		else()
			cmake_path(RELATIVE_PATH CMAKE_CURRENT_BINARY_DIR
				BASE_DIRECTORY ${CMAKE_BINARY_DIR}
				OUTPUT_VARIABLE relative_binary_dir)
			string(REPLACE "/" "." ZTD_TOOLS_ARGS_NAMES ${relative_binary_dir})
		endif()
	endif()
	if (NOT ZTD_TOOLS_ARGS_CONFIGS)
		if (ZTD_TOOLS_ARGS_CONFIG)
			set(ZTD_TOOLS_ARGS_CONFIGS ${ZTD_TOOLS_ARGS_CONFIG})
		else()
			set(ZTD_TOOLS_ARGS_CONFIGS ${CMAKE_CURRENT_SOURCE_DIR}/graph_config.json)
		endif()
	endif()

	if (NOT ZTD_TOOLS_ARGS_OUTPUT_DIRS)
		if (ZTD_TOOLS_ARGS_OUTPUT_DIR)
			set(ZTD_TOOLS_ARGS_OUTPUT_DIRS ${ZTD_TOOLS_ARGS_OUTPUT_DIR})
		else()
			list(GET ZTD_TOOLS_ARGS_NAMES 0 ZTD_TOOLS_FIRST_NAME)
			set(ZTD_TOOLS_ARGS_OUTPUT_DIRS ${CMAKE_BINARY_DIR}/benchmark_results/${CMAKE_SYSTEM_PROCESSOR}/${CMAKE_BUILD_TYPE}/${ZTD_TOOLS_FIRST_NAME})
		endif()
	endif()

	list(LENGTH ZTD_TOOLS_ARGS_CONFIGS configs_size)
	list(LENGTH ZTD_TOOLS_ARGS_NAMES names_size)
	if (NOT configs_size EQUAL names_size)
		message(FATAL "[ztd.tools] An equal number of names and configs must be passed in the NAMES and CONFIGS arguments")
	endif()

	# # Commands and Targets
	set(result_output_files)
	set(result_output_targets)
	foreach (benchmark_target IN LISTS ZTD_TOOLS_ARGS_TARGETS)
		set(result_output_dir ${CMAKE_BINARY_DIR}/benchmark_results/${CMAKE_SYSTEM_PROCESSOR}/${CMAKE_BUILD_TYPE})
		file(MAKE_DIRECTORY ${result_output_dir})
		set(result_output_file ${result_output_dir}/${benchmark_target}.json)
		list(APPEND result_output_files ${result_output_file})
		add_custom_command(
			OUTPUT "${result_output_file}"
			COMMAND ${benchmark_target}
				--benchmark_out=${result_output_file}
				--benchmark_out_format=json
				--benchmark_repetitions=${ZTD_TOOLS_ARGS_REPETITIONS}
			DEPENDS ${benchmark_target}
			COMMENT "[ztd.tools] Executing ${benchmark_target} benchmarks and outputting to '${result_output_file}'"
		)
		add_custom_target(ztd.tools.benchmark_data.${benchmark_target}
			DEPENDS "${result_output_file}"
		)
		list(APPEND result_output_targets ztd.tools.benchmark_data.${benchmark_target})
	endforeach()

	foreach(graph_name graph_config graph_output_dir
		IN ZIP_LISTS
		ZTD_TOOLS_ARGS_NAMES ZTD_TOOLS_ARGS_CONFIGS ZTD_TOOLS_ARGS_OUTPUT_DIRS)
		if (NOT graph_output_dir)
			set(graph_output_dir ${CMAKE_BINARY_DIR}/benchmark_results/${CMAKE_SYSTEM_PROCESSOR}/${CMAKE_BUILD_TYPE}/${graph_name})
		endif()
		file(MAKE_DIRECTORY ${graph_output_dir})
		add_custom_target(ztd.tools.benchmark_grapher.${graph_name}
			${ZTD_TOOLS_ARGS_ALL_TEXT}
			COMMAND ${Python3_EXECUTABLE} ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/generate_graphs/__main__.py
				-c ${graph_config}
				-i "${result_output_files}"
				-o "${graph_output_dir}"
			DEPENDS ${result_output_targets} ${graph_config}
			WORKING_DIRECTORY ${graph_output_dir}
			COMMENT "[ztd.tools] Graphing data to '${graph_output_dir}'"
		)
	endforeach()
endfunction()
