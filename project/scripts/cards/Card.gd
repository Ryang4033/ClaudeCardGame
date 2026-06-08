class_name Card
extends Control

signal card_clicked(card: Card)
signal card_hovered(card: Card)
signal card_unhovered(card: Card)

@export var data: CardData

@onready var card_name_label: Label = $Layout/CardName
@onready var cost_label: Label = $Layout/Cost
@onready var description_label: Label = $Layout/Description
@onready var art_texture: TextureRect = $Layout/Art
@onready var type_label: Label = $Layout/Type

var original_position: Vector2
var is_hovered: bool = false
var is_dragging: bool = false
var drag_offset: Vector2

const HOVER_LIFT := -30.0
const HOVER_SCALE := Vector2(1.1, 1.1)

func setup(card_data: CardData) -> void:
	data = card_data
	card_name_label.text = data.card_name
	cost_label.text = str(data.cost)
	description_label.text = data.description
	type_label.text = CardData.CardType.keys()[data.type]
	if data.art:
		art_texture.texture = data.art

func _on_mouse_entered() -> void:
	is_hovered = true
	card_hovered.emit(self)
	var tween := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "position:y", original_position.y + HOVER_LIFT, 0.15)
	tween.parallel().tween_property(self, "scale", HOVER_SCALE, 0.15)
	z_index = 10

func _on_mouse_exited() -> void:
	is_hovered = false
	card_unhovered.emit(self)
	if not is_dragging:
		_return_to_original()

func _return_to_original() -> void:
	var tween := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SPRING)
	tween.tween_property(self, "position:y", original_position.y, 0.2)
	tween.parallel().tween_property(self, "scale", Vector2.ONE, 0.2)
	z_index = 0

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			card_clicked.emit(self)
