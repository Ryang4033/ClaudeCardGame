class_name EnemyView
extends Control

var _name_label: Label
var _hp_label: Label
var _block_label: Label
var _intent_label: Label
var _hp_bar: ColorRect
var _hp_fill: ColorRect

var _max_hp: int = 1

func _ready() -> void:
	custom_minimum_size = Vector2(160, 200)
	_build_ui()

func _build_ui() -> void:
	var bg := PanelContainer.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 6)
	bg.add_child(vbox)

	_name_label = Label.new()
	_name_label.text = "Enemy"
	_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_name_label.add_theme_font_size_override("font_size", 13)
	vbox.add_child(_name_label)

	# Art placeholder
	var art := ColorRect.new()
	art.custom_minimum_size = Vector2(0, 80)
	art.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	art.color = Color(0.25, 0.12, 0.12)
	vbox.add_child(art)

	# HP bar
	var bar_bg := ColorRect.new()
	bar_bg.custom_minimum_size = Vector2(0, 14)
	bar_bg.color = Color(0.25, 0.05, 0.05)
	bar_bg.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(bar_bg)

	_hp_fill = ColorRect.new()
	_hp_fill.color = Color(0.8, 0.15, 0.15)
	_hp_fill.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bar_bg.add_child(_hp_fill)

	_hp_label = Label.new()
	_hp_label.text = "HP: —"
	_hp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hp_label.add_theme_font_size_override("font_size", 11)
	vbox.add_child(_hp_label)

	_block_label = Label.new()
	_block_label.text = "Block: 0"
	_block_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_block_label.add_theme_font_size_override("font_size", 11)
	vbox.add_child(_block_label)

	_intent_label = Label.new()
	_intent_label.text = "Intent: ?"
	_intent_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_intent_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	_intent_label.add_theme_font_size_override("font_size", 11)
	vbox.add_child(_intent_label)

func bind(enemy: Enemy) -> void:
	_max_hp = enemy.max_health
	_name_label.text = enemy.entity_name
	_update_hp(enemy.current_health, enemy.max_health)
	_update_block(enemy.block)

	enemy.health_changed.connect(_update_hp)
	enemy.block_changed.connect(_update_block)
	enemy.intent_changed.connect(_update_intent)

func _update_hp(current: int, maximum: int) -> void:
	_max_hp = maximum
	_hp_label.text = "HP: %d / %d" % [current, maximum]
	_hp_fill.scale.x = float(current) / float(maximum) if maximum > 0 else 0.0

func _update_block(amount: int) -> void:
	_block_label.text = "Block: %d" % amount

func _update_intent(action: Dictionary) -> void:
	var text: String
	match action.get("effect", ""):
		"damage":           text = "Attack %d" % action.get("value", 0)
		"block":            text = "Defend %d" % action.get("value", 0)
		"buff_strength":    text = "Buff Strength"
		"apply_vulnerable": text = "Vulnerable"
		_:                  text = "?"
	_intent_label.text = "Intent: " + text
