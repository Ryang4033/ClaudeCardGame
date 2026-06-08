class_name CombatHUD
extends Control

@onready var player_health_label: Label = $PlayerArea/PlayerHealth
@onready var player_block_label: Label = $PlayerArea/PlayerBlock
@onready var energy_label: Label = $PlayerArea/Energy
@onready var draw_pile_label: Label = $PileCounts/DrawPile
@onready var discard_pile_label: Label = $PileCounts/DiscardPile
@onready var end_turn_button: Button = $EndTurnButton
@onready var status_label: Label = $StatusLabel
@onready var enemy_health_label: Label = $EnemyArea/EnemyHealth
@onready var enemy_block_label: Label = $EnemyArea/EnemyBlock
@onready var enemy_intent_label: Label = $EnemyArea/EnemyIntent
@onready var enemy_name_label: Label = $EnemyArea/EnemyName

signal end_turn_pressed

func _ready() -> void:
	end_turn_button.pressed.connect(func(): end_turn_pressed.emit())

func connect_player(player: Player) -> void:
	player.health_changed.connect(_on_player_health_changed)
	player.block_changed.connect(_on_player_block_changed)
	player.energy_changed.connect(_on_energy_changed)
	_on_player_health_changed(player.current_health, player.max_health)
	_on_energy_changed(player.current_energy, player.max_energy)

func connect_enemy(enemy: Enemy) -> void:
	enemy.health_changed.connect(_on_enemy_health_changed)
	enemy.block_changed.connect(_on_enemy_block_changed)
	enemy.intent_changed.connect(_on_enemy_intent_changed)
	enemy_name_label.text = enemy.entity_name
	_on_enemy_health_changed(enemy.current_health, enemy.max_health)

func connect_deck_manager(dm: DeckManager) -> void:
	dm.draw_pile_changed.connect(func(c): draw_pile_label.text = "Draw: %d" % c)
	dm.discard_pile_changed.connect(func(c): discard_pile_label.text = "Disc: %d" % c)

func set_status(text: String) -> void:
	status_label.text = text

func set_interactable(enabled: bool) -> void:
	end_turn_button.disabled = not enabled

func _on_player_health_changed(current: int, maximum: int) -> void:
	player_health_label.text = "HP: %d/%d" % [current, maximum]

func _on_player_block_changed(amount: int) -> void:
	player_block_label.text = "Block: %d" % amount

func _on_energy_changed(current: int, maximum: int) -> void:
	energy_label.text = "Energy: %d/%d" % [current, maximum]

func _on_enemy_health_changed(current: int, maximum: int) -> void:
	enemy_health_label.text = "HP: %d/%d" % [current, maximum]

func _on_enemy_block_changed(amount: int) -> void:
	enemy_block_label.text = "Block: %d" % amount

func _on_enemy_intent_changed(action: Dictionary) -> void:
	var intent_text := ""
	match action.get("effect", ""):
		"damage":
			intent_text = "Attack %d" % action.get("value", 0)
		"block":
			intent_text = "Defend %d" % action.get("value", 0)
		"buff_strength":
			intent_text = "Buff Strength"
		"apply_vulnerable":
			intent_text = "Vulnerable"
		_:
			intent_text = "Unknown"
	enemy_intent_label.text = "Intent: " + intent_text
