extends Node

@onready var map_ui: MapUI = $ScrollContainer/MapUI
@onready var act_label: Label = $ActLabel

var map_data: MapData

func _ready() -> void:
	if RunState.map_data == null:
		RunState.map_data = MapGenerator.new().generate()
	map_data = RunState.map_data
	map_ui.draw_map(map_data)
	act_label.text = "Act %d" % map_data.act
	map_ui.node_selected.connect(_on_node_selected)

func _on_node_selected(node: MapData.MapNode) -> void:
	map_data.current_node_id = node.id
	node.completed = true
	map_ui.draw_map(map_data)

	match node.type:
		MapData.NodeType.COMBAT, MapData.NodeType.ELITE, MapData.NodeType.BOSS:
			get_tree().change_scene_to_file("res://scenes/combat/Combat.tscn")
		MapData.NodeType.REST:
			_show_rest_options()
		MapData.NodeType.SHOP:
			get_tree().change_scene_to_file("res://scenes/ui/Shop.tscn")
		MapData.NodeType.EVENT:
			get_tree().change_scene_to_file("res://scenes/ui/Event.tscn")

func _show_rest_options() -> void:
	# Placeholder: in full game this opens a rest site UI
	pass
