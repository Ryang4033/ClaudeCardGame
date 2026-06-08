class_name CombatManager
extends Node

signal state_changed(state: State)
signal turn_started(state: State)
signal combat_ended(player_won: bool)
signal card_resolved(card_data: CardData)
signal status_message(text: String)

enum State { PLAYER_TURN, ENEMY_TURN, WIN, LOSE }

const CARDS_PER_TURN := 5

@onready var effect_resolver: EffectResolver = $EffectResolver
@onready var deck_manager: DeckManager = $DeckManager

var player: Player
var enemies: Array[Enemy] = []
var hand: Hand

var state: State = State.PLAYER_TURN

func setup(p: Player, e: Array[Enemy], h: Hand, deck: Array[CardData]) -> void:
	player = p
	enemies = e
	hand = h

	deck_manager.build_deck(deck)

	effect_resolver.draw_requested.connect(_on_draw_requested)
	effect_resolver.energy_requested.connect(_on_energy_requested)

	for enemy in enemies:
		enemy.died.connect(_on_enemy_died.bind(enemy))

	player.died.connect(_on_player_died)

	_begin_player_turn()

func _begin_player_turn() -> void:
	state = State.PLAYER_TURN
	state_changed.emit(state)
	player.start_turn()
	_draw_cards(CARDS_PER_TURN)
	turn_started.emit(state)
	status_message.emit("Your turn")

func end_player_turn() -> void:
	if state != State.PLAYER_TURN:
		return
	_discard_hand()
	_begin_enemy_turn()

func play_card(card: Card) -> void:
	if state != State.PLAYER_TURN:
		return
	var data := card.data
	if not player.can_afford(data.cost):
		status_message.emit("Not enough energy!")
		return

	player.spend_energy(data.cost)

	var target: CombatEntity = enemies[0] if not enemies.is_empty() else player
	effect_resolver.resolve(data.effects, player, target)

	hand.remove_card(card)
	deck_manager.discard(data)
	card_resolved.emit(data)

func _begin_enemy_turn() -> void:
	state = State.ENEMY_TURN
	state_changed.emit(state)
	turn_started.emit(state)
	status_message.emit("Enemy turn")

	for enemy in enemies:
		enemy.start_turn()
		enemy.execute_action(player)
		enemy.end_turn()

	if state != State.LOSE:
		_begin_player_turn()

func _draw_cards(count: int) -> void:
	var drawn := deck_manager.draw(count)
	for card_data in drawn:
		hand.add_card(card_data)

func _discard_hand() -> void:
	for card in hand.cards.duplicate():
		deck_manager.discard(card.data)
	hand.clear()

func _on_draw_requested(count: int) -> void:
	_draw_cards(count)

func _on_energy_requested(amount: int) -> void:
	player.current_energy = min(player.max_energy, player.current_energy + amount)
	player.energy_changed.emit(player.current_energy, player.max_energy)

func _on_enemy_died(enemy: Enemy) -> void:
	enemies.erase(enemy)
	if enemies.is_empty():
		state = State.WIN
		state_changed.emit(state)
		combat_ended.emit(true)
		status_message.emit("Victory!")

func _on_player_died() -> void:
	state = State.LOSE
	state_changed.emit(state)
	combat_ended.emit(false)
	status_message.emit("Defeated...")
