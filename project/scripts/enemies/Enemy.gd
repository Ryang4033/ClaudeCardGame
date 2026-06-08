class_name Enemy
extends CombatEntity

signal intent_changed(action: Dictionary)

var data: EnemyData
var next_action: Dictionary = {}

func setup(enemy_data: EnemyData) -> void:
	data = enemy_data
	entity_name = data.enemy_name
	max_health = data.max_health
	current_health = max_health
	data.reset_pattern()
	queue_next_action()

func queue_next_action() -> void:
	next_action = data.get_next_action()
	intent_changed.emit(next_action)

func execute_action(target: CombatEntity) -> void:
	if next_action.is_empty():
		return
	match next_action.get("effect", ""):
		"damage":
			var dmg: int = next_action.get("value", 0) + get_strength()
			target.take_damage(dmg)
		"block":
			gain_block(next_action.get("value", 0))
		"apply_vulnerable":
			target.apply_status("vulnerable", next_action.get("value", 1))
		"apply_weak":
			target.apply_status("weak", next_action.get("value", 1))
		"buff_strength":
			apply_status("strength", next_action.get("value", 1))

func start_turn() -> void:
	reset_block()
	tick_statuses()

func end_turn() -> void:
	queue_next_action()
