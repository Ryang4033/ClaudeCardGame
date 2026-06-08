extends Control

@onready var rest_button: Button = $Panel/VBox/RestButton
@onready var smith_button: Button = $Panel/VBox/SmithButton
@onready var status_label: Label = $Panel/VBox/StatusLabel

func _ready() -> void:
	rest_button.pressed.connect(_on_rest)
	smith_button.pressed.connect(_on_smith)
	_refresh()

func _refresh() -> void:
	var can_rest := RunState.player_current_health < RunState.player_max_health
	rest_button.disabled = not can_rest
	rest_button.text = "Rest (Heal 30%% HP)"

func _on_rest() -> void:
	var heal_amount := int(RunState.player_max_health * 0.30)
	RunState.player_current_health = min(
		RunState.player_max_health,
		RunState.player_current_health + heal_amount
	)
	status_label.text = "Healed %d HP." % heal_amount
	rest_button.disabled = true

func _on_smith() -> void:
	# Placeholder: open deck viewer to upgrade a card
	status_label.text = "Card upgrade not yet implemented."
