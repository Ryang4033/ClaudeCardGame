class_name MapData
extends Resource

enum NodeType { COMBAT, ELITE, REST, SHOP, EVENT, BOSS }

class MapNode:
	var id: int
	var type: NodeType
	var row: int
	var col: int
	var connections: Array[int] = []  # ids of nodes this connects to (next row)
	var completed: bool = false

	func _init(i: int, t: NodeType, r: int, c: int) -> void:
		id = i
		type = t
		row = r
		col = c

var nodes: Array  # Array of MapNode
var current_node_id: int = -1
var act: int = 1

const ROWS := 15
const COLS := 7
const BOSS_ROW := 15
