class_name Player
extends CombatEntity

signal energy_changed(current: int, maximum: int)

@export var max_energy: int = 3
@export var cards_per_turn: int = 5

var current_energy: int

func _ready() -> void:
	super()
	entity_name = "Player"
	max_health = 80
	current_health = max_health
	current_energy = max_energy

func start_turn() -> void:
	reset_block()
	current_energy = max_energy
	energy_changed.emit(current_energy, max_energy)
	tick_statuses()

func spend_energy(amount: int) -> bool:
	if current_energy < amount:
		return false
	current_energy -= amount
	energy_changed.emit(current_energy, max_energy)
	return true

func can_afford(cost: int) -> bool:
	return current_energy >= cost
