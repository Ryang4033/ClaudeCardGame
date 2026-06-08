class_name MapData
extends Resource

enum NodeType { COMBAT, ELITE, REST, SHOP, EVENT, BOSS }

class MapNode:
	var id: int
	var type: NodeType
	var row: int
	var col: int  # slot index within this row (0..width-1)
	var connections: Array[int] = []  # ids of nodes this connects forward to
	var completed: bool = false

	func _init(i: int, t: NodeType, r: int, c: int) -> void:
		id = i
		type = t
		row = r
		col = c

var nodes: Array  # Array[MapNode]
var current_node_id: int = -1
var act: int = 1

# Width of each row. Expands then collapses — single start, single boss.
# Row index matches position in this array; boss is appended after.
const WIDTH_PROFILE: Array[int] = [1, 2, 3, 4, 5, 6, 5, 4, 3, 4, 5, 4, 3, 2, 1]

# Row indices that are always a fixed type (0-indexed into WIDTH_PROFILE)
const FORCED_TYPES: Dictionary = {
	0: NodeType.COMBAT,   # always start with a fight
	7: NodeType.REST,     # mid-act breather
	14: NodeType.COMBAT,  # pre-boss fight
}
