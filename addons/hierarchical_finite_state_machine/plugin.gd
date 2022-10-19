##############################################################################
#	Copyright (C) 2021 Daylily-Zeleen  daylily-zeleen@foxmail.com.
#
#	DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
#
#	Hirerarchical Finite State Machine - Trial Version(HFSM - Trial Version)
#
#
#	This file is part of HFSM - Trial Version.
#
#	HFSM -Triabl Version is free Godot Plugin: you can redistribute it and/or
#modify it under the terms of the GNU Lesser General Public License as published
#by the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#	HFSM -Triabl Version is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU Lesser General Public License for more details.
#
#	You should have received a copy of the GNU Lesser General Public License
#along with HFSM -Triabl Version.  If not, see <http://www.gnu.org/licenses/>.                                                                          *
#
#	HFSM -Triabl Version是一个自由Godot插件，您可以自由分发、修改其中的源
#代码或者重新发布它，新的任何修改后的重新发布版必须同样在遵守LGPL3或更后续的
#版本协议下发布.关于LGPL协议的细则请参考COPYING、COPYING.LESSER文件，
#	您可以在HFSM -Triabl Version的相关目录中获得LGPL协议的副本，
#如果没有找到，请连接到 http://www.gnu.org/licenses/ 查看。
#
#
#	This is HFSM‘s triable version ,but it contain almost features of the full version
#(please read the READEME.md to learn difference.).If this plugin is useful for you,
#please consider to support me by getting the full version.
#
#	虽然这是HFSM的试用版本，但是几乎包含了完整版本的所有功能(请阅读README.md了解他们的差异)。如果这个
#插件对您有帮助，请考虑通过获取完整版本来支持我。
#
# Sponsor link (赞助链接):
#	https://afdian.net/@Daylily-Zeleen
#	https://godotmarketplace.com/?post_type=product&p=37138
#
#
#	@author   Daylily-Zeleen
#	@email    daylily-zeleen@foxmail.com. @qq.com
#	@version  0.8(版本号)
#	@license  GNU Lesser General Public License v3.0 (LGPL-3.0)
#
#----------------------------------------------------------------------------
#  Remark         :
#----------------------------------------------------------------------------
#  Change History :
#  <Date>     | <Version> | <Author>       | <Description>
#----------------------------------------------------------------------------
#  2021/04/14 | 0.1   | Daylily-Zeleen      | Create file
#  2022/07/1~3 | 0.8   | Daylily-Zeleen      |   Bugfix, add new feature.
#----------------------------------------------------------------------------
#
##############################################################################
tool
extends EditorPlugin

const HfsmConstant = preload("res://addons/hierarchical_finite_state_machine/script/source/hfsm_constant.gd")
const HFSM = preload("script/hfsm.gd")
var hfsm_editor_dock:Control# = preload("editor/hfsm_editor.tscn").instance()
var trasition_editor_inspector_plugin:EditorInspectorPlugin #= preload("editor/transit_flow/trasition_editor_inspector_plugin.gd").new()
var state_editor_inspector_plugin:EditorInspectorPlugin# = preload("editor/state_node/state_editor_inspector_plugin.gd").new()
var hfsm_inspector_plugin :EditorInspectorPlugin #= preload("editor/hfsm/hfsm_inspector_plugin.gd").new()
var script_create_dialog :ScriptCreateDialog = ScriptCreateDialog.new()
var script_select_dialog :FileDialog = FileDialog.new()
var current_hfsm :HFSM
var dock_button:ToolButton

var inspector :EditorInspector
var inspector_tab :TabContainer
func _enter_tree():
	var fs :EditorFileSystemDirectory
	while not fs :
		fs = get_editor_interface().get_resource_filesystem().get_filesystem_path("res://addons/hierarchical_finite_state_machine/editor/icon/")
		yield(get_tree(),"idle_frame")
	while true:
		var passed :bool = true
		for i in range(fs.get_file_count()):
			if not fs.get_file_import_is_valid(i):
				passed = false
				yield(get_tree(),"idle_frame")
				break
		if passed :
			break


	hfsm_editor_dock = load("res://addons/hierarchical_finite_state_machine/editor/hfsm_editor.tscn").instance()
	trasition_editor_inspector_plugin= load("res://addons/hierarchical_finite_state_machine/editor/transit_flow/trasition_editor_inspector_plugin.gd").new()
	state_editor_inspector_plugin = load("res://addons/hierarchical_finite_state_machine/editor/state_node/state_editor_inspector_plugin.gd").new()
	hfsm_inspector_plugin= load("res://addons/hierarchical_finite_state_machine/editor/hfsm/hfsm_inspector_plugin.gd").new()

	inspector = get_editor_interface().get_inspector()
	var p = inspector.get_parent()
	while not p is TabContainer:
		p = p.get_parent()
	inspector_tab = p
	if not inspector_tab.is_connected("tab_changed" , self , "_on_inspector_tab_changed"):
		inspector_tab.connect("tab_changed" , self , "_on_inspector_tab_changed")


	get_editor_interface().get_file_system_dock().connect("file_removed" , self , "_on_FileSystemDock_file_removed" )
	hfsm_editor_dock.add_child(script_create_dialog)
	add_custom_type("HFSM", "Node", load("res://addons/hierarchical_finite_state_machine/script/hfsm.gd"), load("res://addons/hierarchical_finite_state_machine/script/icon.svg"))


	dock_button = add_control_to_bottom_panel(hfsm_editor_dock, "HFSM Editor")
	dock_button.hide()

	hfsm_editor_dock.the_plugin = self
	hfsm_editor_dock.connect("node_selected" , self , "_on_FsmEditor_node_selected")


	script_select_dialog.mode = FileDialog.MODE_OPEN_FILE
	script_select_dialog.set_filters(PoolStringArray(["*.gd ; GD Script","*.cs ; CSharp Script"]))
	script_select_dialog.set_title("open script file")
	script_select_dialog.resizable = true
	script_select_dialog.rect_min_size = Vector2(720 , 420)

	get_editor_interface().get_base_control().add_child(script_select_dialog)

	add_inspector_plugin(trasition_editor_inspector_plugin)
	add_inspector_plugin(state_editor_inspector_plugin)
	add_inspector_plugin(hfsm_inspector_plugin)

	get_editor_interface().get_selection().connect("selection_changed", self, "_on_editor_selection_changed")

	connect("scene_changed",self ,"_on_scene_changed")

	var dir := Directory.new()
	var f :File= File.new()
	# 模板目录
	if not dir.file_exists(HfsmConstant.template_folder_path) :
		dir.make_dir(HfsmConstant.template_folder_path)
	# gd状态模板
	if not dir.file_exists(HfsmConstant.gd_state_template_target_path):
		dir.copy(HfsmConstant.gd_state_template_default_path , HfsmConstant.gd_state_template_target_path)
	# cs状态模板
	if not dir.file_exists(HfsmConstant.cs_state_template_target_path):
		if f.open(HfsmConstant.cs_state_template_target_path, File.WRITE) == OK:
			f.store_string(HfsmConstant.CSStateTemplate)
			f.close()

	if not dir.file_exists(HfsmConstant.ignore_target_path) :
		dir.copy(HfsmConstant.ignore_default_path , HfsmConstant.ignore_target_path)
	print("HFSM : If you use this plugin first time in this project ,it may push some error ,they are import error,just ignore them.")
# ----------------- signals -------------
func _on_scene_changed(scene_root):
	hfsm_editor_dock.enable = false


func _on_editor_selection_changed():
	var ns:Array = get_editor_interface().get_selection().get_selected_nodes()
	if ns.size() > 0:
		if ns[0] is HFSM :
			current_hfsm = ns[0]
			_on_inspector_tab_changed(0)
			if not current_hfsm._inspector_res.is_connected("script_reload_request",self ,"_on_script_reload_request"):
				current_hfsm._inspector_res.connect("script_reload_request",self ,"_on_script_reload_request")
			#如果没有资源，则创建资源
			if not current_hfsm._root_fsm_res :
				current_hfsm._root_fsm_res = preload("script/source/nested_fsm_res.gd").new()
			hfsm_editor_dock.current_hfsm = current_hfsm
			hfsm_editor_dock.enable = true

			dock_button.pressed = true
			dock_button.show()

func _on_inspector_tab_changed(indx:int):
	var ns  = get_editor_interface().get_selection().get_selected_nodes()
	if ns.size()>0:
		if ns[0]  and ns[0] is HFSM:
			if inspector_tab.get_current_tab_control().name == "Inspector" :
				get_editor_interface().inspect_object(ns[0]._inspector_res)
			elif inspector_tab.get_current_tab_control().name == "Node" :
				get_editor_interface().inspect_object(ns[0])

func _exit_tree():
	remove_custom_type("HFSM")

	remove_control_from_bottom_panel(hfsm_editor_dock)
	hfsm_editor_dock.queue_free()

	get_editor_interface().get_base_control().remove_child(script_select_dialog)
	script_select_dialog.queue_free()

	remove_inspector_plugin(trasition_editor_inspector_plugin)

const TransitFlow = preload("editor/transit_flow/transit_flow.gd")
const StateNode = preload("editor/state_node/state_node.gd")
func _on_FsmEditor_node_selected(node):
	if node is TransitFlow or node is StateNode:
		get_editor_interface().inspect_object(node.inspector_res)

func _on_FileSystemDock_file_removed(file:String):
	if current_hfsm and current_hfsm._root_fsm_res:
		if current_hfsm._root_fsm_res.is_deleted_state_script():
			hfsm_editor_dock.refresh_state_node()
func _on_script_reload_request():
	var interface := get_editor_interface()
	interface.get_script_editor().reload_scripts()
	interface.get_resource_filesystem().scan()
	interface.get_resource_filesystem().update_script_classes()
	interface.get_script_editor().notification(Node.NOTIFICATION_WM_FOCUS_IN)
