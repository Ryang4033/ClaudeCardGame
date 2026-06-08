class_name CardReward
extends Control

signal card_chosen(card: CardData)
signal reward_skipped

const ALL_CARDS: Array[String] = [
	"res://resources/cards/Anger.tres",
	"res://resources/cards/Bash.tres",
	"res://resources/cards/BodySlam.tres",
	"res://resources/cards/Cleave.tres",
	"res://resources/cards/Defend.tres",
	"res://resources/cards/Flex.tres",
	"res://resources/cards/Inflame.tres",
	"res://resources/cards/IronWave.tres",
	"res://resources/cards/PommelStrike.tres",
	"res://resources/cards/ShrugItOff.tres",
	"res://resources/cards/Strike.tres",
	"res://resources/cards/Thunderclap.tres",
]

var _card_container: HBoxContainer

func _ready() -> void:
	# Fill screen with a dim overlay
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	var dim := ColorRect.new()
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0, 0, 0, 0.72)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dim)

	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left   = -380.0
	panel.offset_top    = -160.0
	panel.offset_right  =  380.0
	panel.offset_bottom =  160.0
	add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 16)
	panel.add_child(vbox)

	var title := Label.new()
	title.text = "Choose a Card"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 18)
	vbox.add_child(title)

	_card_container = HBoxContainer.new()
	_card_container.add_theme_constant_override("separation", 16)
	_card_container.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(_card_container)

	var skip_btn := Button.new()
	skip_btn.text = "Skip"
	skip_btn.pressed.connect(func(): reward_skipped.emit())
	vbox.add_child(skip_btn)

func open() -> void:
	var pool := ALL_CARDS.duplicate()
	pool.shuffle()
	var offered: Array[CardData] = []
	for path: String in pool.slice(0, 3):
		offered.append(load(path) as CardData)
	_populate(offered)
	show()

func _populate(cards: Array[CardData]) -> void:
	for child in _card_container.get_children():
		child.queue_free()

	for card_data: CardData in cards:
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(170, 220)
		btn.text = "%s\nCost: %d  |  %s\n\n%s" % [
			card_data.card_name,
			card_data.cost,
			CardData.CardType.keys()[card_data.type],
			card_data.description,
		]
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD
		btn.pressed.connect(func(): card_chosen.emit(card_data))
		_card_container.add_child(btn)
