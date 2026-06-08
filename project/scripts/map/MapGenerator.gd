class_name MapGenerator
extends RefCounted

const TYPE_WEIGHTS: Dictionary = {
	MapData.NodeType.COMBAT: 50,
	MapData.NodeType.ELITE:  10,
	MapData.NodeType.REST:   12,
	MapData.NodeType.SHOP:    8,
	MapData.NodeType.EVENT:  20,
}

func generate() -> MapData:
	var data := MapData.new()
	data.nodes = []
	var id_counter := 0
	var grid: Array = []  # grid[row] -> Array of MapNode

	# Build nodes row by row using the width profile
	for row in MapData.WIDTH_PROFILE.size():
		var width: int = MapData.WIDTH_PROFILE[row]
		var row_nodes: Array = []
		for slot in width:
			var type := _pick_type(row, slot, width)
			var node := MapData.MapNode.new(id_counter, type, row, slot)
			id_counter += 1
			row_nodes.append(node)
			data.nodes.append(node)
		grid.append(row_nodes)

	# Boss — single node at the end
	var boss_row: int = MapData.WIDTH_PROFILE.size()
	var boss := MapData.MapNode.new(id_counter, MapData.NodeType.BOSS, boss_row, 0)
	data.nodes.append(boss)
	grid.append([boss])

	# Wire connections: each row -> next row, no crossings
	for row in MapData.WIDTH_PROFILE.size():
		_connect_rows(grid[row], grid[row + 1])

	data.current_node_id = -1  # -1 means "not started yet"
	return data

# Maps each node in cur_row to 1-2 nodes in nxt_row using proportional
# slot mapping so paths never cross and the tree stays clean.
func _connect_rows(cur_row: Array, nxt_row: Array) -> void:
	var cw: int = cur_row.size()
	var nw: int = nxt_row.size()

	for i in cw:
		var node: MapData.MapNode = cur_row[i]

		# Proportionally map slot i -> target slot in next row
		var t: int
		if cw == 1:
			t = 0
		else:
			t = int(round(float(i) * float(nw - 1) / float(cw - 1)))

		_add_connection(node, nxt_row[t])

		# When the row is expanding, also connect to an adjacent slot
		# so each node branches into two paths
		if nw > cw:
			var t2: int = t + 1 if i < cw / 2 else t - 1
			if t2 >= 0 and t2 < nw and t2 != t:
				_add_connection(node, nxt_row[t2])

func _add_connection(from_node: MapData.MapNode, to_node: MapData.MapNode) -> void:
	if to_node.id not in from_node.connections:
		from_node.connections.append(to_node.id)

func _pick_type(row: int, _slot: int, _width: int) -> MapData.NodeType:
	if row in MapData.FORCED_TYPES:
		return MapData.FORCED_TYPES[row]
	return _weighted_random()

func _weighted_random() -> MapData.NodeType:
	var rng := RandomNumberGenerator.new()
	var total := 0
	for w: int in TYPE_WEIGHTS.values():
		total += w
	var roll: int = rng.randi_range(0, total - 1)
	var cumulative := 0
	for type: MapData.NodeType in TYPE_WEIGHTS:
		cumulative += TYPE_WEIGHTS[type]
		if roll < cumulative:
			return type
	return MapData.NodeType.COMBAT
