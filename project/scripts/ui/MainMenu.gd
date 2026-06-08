extends Control

@onready var new_run_button: Button = $Panel/VBox/NewRunButton
@onready var quit_button: Button = $Panel/VBox/QuitButton

func _ready() -> void:
	new_run_button.pressed.connect(_on_new_run)
	quit_button.pressed.connect(func(): get_tree().quit())

func _on_new_run() -> void:
	RunState.start_new_run()
	get_tree().change_scene_to_file("res://scenes/map/Map.tscn")
