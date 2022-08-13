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

include_guard(GLOBAL)

#[[
Generates a manifest and a config file (windows) for a specific target.
]]
function (generate_config_and_manifest_for target)
	cmake_parse_arguments(PARSE_ARGV 1 flag "" "" "DEPEDENCY_DIR")
	if (NOT flag_DEPEDENCY_DIR)
		set(flag_DEPEDENCY_DIR "trash")
	endif()

	if (MSVC)
		# Only for MSVC do we do the deep configuration techniques

		# The basic configuration file. This has to be placed next to the application/dll and must have
		# the same name as it, plus the suffix ".manifest".
		set(raw_basic_config [=[<?xml version="1.0"?>
<configuration>
	<runtime>
		<assemblyBinding xmlns="urn:schemas-microsoft-com.asm.v1">
			<probing privatePath="${ZTD_GCAMF_DEPENDENCY_DIR}" />
		</assemblyBinding>
	</runtime>
</configuration>]=])

		# The basic application manifest. This can be added to the sources of the target,
		# and CMake should process it as-is.
		set(basic_manifest [=[<assembly xmlns="urn:schemas-microsoft-com:asm.v1" manifestVersion="1.0" xmlns:asmv3="urn:schemas-microsoft-com:asm.v3">
	<asmv3:application>
		<asmv3:windowsSettings xmlns="http://schemas.microsoft.com/SMI/2019/WindowsSettings" xmlns:ws2="http://schemas.microsoft.com/SMI/2016/WindowsSettings"> 
			<activeCodePage>UTF-8</activeCodePage>
			<ws2:longPathAware>true</ws2:longPathAware>
		</asmv3:windowsSettings>
	</asmv3:application>
</assembly>]=])

		# The symlink command; processes each dependency in ${target}
		# and produces either a copied object or a symlink
		set(symlink_command_script [=[set(ZTD_GCAMF_DEPENDENCIES $<TARGET_RUNTIME_DLLS:${ZTD_GCAMF_DEPENDENCY}>)
foreach (dependency ${ZTD_GCAMF_DEPENDENCIES})
	file(CREATE_LINK ${dependency} ${dependency_link_target}
		RESULT dependency_link_success COPY_ON_ERROR SYMBOLIC)
	if (NOT dependency_link_sucess)
		message(FATAL_ERROR "[ztd.cmake] Could not create a symbolic link OR copy ${dependency} at/into the location ${dependency_link_target}")
	endif()
endforeach()
	]=])

		set(ZTD_GCAMF_DEPENDENCY ${target})
		set(ZTD_GCAMF_DEPENDENCY_DIR ${flag_DEPEDENCY_DIR})
		set(config_file $<TARGET_FILE_DIR:${target}>/$<TARGET_FILE_NAME:${target}>.config)
		set(manifest_file ${CMAKE_CURRENT_BINARY_DIR}/${target}.ztd.cmake.manifest)
		set(symlink_command_script_configure_file ${CMAKE_CURRENT_BINARY_DIR}/${target}.generate_or_copy_symlinks.cmake.in)
		set(symlink_command_script_file ${CMAKE_CURRENT_BINARY_DIR}/$<TARGET_FILE_NAME:${target}>.generate_or_copy_symlinks.cmake)
		string(REPLACE "ZTD_GCAMF_DEPENDENCY_DIR" "${ZTD_GCAMF_DEPENDENCY_DIR}" basic_config ${raw_basic_config})
		
		file(CONFIGURE
			OUTPUT ${manifest_file}
			CONTENT ${basic_manifest})

		file(CONFIGURE
			OUTPUT ${symlink_command_script_configure_file}
			CONTENT ${symlink_command_script})

		file(GENERATE
			OUTPUT ${config_file}
			CONTENT ${basic_config})

		file(GENERATE
			OUTPUT ${symlink_command_script_file}
			INPUT ${symlink_command_script_configure_file}
			TARGET ${target})

		target_sources(${target}
			PRIVATE
			${manifest_file}
		)
		add_custom_command(TARGET ${target} POST_BUILD
			COMMAND ${CMAKE_COMMAND} -P ${symlink_command_script_file}
			COMMAND_EXPAND_LISTS
		)
	elseif(WIN32)
		# We may be on Clang or something;
		# copy all dependeny DLLs to the output
		add_custom_command(TARGET ${target} POST_BUILD
			COMMAND ${CMAKE_COMMAND} -E copy_if_different
				$<TARGET_RUNTIME_DLLS:${target}>
				$<TARGET_FILE_DIR:${target}>
			COMMAND_EXPAND_LISTS
		)
	endif()
endfunction()
