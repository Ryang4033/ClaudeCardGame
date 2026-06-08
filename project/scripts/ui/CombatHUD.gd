class_name CombatHUD
extends Control

signal end_turn_pressed

# Labels created in _ready — no @onready path dependency on scene structure.
var player_health_label: Label
var player_block_label: Label
var energy_label: Label
var draw_pile_label: Label
var discard_pile_label: Label
var end_turn_button: Button
var status_label: Label
var enemy_health_label: Label
var enemy_block_label: Label
var enemy_intent_label: Label
var enemy_name_label: Label

func _ready() -> void:
	_build_ui()

func _build_ui() -> void:
	# Enemy panel — top left
	var enemy_panel := _vbox(Vector2(20, 20), Vector2(220, 130))
	enemy_name_label   = _label(enemy_panel, "Enemy")
	enemy_health_label = _label(enemy_panel, "HP: —")
	enemy_block_label  = _label(enemy_panel, "Block: 0")
	enemy_intent_label = _label(enemy_panel, "Intent: ?")

	# Player panel — bottom left
	var player_panel := _vbox(Vector2(20, 560), Vector2(220, 140))
	player_health_label = _label(player_panel, "HP: —")
	player_block_label  = _label(player_panel, "Block: 0")
	energy_label        = _label(player_panel, "Energy: —")

	# Pile counts — bottom right
	var pile_row := _hbox(Vector2(1040, 630), Vector2(220, 30))
	draw_pile_label    = _label(pile_row, "Draw: 0")
	discard_pile_label = _label(pile_row, "Disc: 0")

	# End turn button — bottom right above piles
	end_turn_button = Button.new()
	end_turn_button.text = "End Turn"
	end_turn_button.position = Vector2(1060, 580)
	end_turn_button.custom_minimum_size = Vector2(180, 40)
	end_turn_button.pressed.connect(func(): end_turn_pressed.emit())
	add_child(end_turn_button)

	# Status label — top centre
	status_label = Label.new()
	status_label.position = Vector2(490, 12)
	status_label.custom_minimum_size = Vector2(300, 28)
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(status_label)

# ── helpers ──────────────────────────────────────────────────────────────────

func _vbox(pos: Vector2, size: Vector2) -> VBoxContainer:
	var c := VBoxContainer.new()
	c.position = pos
	c.custom_minimum_size = size
	add_child(c)
	return c

func _hbox(pos: Vector2, size: Vector2) -> HBoxContainer:
	var c := HBoxContainer.new()
	c.position = pos
	c.custom_minimum_size = size
	add_child(c)
	return c

func _label(parent: Control, default_text: String) -> Label:
	var l := Label.new()
	l.text = default_text
	parent.add_child(l)
	return l

# ── public API ────────────────────────────────────────────────────────────────

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
	dm.draw_pile_changed.connect(func(c: int): draw_pile_label.text = "Draw: %d" % c)
	dm.discard_pile_changed.connect(func(c: int): discard_pile_label.text = "Disc: %d" % c)

func set_status(text: String) -> void:
	status_label.text = text

func set_interactable(enabled: bool) -> void:
	end_turn_button.disabled = not enabled

# ── signal handlers ───────────────────────────────────────────────────────────

func _on_player_health_changed(current: int, maximum: int) -> void:
	player_health_label.text = "HP: %d / %d" % [current, maximum]

func _on_player_block_changed(amount: int) -> void:
	player_block_label.text = "Block: %d" % amount

func _on_energy_changed(current: int, maximum: int) -> void:
	energy_label.text = "Energy: %d / %d" % [current, maximum]

func _on_enemy_health_changed(current: int, maximum: int) -> void:
	enemy_health_label.text = "HP: %d / %d" % [current, maximum]

func _on_enemy_block_changed(amount: int) -> void:
	enemy_block_label.text = "Block: %d" % amount

func _on_enemy_intent_changed(action: Dictionary) -> void:
	var intent_text: String
	match action.get("effect", ""):
		"damage":        intent_text = "Attack %d"  % action.get("value", 0)
		"block":         intent_text = "Defend %d"  % action.get("value", 0)
		"buff_strength": intent_text = "Buff Strength"
		"apply_vulnerable": intent_text = "Vulnerable"
		_:               intent_text = "Unknown"
	enemy_intent_label.text = "Intent: " + intent_text
