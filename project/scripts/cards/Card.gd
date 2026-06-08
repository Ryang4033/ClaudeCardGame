class_name Card
extends Control

signal card_clicked(card: Card)
signal card_hovered(card: Card)
signal card_unhovered(card: Card)

var data: CardData

# UI nodes built in _ready — no @onready scene-path dependency
var _name_label: Label
var _cost_label: Label
var _type_label: Label
var _desc_label: Label

var original_position: Vector2
var is_dragging: bool = false

const HOVER_LIFT  := -28.0
const HOVER_SCALE := Vector2(1.08, 1.08)
const CARD_W      := 110.0
const CARD_H      := 160.0

const TYPE_COLORS := {
	0: Color(0.75, 0.18, 0.18),  # ATTACK  — red
	1: Color(0.18, 0.42, 0.72),  # SKILL   — blue
	2: Color(0.55, 0.20, 0.70),  # POWER   — purple
}

func _ready() -> void:
	custom_minimum_size = Vector2(CARD_W, CARD_H)
	size = Vector2(CARD_W, CARD_H)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_ui()
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _build_ui() -> void:
	# Card background panel
	var bg := PanelContainer.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 4)
	bg.add_child(vbox)

	# Cost bubble — top row
	var top_row := HBoxContainer.new()
	vbox.add_child(top_row)
	_cost_label = Label.new()
	_cost_label.text = "1"
	_cost_label.custom_minimum_size = Vector2(22, 22)
	_cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_cost_label.add_theme_color_override("font_color", Color.YELLOW)
	top_row.add_child(_cost_label)

	_name_label = Label.new()
	_name_label.text = "Card"
	_name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_name_label.add_theme_font_size_override("font_size", 11)
	_name_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	top_row.add_child(_name_label)

	# Art placeholder
	var art := ColorRect.new()
	art.custom_minimum_size = Vector2(0, 52)
	art.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	art.color = Color(0.15, 0.15, 0.20)
	vbox.add_child(art)

	# Type label
	_type_label = Label.new()
	_type_label.text = "ATTACK"
	_type_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_type_label.add_theme_font_size_override("font_size", 9)
	vbox.add_child(_type_label)

	# Description
	_desc_label = Label.new()
	_desc_label.text = ""
	_desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_desc_label.add_theme_font_size_override("font_size", 9)
	_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	_desc_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(_desc_label)

func setup(card_data: CardData) -> void:
	data = card_data
	_name_label.text = data.card_name
	_cost_label.text = str(data.cost)
	_desc_label.text = data.description
	var type_key: String = CardData.CardType.keys()[data.type]
	_type_label.text = type_key
	_type_label.add_theme_color_override("font_color",
		TYPE_COLORS.get(data.type, Color.WHITE))

func _on_mouse_entered() -> void:
	card_hovered.emit(self)
	var tween := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "position:y", original_position.y + HOVER_LIFT, 0.12)
	tween.parallel().tween_property(self, "scale", HOVER_SCALE, 0.12)
	z_index = 10

func _on_mouse_exited() -> void:
	card_unhovered.emit(self)
	_return_to_hand()

func _return_to_hand() -> void:
	var tween := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SPRING)
	tween.tween_property(self, "position:y", original_position.y, 0.18)
	tween.parallel().tween_property(self, "scale", Vector2.ONE, 0.18)
	z_index = 0

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			card_clicked.emit(self)
