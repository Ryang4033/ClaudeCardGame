class_name RelicManager
extends Node

# Hooks into CombatManager signals and applies relic effects.

var player: Player
var relics: Array[RelicData] = []

func setup(p: Player, relic_list: Array[RelicData], combat_manager: CombatManager) -> void:
	player = p
	relics = relic_list
	combat_manager.turn_started.connect(_on_turn_started)
	combat_manager.card_resolved.connect(_on_card_played)

func _on_turn_started(state: CombatManager.State) -> void:
	if state == CombatManager.State.PLAYER_TURN:
		_trigger(RelicData.Trigger.ON_TURN_START)
	elif state == CombatManager.State.ENEMY_TURN:
		_trigger(RelicData.Trigger.ON_TURN_END)

func _on_card_played(_card: CardData) -> void:
	_trigger(RelicData.Trigger.ON_CARD_PLAYED)

func _trigger(trigger: RelicData.Trigger) -> void:
	for relic in relics:
		if relic.trigger == trigger:
			_apply(relic)

func _apply(relic: RelicData) -> void:
	match relic.effect:
		"gain_energy":
			player.current_energy = min(player.max_energy, player.current_energy + relic.value)
			player.energy_changed.emit(player.current_energy, player.max_energy)
		"draw_card":
			# Emit signal upward — CombatManager handles draw
			draw_requested.emit(relic.value)
		"gain_block":
			player.gain_block(relic.value)
		"heal":
			player.heal(relic.value)
		"gain_max_hp":
			player.max_health += relic.value
			player.heal(relic.value)

signal draw_requested(count: int)
