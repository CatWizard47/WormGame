class_name PathfindingNode extends Resource
var position: Vector2
var is_accesible: bool = true
var neighbours: Array	#contains other PathfindingNodes
var score: int
						#goes
						#[5]	[1]		[6]
						#[4]	[x]		[2]
						#[8]	[3]		[7]
func _init(new_position: Vector2, accesible: bool, new_score = 0)->void:
	position = new_position
	is_accesible = accesible
	score = new_score
