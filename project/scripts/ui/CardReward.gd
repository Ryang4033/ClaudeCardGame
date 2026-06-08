class_name CardReward
extends Control

signal card_chosen(card: CardData)
signal reward_skipped

@onready var card_container: HBoxContainer = $Panel/VBox/CardContainer
@onready var skip_button: Button = $Panel/VBox/SkipButton

var offered_cards: Array[CardData] = []

func _ready() -> void:
	skip_button.pressed.connect(func(): reward_skipped.emit())

func show_reward(cards: Array[CardData]) -> void:
	offered_cards = cards
	for child in card_container.get_children():
		child.queue_free()

	for card_data in cards:
		var btn := Button.new()
		btn.text = "%s\n(%s, Cost %d)\n%s" % [
			card_data.card_name,
			CardData.CardType.keys()[card_data.type],
			card_data.cost,
			card_data.description,
		]
		btn.custom_minimum_size = Vector2(160, 220)
		btn.pressed.connect(func(): card_chosen.emit(card_data))
		card_container.add_child(btn)

func _generate_reward(rarity_boost: float = 0.0) -> Array[CardData]:
	var all_cards: Array[String] = [
		"res://resources/cards/Strike.tres",
		"res://resources/cards/Defend.tres",
		"res://resources/cards/Bash.tres",
		"res://resources/cards/Anger.tres",
		"res://resources/cards/Cleave.tres",
		"res://resources/cards/IronWave.tres",
		"res://resources/cards/Thunderclap.tres",
		"res://resources/cards/ShrugItOff.tres",
		"res://resources/cards/Flex.tres",
		"res://resources/cards/Inflame.tres",
		"res://resources/cards/PommelStrike.tres",
		"res://resources/cards/BodySlam.tres",
	]
	all_cards.shuffle()
	var chosen: Array[CardData] = []
	for path in all_cards.slice(0, 3):
		chosen.append(load(path))
	return chosen
