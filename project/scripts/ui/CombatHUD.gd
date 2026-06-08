class_name CombatHUD
extends Control

signal end_turn_pressed

var player_health_label: Label
var player_block_label: Label
var energy_label: Label
var draw_pile_label: Label
var discard_pile_label: Label
var end_turn_button: Button
var status_label: Label
var _player_status_display: StatusEffectDisplay

func _ready() -> void:
	_build_ui()

func _build_ui() -> void:
	# Player panel — bottom left
	var player_panel := _vbox(Vector2(20, 490), Vector2(230, 210))
	player_health_label = _label(player_panel, "HP: —")
	player_block_label  = _label(player_panel, "Block: 0")
	energy_label        = _label(player_panel, "Energy: —")

	_player_status_display = StatusEffectDisplay.new()
	_player_status_display.add_theme_constant_override("separation", 4)
	player_panel.add_child(_player_status_display)

	# Pile counts — bottom right
	var pile_row := _hbox(Vector2(1040, 630), Vector2(220, 30))
	draw_pile_label    = _label(pile_row, "Draw: 0")
	discard_pile_label = _label(pile_row, "Disc: 0")

	# End turn button — bottom right
	end_turn_button = Button.new()
	end_turn_button.text = "End Turn"
	end_turn_button.position = Vector2(1060, 580)
	end_turn_button.custom_minimum_size = Vector2(180, 40)
	end_turn_button.pressed.connect(func(): end_turn_pressed.emit())
	add_child(end_turn_button)

	# Turn status message — top centre
	status_label = Label.new()
	status_label.position = Vector2(490, 12)
	status_label.custom_minimum_size = Vector2(300, 28)
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(status_label)

# ── helpers ───────────────────────────────────────────────────────────────────

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
	_player_status_display.bind(player)

func connect_enemy(_enemy: Enemy) -> void:
	pass  # Enemy display is handled entirely by EnemyView

func connect_deck_manager(dm: DeckManager) -> void:
	dm.draw_pile_changed.connect(func(c: int): draw_pile_label.text = "Draw: %d" % c)
	dm.discard_pile_changed.connect(func(c: int): discard_pile_label.text = "Disc: %d" % c)

func set_status(text: String) -> void:
	status_label.text = text

func set_interactable(enabled: bool) -> void:
	end_turn_button.disabled = not enabled

# ── signal handlers ───────────────────────────────────────────────────────────

func _on_player_health_changed(current: int, maximum: int) -> void:
	if player_health_label:
		player_health_label.text = "HP: %d / %d" % [current, maximum]

func _on_player_block_changed(amount: int) -> void:
	if player_block_label:
		player_block_label.text = "Block: %d" % amount

func _on_energy_changed(current: int, maximum: int) -> void:
	if energy_label:
		energy_label.text = "Energy: %d / %d" % [current, maximum]
