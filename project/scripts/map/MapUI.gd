class_name MapUI
extends Control

signal node_selected(node: MapData.MapNode)

const NODE_COLORS := {
	MapData.NodeType.COMBAT: Color(0.8, 0.2, 0.2),
	MapData.NodeType.ELITE: Color(0.8, 0.4, 0.0),
	MapData.NodeType.REST: Color(0.2, 0.7, 0.3),
	MapData.NodeType.SHOP: Color(0.9, 0.8, 0.1),
	MapData.NodeType.EVENT: Color(0.3, 0.5, 0.9),
	MapData.NodeType.BOSS: Color(0.6, 0.0, 0.8),
}

const NODE_LABELS := {
	MapData.NodeType.COMBAT: "⚔",
	MapData.NodeType.ELITE: "💀",
	MapData.NodeType.REST: "🔥",
	MapData.NodeType.SHOP: "$",
	MapData.NodeType.EVENT: "?",
	MapData.NodeType.BOSS: "★",
}

const H_SPACING := 160.0
const V_SPACING := 44.0
const NODE_RADIUS := 18.0

var map_data: MapData
var node_buttons: Dictionary = {}  # node id -> Button

func draw_map(data: MapData) -> void:
	map_data = data
	for child in get_children():
		child.queue_free()
	node_buttons.clear()

	# Draw connection lines first (behind buttons)
	for node in data.nodes:
		for target_id in node.connections:
			var target := _find_node(target_id)
			if target:
				_draw_line_between(node, target)

	# Draw node buttons
	for node in data.nodes:
		_create_node_button(node)

	_refresh_accessibility(data.current_node_id)

func _create_node_button(node: MapData.MapNode) -> void:
	var btn := Button.new()
	var pos := _node_to_screen(node)
	btn.position = pos - Vector2(NODE_RADIUS, NODE_RADIUS)
	btn.custom_minimum_size = Vector2(NODE_RADIUS * 2, NODE_RADIUS * 2)
	btn.text = NODE_LABELS.get(node.type, "?")
	btn.tooltip_text = MapData.NodeType.keys()[node.type]
	btn.self_modulate = NODE_COLORS.get(node.type, Color.WHITE)
	btn.pressed.connect(func(): node_selected.emit(node))
	add_child(btn)
	node_buttons[node.id] = btn

func _draw_line_between(a: MapData.MapNode, b: MapData.MapNode) -> void:
	var line := Line2D.new()
	line.add_point(_node_to_screen(a))
	line.add_point(_node_to_screen(b))
	line.width = 2.0
	line.default_color = Color(0.5, 0.5, 0.5, 0.6)
	add_child(line)

func _node_to_screen(node: MapData.MapNode) -> Vector2:
	return Vector2(
		60.0 + node.col * H_SPACING,
		600.0 - node.row * V_SPACING
	)

func _find_node(id: int) -> MapData.MapNode:
	for node in map_data.nodes:
		if node.id == id:
			return node
	return null

func _refresh_accessibility(current_id: int) -> void:
	var reachable := _get_reachable_ids(current_id)
	for id in node_buttons:
		var btn: Button = node_buttons[id]
		btn.disabled = id not in reachable

func _get_reachable_ids(current_id: int) -> Array[int]:
	if current_id < 0:
		# First move: return all nodes in row 0
		var ids: Array[int] = []
		for node in map_data.nodes:
			if node.row == 0:
				ids.append(node.id)
		return ids
	var current := _find_node(current_id)
	if current == null:
		return []
	return current.connections
