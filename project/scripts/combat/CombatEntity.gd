class_name CombatEntity
extends Node

signal health_changed(current: int, maximum: int)
signal block_changed(amount: int)
signal died
signal status_applied(status_name: String, stacks: int)

@export var entity_name: String = ""
@export var max_health: int = 80

var current_health: int
var block: int = 0
var statuses: Dictionary = {}  # status_name -> stacks

func _ready() -> void:
	current_health = max_health

func take_damage(amount: int) -> int:
	var damage := _apply_vulnerable(amount)
	damage = max(0, damage - block)
	block = max(0, block - amount)
	block_changed.emit(block)

	current_health = max(0, current_health - damage)
	health_changed.emit(current_health, max_health)

	if current_health <= 0:
		died.emit()
	return damage

func heal(amount: int) -> void:
	current_health = min(max_health, current_health + amount)
	health_changed.emit(current_health, max_health)

func gain_block(amount: int) -> void:
	block += amount
	block_changed.emit(block)

func reset_block() -> void:
	block = 0
	block_changed.emit(block)

func apply_status(status: String, stacks: int) -> void:
	statuses[status] = statuses.get(status, 0) + stacks
	status_applied.emit(status, statuses[status])

func get_status(status: String) -> int:
	return statuses.get(status, 0)

func tick_statuses() -> void:
	var to_remove: Array[String] = []
	for status in statuses:
		match status:
			"vulnerable", "weak", "frail":
				statuses[status] -= 1
				if statuses[status] <= 0:
					to_remove.append(status)
	for s in to_remove:
		statuses.erase(s)

func get_strength() -> int:
	return statuses.get("strength", 0)

func _apply_vulnerable(amount: int) -> int:
	if statuses.get("vulnerable", 0) > 0:
		return int(amount * 1.5)
	return amount
