extends Node

@onready var combat_manager: CombatManager = $CombatManager
@onready var player: Player = $Player
@onready var enemy_node: Enemy = $Enemy
@onready var hand: Hand = $Hand
@onready var hud: CombatHUD = $HUD

func _ready() -> void:
	# Defer one frame so every node's _ready() has finished before we wire
	# signals and call methods that depend on child state (e.g. HUD labels).
	await get_tree().process_frame
	_setup()

func _setup() -> void:
	var enemy_data := _make_cultist()
	enemy_node.setup(enemy_data)

	# Enemy visual — centred in the upper half of the screen
	var enemy_view := EnemyView.new()
	get_tree().current_scene.add_child(enemy_view)
	enemy_view.position = Vector2(560, 80)
	enemy_view.bind(enemy_node)

	hud.connect_player(player)
	hud.connect_enemy(enemy_node)
	hud.connect_deck_manager(combat_manager.deck_manager)
	hud.end_turn_pressed.connect(combat_manager.end_player_turn)

	combat_manager.status_message.connect(hud.set_status)
	combat_manager.state_changed.connect(_on_state_changed)
	combat_manager.card_resolved.connect(_on_card_resolved)
	hand.card_played.connect(combat_manager.play_card)

	var deck := _build_starter_deck()
	combat_manager.setup(player, [enemy_node], hand, deck)

func _on_state_changed(state: CombatManager.State) -> void:
	hud.set_interactable(state == CombatManager.State.PLAYER_TURN)

func _on_card_resolved(_data: CardData) -> void:
	pass

func _build_starter_deck() -> Array[CardData]:
	var deck: Array[CardData] = []
	for _i in 5:
		deck.append(load("res://resources/cards/Strike.tres"))
	for _i in 4:
		deck.append(load("res://resources/cards/Defend.tres"))
	deck.append(load("res://resources/cards/Bash.tres"))
	return deck

func _make_cultist() -> EnemyData:
	var data := EnemyData.new()
	data.enemy_name = "Cultist"
	data.max_health = 48
	data.action_pattern = [
		{"effect": "buff_strength", "value": 3},
		{"effect": "damage", "value": 6},
		{"effect": "damage", "value": 6},
		{"effect": "damage", "value": 6},
	]
	return data
