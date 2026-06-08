class_name RelicData
extends Resource

enum Trigger {
	ON_COMBAT_START,
	ON_TURN_START,
	ON_TURN_END,
	ON_CARD_PLAYED,
	ON_TAKE_DAMAGE,
	ON_KILL,
	PASSIVE,
}

@export var relic_name: String = ""
@export var description: String = ""
@export var art: Texture2D
@export var trigger: Trigger = Trigger.PASSIVE

# Effect parameters — interpreted by RelicManager
@export var effect: String = ""
@export var value: int = 0
