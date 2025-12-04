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

import os
import visualize
from typing import List, Optional, Dict, Any


def primary_data_label_sorter(d: visualize.data_label_info):
	return d.primary


def parse_sources_from_json(
    j: dict, config_file_path: str,
    input_file_paths: List[str]) -> visualize.analysis_info:
	config_relative_path = os.path.dirname(config_file_path)
	info: visualize.analysis_info = visualize.analysis_info()

	for input in input_file_paths:
		src_info: visualize.source_info = visualize.source_info(
		    input, "", True)
		info.sources.append(src_info)

	jtoplevelname = j.get("name")
	jtoplevelfile_name = j.get("file_name")
	jtopleveldiscard_unmatched_runs = j.get("discard_unmatched_runs")
	if isinstance(jtopleveldiscard_unmatched_runs, bool):
		info.discard_unmatched_runs = jtopleveldiscard_unmatched_runs
	if isinstance(jtoplevelname, str):
		info.file_name = jtoplevelfile_name
	if isinstance(jtoplevelname, str):
		info.name = jtoplevelname
	else:
		info.name = os.path.split(config_file_path)[1]
	jdefault_scale = j.get("scale")
	if jdefault_scale:
		jdefaultaxis_scale: Optional[str] = jdefault_scale.get("axis_scale")
		defaultaxis_scale = visualize.axis_scaling.automatic
		if isinstance(jdefaultaxis_scale, str):
			if jdefaultaxis_scale == "automatic":
				defaultaxis_scale = visualize.axis_scaling.automatic
			if jdefaultaxis_scale == "linear":
				defaultaxis_scale = visualize.axis_scaling.automatic
			if jdefaultaxis_scale == "logarithmic":
				defaultaxis_scale = visualize.axis_scaling.automatic

		jtype = jdefault_scale["type"]
		if jtype == "relative":
			jto = jdefault_scale["to"]
			info.default_scale = visualize.scaling_info(
			    visualize.graph_scaling.relative, defaultaxis_scale, jto)
		else:
			info.default_scale = visualize.scaling_info(
			    visualize.graph_scaling.absolute, defaultaxis_scale, "")
	jcategories = j.get("categories")
	if jcategories:
		for jcategory in jcategories:
			name = jcategory["name"]
			jfilename: Optional[str] = jcategory.get("file_name")
			jcatscale = jcategory.get("scale")
			jcatpattern: Optional[str] = jcategory.get("pattern")
			jcatexact_pattern: Optional[str] = jcategory.get(
			    "exact_pattern")
			jcatexclude: Optional[str] = jcategory.get("exclude")
			jcatexclude: Optional[str] = jcategory.get("exclude")
			jascending = jcategory.get("ascending")
			jdescending = jcategory.get("descending")
			jdescription = jcategory.get("description")
			scale: Optional[visualize.scaling_info] = None
			order: visualize.category_order = visualize.category_order.ascending
			if isinstance(jascending, bool) and jascending:
				order = visualize.category_order.ascending
			if isinstance(jdescending, bool) and jdescending:
				order = visualize.category_order.descending
			if jcatscale is not None:
				jcatscaletype = jcatscale.get("type")
				jcataxis_scale = jcatscale.get("axis_scale")
				cataxis_scale = info.default_scale.axis_scale
				if isinstance(jcataxis_scale, str):
					if jcataxis_scale == "automatic" or jcataxis_scale == "auto":
						cataxis_scale = visualize.axis_scaling.automatic
					if jcataxis_scale == "linear":
						cataxis_scale = visualize.axis_scaling.linear
					if jcataxis_scale == "logarithmic" or jcataxis_scale == "log":
						cataxis_scale = visualize.axis_scaling.logarithmic
				if jtype == "relative":
					jcatscaletypeto: str = jcatscaletype.get("to")
					scale = visualize.scaling_info(
					    visualize.graph_scaling.relative, cataxis_scale,
					    jcatscaletypeto)
				else:
					scale = visualize.scaling_info(
					    visualize.graph_scaling.absolute, cataxis_scale,
					    "")
			else:
				scale = info.default_scale
			catpattern = "^" + jcatexact_pattern + "$" if isinstance(
			    jcatexact_pattern,
			    str) and len(jcatexact_pattern) > 0 else jcatpattern
			cat_info: visualize.category_info = visualize.category_info(
			    name, scale, order, catpattern, jcatexclude, jdescription,
			    jfilename)
			info.categories.append(cat_info)

	jdata_labels = j.get("data_labels")
	if jdata_labels:
		for jdata_label in jdata_labels:
			dli: visualize.data_label_info = visualize.data_label_info()
			dli.id = jdata_label["id"]
			jname = jdata_label.get("name")
			if isinstance(jname, str):
				dli.name = jname
			jprimary = jdata_label.get("primary")
			if isinstance(jprimary, bool) and jprimary:
				dli.primary = jprimary
			jformat = jdata_label.get("format")
			if jformat is None or jformat == "clock":
				dli.format = visualize.data_label_format.clock
				dli.format_list = visualize.data_label_info.clock_time_scales
			else:
				dli.format = visualize.data_label_format.custom
				dli.format_list = visualize.data_label_info.unknown_time_scales
			jdescription = jdata_label.get("description")
			if isinstance(jdescription, str):
				dli.description = jdescription
			info.data_labels.append(dli)

	jdata_groups = j.get("data_groups")
	order_index: int = 0
	if jdata_groups:
		for jdata_group in jdata_groups:
			jname = jdata_group["name"]
			jpattern = jdata_group.get("pattern")
			jexact_pattern = jdata_group.get("exact_pattern")
			jdescription = jdata_group.get("description")
			jalways_included = jdata_group.get("always_included")
			always_included: bool = False
			if isinstance(jalways_included, bool) and jalways_included:
				always_included = True
			catpattern = "^" + jexact_pattern + "$" if isinstance(
			    jexact_pattern,
			    str) and len(jexact_pattern) > 0 else jpattern
			dgi: visualize.data_group_info = visualize.data_group_info(
			    jname, order_index, jpattern, jdescription, always_included)
			order_index = order_index + 1
			info.data_groups.append(dgi)

	if len(info.data_labels) < 1:
		info.data_labels = [
		    visualize.data_label_info("real_time",
		                              visualize.data_label_format.clock,
		                              True),
		    visualize.data_label_info("cpu_time")
		]
	info.data_labels.sort(key=primary_data_label_sorter)

	jremove_prefixes = j["remove_prefixes"]
	if jremove_prefixes is not None:
		for prefix in jremove_prefixes:
			if isinstance(prefix, str):
				info.prefixes_to_remove.append(prefix)

	jremove_suffixes = j["remove_suffixes"]
	if jremove_suffixes is not None:
		for suffix in jremove_suffixes:
			if isinstance(suffix, str):
				info.suffixes_to_remove.append(suffix)

	needs_noop: bool = True
	for dg in info.data_groups:
		if visualize.is_noop_category(dg.name):
			needs_noop = False
			break

	if needs_noop:
		noop_data_group: visualize.data_group_info = visualize.data_group_info(
		    "noop", order_index, "[Nn][Oo]([\\.| |-|_])?[Oo][Pp]",
		    "Measures doing literally nothing (no written expressions/statements in the benchmarking loop). Can be useful for determining potential environment noise.",
		    True)
		info.data_groups.append(noop_data_group)

	return info
