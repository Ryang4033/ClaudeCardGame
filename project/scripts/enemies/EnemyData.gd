class_name EnemyData
extends Resource

enum IntentType { ATTACK, BLOCK, BUFF, DEBUFF, UNKNOWN }

class Intent:
	var type: IntentType
	var value: int
	var description: String

	func _init(t: IntentType, v: int, desc: String) -> void:
		type = t
		value = v
		description = desc

@export var enemy_name: String = ""
@export var max_health: int = 50
@export var art: Texture2D

# Pattern is an array of Dictionaries: { "type": IntentType, "value": int, "effect": String }
@export var action_pattern: Array[Dictionary] = []

var _pattern_index: int = 0

func get_next_action() -> Dictionary:
	if action_pattern.is_empty():
		return {}
	var action := action_pattern[_pattern_index]
	_pattern_index = (_pattern_index + 1) % action_pattern.size()
	return action

func reset_pattern() -> void:
	_pattern_index = 0
