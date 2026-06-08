class_name DeckManager
extends Node

signal draw_pile_changed(count: int)
signal discard_pile_changed(count: int)

var draw_pile: Array[CardData] = []
var discard_pile: Array[CardData] = []

func build_deck(card_data_list: Array[CardData]) -> void:
	draw_pile = card_data_list.duplicate()
	discard_pile.clear()
	shuffle_draw_pile()

func shuffle_draw_pile() -> void:
	draw_pile.shuffle()
	draw_pile_changed.emit(draw_pile.size())

func draw(count: int) -> Array[CardData]:
	var drawn: Array[CardData] = []
	for i in count:
		if draw_pile.is_empty():
			if discard_pile.is_empty():
				break
			_reshuffle_discard_into_draw()
		if not draw_pile.is_empty():
			drawn.append(draw_pile.pop_back())
	draw_pile_changed.emit(draw_pile.size())
	return drawn

func discard(card_data: CardData) -> void:
	discard_pile.append(card_data)
	discard_pile_changed.emit(discard_pile.size())

func _reshuffle_discard_into_draw() -> void:
	draw_pile = discard_pile.duplicate()
	discard_pile.clear()
	shuffle_draw_pile()
	discard_pile_changed.emit(discard_pile.size())
