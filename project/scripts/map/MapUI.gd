class_name MapUI
extends Control

signal node_selected(node: MapData.MapNode)

const NODE_COLORS: Dictionary = {
	MapData.NodeType.COMBAT: Color(0.85, 0.25, 0.25),
	MapData.NodeType.ELITE:  Color(0.85, 0.45, 0.05),
	MapData.NodeType.REST:   Color(0.25, 0.75, 0.35),
	MapData.NodeType.SHOP:   Color(0.90, 0.80, 0.10),
	MapData.NodeType.EVENT:  Color(0.35, 0.55, 0.95),
	MapData.NodeType.BOSS:   Color(0.65, 0.05, 0.85),
}

const NODE_LABELS: Dictionary = {
	MapData.NodeType.COMBAT: "S",
	MapData.NodeType.ELITE:  "E",
	MapData.NodeType.REST:   "R",
	MapData.NodeType.SHOP:   "$",
	MapData.NodeType.EVENT:  "?",
	MapData.NodeType.BOSS:   "B",
}

const H_SPACING  := 110.0   # horizontal gap between nodes in the same row
const V_SPACING  :=  48.0   # vertical gap between rows
const NODE_SIZE  :=  36.0   # button width/height
const CANVAS_W   := 1280.0  # logical screen width for centering
const BOTTOM_Y   := 660.0   # y of row 0 (start)

var map_data: MapData
var node_buttons: Dictionary = {}  # node id -> Button

func draw_map(data: MapData) -> void:
	map_data = data
	for child in get_children():
		child.queue_free()
	node_buttons.clear()

	# Lines behind buttons
	for node: MapData.MapNode in data.nodes:
		for target_id: int in node.connections:
			var target := _find_node(target_id)
			if target:
				_draw_connection(node, target)

	# Buttons on top
	for node: MapData.MapNode in data.nodes:
		_create_button(node)

	_refresh_accessibility()

func _create_button(node: MapData.MapNode) -> void:
	var btn := Button.new()
	var pos := _node_pos(node)
	btn.position = pos - Vector2(NODE_SIZE * 0.5, NODE_SIZE * 0.5)
	btn.custom_minimum_size = Vector2(NODE_SIZE, NODE_SIZE)
	btn.text = NODE_LABELS.get(node.type, "?")
	btn.tooltip_text = MapData.NodeType.keys()[node.type].capitalize()
	btn.self_modulate = NODE_COLORS.get(node.type, Color.WHITE)
	if node.completed:
		btn.self_modulate = btn.self_modulate.darkened(0.45)
	btn.pressed.connect(func(): node_selected.emit(node))
	add_child(btn)
	node_buttons[node.id] = btn

func _draw_connection(a: MapData.MapNode, b: MapData.MapNode) -> void:
	var line := Line2D.new()
	line.add_point(_node_pos(a))
	line.add_point(_node_pos(b))
	line.width = 2.5
	line.default_color = Color(0.55, 0.55, 0.55, 0.55)
	add_child(line)

# Returns the screen-space center of a node, centering each row.
func _node_pos(node: MapData.MapNode) -> Vector2:
	var width: int
	if node.type == MapData.NodeType.BOSS:
		width = 1
	else:
		width = MapData.WIDTH_PROFILE[node.row]

	var total_span := float(width - 1) * H_SPACING
	var row_start_x := (CANVAS_W - total_span) * 0.5
	var x := row_start_x + node.col * H_SPACING
	var y := BOTTOM_Y - node.row * V_SPACING
	return Vector2(x, y)

func _find_node(id: int) -> MapData.MapNode:
	for node: MapData.MapNode in map_data.nodes:
		if node.id == id:
			return node
	return null

func _refresh_accessibility() -> void:
	var reachable := _reachable_ids()
	for id: int in node_buttons:
		var btn: Button = node_buttons[id]
		btn.disabled = id not in reachable

func _reachable_ids() -> Array[int]:
	var current_id: int = map_data.current_node_id
	if current_id < 0:
		# Not started: only row-0 nodes are reachable
		var ids: Array[int] = []
		for node: MapData.MapNode in map_data.nodes:
			if node.row == 0:
				ids.append(node.id)
		return ids
	var current := _find_node(current_id)
	if current == null:
		return []
	return current.connections
