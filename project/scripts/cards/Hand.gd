class_name Hand
extends Control

signal card_played(card: Card)

@export var card_scene: PackedScene
@export var max_hand_size: int = 10
@export var fan_spread_degrees: float = 30.0
@export var card_spacing: float = 120.0

var cards: Array[Card] = []

func add_card(data: CardData) -> void:
	if cards.size() >= max_hand_size:
		return
	var card: Card = card_scene.instantiate()
	add_child(card)
	card.setup(data)
	card.card_clicked.connect(_on_card_clicked)
	cards.append(card)
	_arrange_cards()

func remove_card(card: Card) -> void:
	cards.erase(card)
	card.queue_free()
	_arrange_cards()

func clear() -> void:
	for card in cards:
		card.queue_free()
	cards.clear()

func _arrange_cards() -> void:
	var count := cards.size()
	if count == 0:
		return

	var total_width := card_spacing * (count - 1)
	var start_x := -total_width / 2.0
	var angle_step := fan_spread_degrees / max(count - 1, 1)
	var start_angle := -fan_spread_degrees / 2.0

	for i in count:
		var card := cards[i]
		var target_x := start_x + i * card_spacing
		var angle := start_angle + i * angle_step if count > 1 else 0.0
		var target_pos := Vector2(target_x, deg_to_rad(abs(angle)) * 60.0)

		card.original_position = target_pos
		card.rotation_degrees = angle

		var tween := card.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		tween.tween_property(card, "position", target_pos, 0.25)

func _on_card_clicked(card: Card) -> void:
	card_played.emit(card)
