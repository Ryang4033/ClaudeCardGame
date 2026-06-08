class_name EnemyView
extends Control

var _name_label: Label
var _hp_label: Label
var _block_label: Label
var _intent_label: Label
var _hp_fill: ColorRect
var _status_display: StatusEffectDisplay
var _enemy: Enemy

func _ready() -> void:
	custom_minimum_size = Vector2(180, 230)
	_build_ui()

func _build_ui() -> void:
	var bg := PanelContainer.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 5)
	bg.add_child(vbox)

	_name_label = _label(vbox, "Enemy", 13)

	var art := ColorRect.new()
	art.custom_minimum_size = Vector2(0, 70)
	art.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	art.color = Color(0.25, 0.12, 0.12)
	vbox.add_child(art)

	# HP bar
	var bar_bg := ColorRect.new()
	bar_bg.custom_minimum_size = Vector2(0, 12)
	bar_bg.color = Color(0.22, 0.04, 0.04)
	bar_bg.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(bar_bg)
	_hp_fill = ColorRect.new()
	_hp_fill.color = Color(0.82, 0.15, 0.15)
	_hp_fill.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bar_bg.add_child(_hp_fill)

	_hp_label    = _label(vbox, "HP: —",     11)
	_block_label = _label(vbox, "Block: 0",  11)
	_intent_label = _label(vbox, "Intent: ?", 11)
	_intent_label.autowrap_mode = TextServer.AUTOWRAP_WORD

	# Status chips row
	_status_display = StatusEffectDisplay.new()
	_status_display.add_theme_constant_override("separation", 4)
	_status_display.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(_status_display)

func bind(enemy: Enemy) -> void:
	_enemy = enemy
	_name_label.text = enemy.entity_name
	_update_hp(enemy.current_health, enemy.max_health)
	_update_block(enemy.block)

	enemy.health_changed.connect(_update_hp)
	enemy.block_changed.connect(_update_block)
	enemy.intent_changed.connect(_update_intent)
	enemy.status_applied.connect(_on_status_applied)

	_status_display.bind(enemy)

	# Show initial intent
	if not enemy.next_action.is_empty():
		_update_intent(enemy.next_action)

func _update_hp(current: int, maximum: int) -> void:
	_hp_label.text = "HP: %d / %d" % [current, maximum]
	_hp_fill.scale.x = float(current) / float(maximum) if maximum > 0 else 0.0

func _update_block(amount: int) -> void:
	_block_label.text = "Block: %d" % amount

func _update_intent(action: Dictionary) -> void:
	var text: String
	match action.get("effect", ""):
		"damage":
			var base: int = action.get("value", 0)
			var total: int = base + (_enemy.get_strength() if _enemy else 0)
			text = "Attack %d" % total
		"block":
			text = "Defend %d" % action.get("value", 0)
		"buff_strength":
			text = "Buff Strength +%d" % action.get("value", 0)
		"apply_vulnerable":
			text = "Vulnerable %d" % action.get("value", 0)
		_:
			text = "?"
	_intent_label.text = "Intent: " + text

func _on_status_applied(_s: String, _v: int) -> void:
	if _enemy:
		_update_intent(_enemy.next_action)

func _label(parent: Control, text: String, font_size: int) -> Label:
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", font_size)
	parent.add_child(l)
	return l
