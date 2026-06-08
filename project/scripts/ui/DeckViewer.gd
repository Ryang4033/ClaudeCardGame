extends Control

@onready var card_grid: GridContainer = $Panel/Scroll/CardGrid
@onready var title_label: Label = $Panel/Title
@onready var close_button: Button = $Panel/CloseButton

func _ready() -> void:
	close_button.pressed.connect(func(): hide())

func show_deck(cards: Array[CardData], label: String = "Deck") -> void:
	title_label.text = "%s (%d)" % [label, cards.size()]
	for child in card_grid.get_children():
		child.queue_free()

	for card in cards:
		var entry := _make_card_entry(card)
		card_grid.add_child(entry)
	show()

func _make_card_entry(card: CardData) -> PanelContainer:
	var panel := PanelContainer.new()
	var vbox := VBoxContainer.new()
	panel.custom_minimum_size = Vector2(130, 170)

	var name_lbl := Label.new()
	name_lbl.text = card.card_name
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD

	var cost_lbl := Label.new()
	cost_lbl.text = "Cost: %d" % card.cost
	cost_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	var type_lbl := Label.new()
	type_lbl.text = CardData.CardType.keys()[card.type]
	type_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	var desc_lbl := Label.new()
	desc_lbl.text = card.description
	desc_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	desc_lbl.add_theme_font_size_override("font_size", 10)

	vbox.add_child(name_lbl)
	vbox.add_child(cost_lbl)
	vbox.add_child(type_lbl)
	vbox.add_child(desc_lbl)
	panel.add_child(vbox)
	return panel
