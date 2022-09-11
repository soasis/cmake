# =============================================================================
#
# ztd.cmake
# Copyright © 2022 JeanHeyd "ThePhD" Meneide and Shepherd's Oasis, LLC
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

function (configure_graph_benchmark_targets)
	set(one_value NAME CONFIG REPETITIONS OUTPUT_DIR)
	set(multi_value TARGETS)
	cmake_parse_arguments(PARSE_ARGV 0 ZTD_TOOLS_ARGS "" "${one_value}" "${multi_value}")

	if (NOT ZTD_TOOLS_ARGS_REPETITIONS)
		if (ZTD_TOOLS_BENCHMARKS_REPETITIONS)
			set(ZTD_TOOLS_ARGS_REPETITIONS ${ZTD_TOOLS_BENCHMARKS_REPETITIONS})
		else()
			set(ZTD_TOOLS_ARGS_REPETITIONS 50)
		endif()
	endif()
	if (NOT ZTD_TOOLS_ARGS_NAME)
		cmake_path(RELATIVE_PATH CMAKE_CURRENT_BINARY_DIR
			BASE_DIRECTORY ${CMAKE_BINARY_DIR}
			OUTPUT_VARIABLE relative_binary_dir)
		string(REPLACE "/" "." ZTD_TOOLS_ARGS_NAME ${relative_binary_dir})
	endif()
	if (NOT ZTD_TOOLS_ARGS_CONFIG)
		set(ZTD_TOOLS_ARGS_CONFIG ${CMAKE_CURRENT_SOURCE_DIR}/graph_config.json)
	endif()

	if (NOT ZTD_TOOLS_ARGS_OUTPUT_DIR)
		set(ZTD_TOOLS_ARGS_OUTPUT_DIR ${CMAKE_BINARY_DIR}/benchmark_results)
	endif()

	# # Commands and Targets
	set(result_output_files)
	set(result_output_targets)
	foreach (benchmark_target ${ZTD_TOOLS_ARGS_TARGETS})
		set(result_output_file ${ZTD_TOOLS_ARGS_OUTPUT_DIR}/${benchmark_target}.json)
		list(APPEND result_output_files ${result_output_file})
		add_custom_command(
			OUTPUT "${result_output_file}"
			COMMAND ${benchmark_target}
				--benchmark_out=${result_output_file}
				--benchmark_out_format=json
				--benchmark_repetitions=${ZTD_TOOLS_ARGS_REPETITIONS}
			DEPENDS ${benchmark_target}
			COMMENT "[ztd.tools] Executing ${benchmark_target} benchmarks and outputting to '${ZTD_TOOLS_ARGS_BENCHMARKS_RESULTS_OUTFILE}'"
		)
		add_custom_target(ztd.tools.benchmark_data.${benchmark_target}
			DEPENDS "${result_output_file}"
		)
		list(APPEND result_output_targets ztd.tools.benchmark_data.${benchmark_target})
	endforeach()

	if (Python3_Interpreter_FOUND)
		add_custom_target(ztd.tools.benchmarks.${ZTD_TOOLS_ARGS_NAME}
			COMMAND ${Python3_EXECUTABLE} ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/generate_graphs/__main__.py
				-c ${ZTD_TOOLS_ARGS_CONFIG}
				-i "${result_output_files}"
				-o "${ZTD_TOOLS_ARGS_OUTPUT_DIR}"
			DEPENDS ${result_output_targets}
			WORKING_DIRECTORY ${ZTD_TOOLS_ARGS_OUTPUT_DIR}
			COMMENT "[ztd.tools] Graphing data to '${ZTD_TOOLS_ARGS_OUTPUT_DIR}'"
		)
	endif()
endfunction()
