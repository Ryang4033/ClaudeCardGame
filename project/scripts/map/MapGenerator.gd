class_name MapGenerator
extends RefCounted

# Generates a StS-style map: paths from row 0 to boss row,
# with guaranteed rest sites and elites placed by probability.

const TYPE_WEIGHTS := {
	MapData.NodeType.COMBAT: 45,
	MapData.NodeType.ELITE: 8,
	MapData.NodeType.REST: 12,
	MapData.NodeType.SHOP: 5,
	MapData.NodeType.EVENT: 22,
}

# Rows that are always a specific type (0-indexed)
const FORCED_TYPES := {
	8: MapData.NodeType.REST,    # midpoint rest
}

func generate() -> MapData:
	var data := MapData.new()
	data.nodes = []
	var id_counter := 0

	# Generate nodes row by row
	var grid: Array = []  # grid[row] = Array of MapNode
	for row in MapData.ROWS:
		var row_nodes: Array = []
		var cols_used := _pick_cols_for_row(row)
		for col in cols_used:
			var type := _pick_type(row)
			var node := MapData.MapNode.new(id_counter, type, row, col)
			id_counter += 1
			row_nodes.append(node)
			data.nodes.append(node)
		grid.append(row_nodes)

	# Boss node
	var boss := MapData.MapNode.new(id_counter, MapData.NodeType.BOSS, MapData.BOSS_ROW, 3)
	data.nodes.append(boss)
	grid.append([boss])

	# Connect rows
	for row in MapData.ROWS:
		var current_row: Array = grid[row]
		var next_row: Array = grid[row + 1]
		for node in current_row:
			# Connect to 1-2 nodes in next row, biased toward same column
			var targets := _pick_connections(node, next_row)
			for t in targets:
				if t.id not in node.connections:
					node.connections.append(t.id)

	data.current_node_id = grid[0][0].id
	return data

func _pick_cols_for_row(row: int) -> Array[int]:
	var rng := RandomNumberGenerator.new()
	var count := rng.randi_range(3, 6)
	var cols: Array[int] = []
	while cols.size() < count:
		var c := rng.randi_range(0, MapData.COLS - 1)
		if c not in cols:
			cols.append(c)
	cols.sort()
	return cols

func _pick_type(row: int) -> MapData.NodeType:
	if row in FORCED_TYPES:
		return FORCED_TYPES[row]
	var rng := RandomNumberGenerator.new()
	var total := 0
	for w in TYPE_WEIGHTS.values():
		total += w
	var roll := rng.randi_range(0, total - 1)
	var cumulative := 0
	for type in TYPE_WEIGHTS:
		cumulative += TYPE_WEIGHTS[type]
		if roll < cumulative:
			return type
	return MapData.NodeType.COMBAT

func _pick_connections(node: MapData.MapNode, next_row: Array) -> Array:
	if next_row.is_empty():
		return []
	var rng := RandomNumberGenerator.new()
	# Find the closest node in next row by column
	var sorted := next_row.duplicate()
	sorted.sort_custom(func(a, b): return abs(a.col - node.col) < abs(b.col - node.col))
	var count := min(rng.randi_range(1, 2), sorted.size())
	return sorted.slice(0, count)
