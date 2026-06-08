## Autoload singleton — persists across scene changes for the duration of a run.
extends Node

var player_max_health: int = 80
var player_current_health: int = 80
var deck: Array[CardData] = []
var relics: Array[RelicData] = []
var gold: int = 99
var map_data: MapData = null
var floor_number: int = 0
var act: int = 1

func start_new_run() -> void:
	player_max_health = 80
	player_current_health = 80
	gold = 99
	floor_number = 0
	act = 1
	relics.clear()
	map_data = null
	deck = _build_starter_deck()

func save_player_health(current: int, maximum: int) -> void:
	player_current_health = current
	player_max_health = maximum

func add_card(card: CardData) -> void:
	deck.append(card)

func remove_card(card: CardData) -> void:
	deck.erase(card)

func add_relic(relic: RelicData) -> void:
	relics.append(relic)

func spend_gold(amount: int) -> bool:
	if gold < amount:
		return false
	gold -= amount
	return true

func _build_starter_deck() -> Array[CardData]:
	var d: Array[CardData] = []
	for _i in 5:
		d.append(load("res://resources/cards/Strike.tres"))
	for _i in 4:
		d.append(load("res://resources/cards/Defend.tres"))
	d.append(load("res://resources/cards/Bash.tres"))
	return d
