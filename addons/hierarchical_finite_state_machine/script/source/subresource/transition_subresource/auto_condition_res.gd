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
#	@email    daylily-zeleen@foxmail.com
#	@version  1.3(版本号)
#	@license  GNU Lesser General Public License v3.0 (LGPL-3.0)
#
#----------------------------------------------------------------------------
#  Remark         :
#----------------------------------------------------------------------------
#  Change History :
#  <Date>     | <Version> | <Author>       | <Description>
#----------------------------------------------------------------------------
#  2021/04/14 | 0.1   | Daylily-Zeleen      | Create file
#  2023/01/30 | 1.3   | Daylily-Zeleen      | Add auto transition type : AnimationFinish
#----------------------------------------------------------------------------
#
##############################################################################
tool
extends Resource

const HfsmConstant = preload("../../../../script/source/hfsm_constant.gd")

var auto_transit_mode :int= HfsmConstant.AUTO_TRANSIT_MODE_ANIMATION_FINISH
var delay_time :float = 1.0
var times :int = 5

func _get_property_list():
	var properties :Array
#			properties.push_back({name = "AutoConditionRes",type = TYPE_NIL,usage = PROPERTY_USAGE_CATEGORY  })

	properties.push_back({name = "auto_transit_mode",type = TYPE_INT })
	properties.push_back({name = "delay_time",type = TYPE_REAL })
	properties.push_back({name = "times",type = TYPE_INT})

	return properties

func _init(_auto_transit_mode :int= HfsmConstant.AUTO_TRANSIT_MODE_ANIMATION_FINISH ,_delay_time :float = 1.0 ,_times :int = 5):
	auto_transit_mode = _auto_transit_mode
	delay_time = _delay_time
	times = _times
