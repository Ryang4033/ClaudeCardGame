class_name CardData
extends Resource

enum CardType { ATTACK, SKILL, POWER }
enum CardRarity { BASIC, COMMON, UNCOMMON, RARE }

@export var card_name: String = ""
@export var description: String = ""
@export var cost: int = 1
@export var type: CardType = CardType.ATTACK
@export var rarity: CardRarity = CardRarity.COMMON
@export var art: Texture2D

# Effects are applied in order when the card is played.
# Each entry is a Dictionary: { "effect": String, "value": int }
@export var effects: Array[Dictionary] = []
