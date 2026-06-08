class_name Card
extends Control

signal card_clicked(card: Card)
signal card_hovered(card: Card)
signal card_unhovered(card: Card)

var data: CardData

var _name_label: Label
var _cost_label: Label
var _type_label: Label
var _desc_label: Label
var _btn: Button  # invisible full-size button — reliable click target

var original_position: Vector2

const HOVER_LIFT  := -28.0
const HOVER_SCALE := Vector2(1.08, 1.08)
const CARD_W      := 110.0
const CARD_H      := 160.0

const TYPE_COLORS := {
	0: Color(0.75, 0.18, 0.18),  # ATTACK
	1: Color(0.18, 0.42, 0.72),  # SKILL
	2: Color(0.55, 0.20, 0.70),  # POWER
}

func _ready() -> void:
	custom_minimum_size = Vector2(CARD_W, CARD_H)
	size = Vector2(CARD_W, CARD_H)
	mouse_filter = Control.MOUSE_FILTER_IGNORE  # let button handle all input
	_build_ui()

func _build_ui() -> void:
	# ── Visual layer ─────────────────────────────────────────────────────────
	var bg := PanelContainer.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 4)
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg.add_child(vbox)

	var top_row := HBoxContainer.new()
	top_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(top_row)

	_cost_label = _make_label("1", 11, Color.YELLOW)
	_cost_label.custom_minimum_size = Vector2(22, 22)
	top_row.add_child(_cost_label)

	_name_label = _make_label("Card", 11)
	_name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_name_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	top_row.add_child(_name_label)

	var art := ColorRect.new()
	art.custom_minimum_size = Vector2(0, 52)
	art.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	art.color = Color(0.15, 0.15, 0.20)
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(art)

	_type_label = _make_label("ATTACK", 9)
	vbox.add_child(_type_label)

	_desc_label = _make_label("", 9)
	_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	_desc_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(_desc_label)

	# ── Input layer — transparent Button on top ───────────────────────────────
	_btn = Button.new()
	_btn.flat = true                               # no visual styling
	_btn.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_btn.focus_mode = Control.FOCUS_NONE
	# Make button transparent (no background, no text)
	var style := StyleBoxEmpty.new()
	_btn.add_theme_stylebox_override("normal",   style)
	_btn.add_theme_stylebox_override("hover",    style)
	_btn.add_theme_stylebox_override("pressed",  style)
	_btn.add_theme_stylebox_override("disabled", style)
	_btn.pressed.connect(func(): card_clicked.emit(self))
	_btn.mouse_entered.connect(_on_hover_enter)
	_btn.mouse_exited.connect(_on_hover_exit)
	add_child(_btn)

func _make_label(text: String, font_size: int, color: Color = Color.WHITE) -> Label:
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", color)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l

func setup(card_data: CardData) -> void:
	data = card_data
	_name_label.text = data.card_name
	_cost_label.text = str(data.cost)
	_desc_label.text = data.description
	_type_label.text = CardData.CardType.keys()[data.type]
	_type_label.add_theme_color_override("font_color",
		TYPE_COLORS.get(data.type, Color.WHITE))

func _on_hover_enter() -> void:
	card_hovered.emit(self)
	var t := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	t.tween_property(self, "position:y", original_position.y + HOVER_LIFT, 0.12)
	t.parallel().tween_property(self, "scale", HOVER_SCALE, 0.12)
	z_index = 10

func _on_hover_exit() -> void:
	card_unhovered.emit(self)
	var t := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SPRING)
	t.tween_property(self, "position:y", original_position.y, 0.18)
	t.parallel().tween_property(self, "scale", Vector2.ONE, 0.18)
	z_index = 0
