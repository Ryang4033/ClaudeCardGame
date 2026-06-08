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

var _reward_screen: CardReward

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
	combat_manager.combat_ended.connect(_on_combat_ended)
	hand.card_played.connect(combat_manager.play_card)

	combat_manager.setup(player, [enemy_node], hand, RunState.deck)

func _on_state_changed(state: CombatManager.State) -> void:
	hud.set_interactable(state == CombatManager.State.PLAYER_TURN)

func _on_combat_ended(player_won: bool) -> void:
	hud.set_interactable(false)
	if player_won:
		_show_card_reward()
	else:
		# Defeated — short delay then return to main menu
		await get_tree().create_timer(1.8).timeout
		get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")

func _show_card_reward() -> void:
	_reward_screen = CardReward.new()
	get_tree().current_scene.add_child(_reward_screen)
	_reward_screen.card_chosen.connect(_on_reward_card_chosen)
	_reward_screen.reward_skipped.connect(_on_reward_skipped)
	_reward_screen.hide()
	await get_tree().process_frame
	_reward_screen.open()

func _on_reward_card_chosen(card: CardData) -> void:
	RunState.add_card(card)
	_go_to_map()

func _on_reward_skipped() -> void:
	_go_to_map()

func _go_to_map() -> void:
	RunState.save_player_health(player.current_health, player.max_health)
	get_tree().change_scene_to_file("res://scenes/map/Map.tscn")

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
