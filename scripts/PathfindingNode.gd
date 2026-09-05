class_name PathfindingNode extends Resource
var position: Vector2
var is_accesible: bool = true
var neighbours: Array	#contains other PathfindingNodes
var score: int
						#goes
						#index'es are to be assigned according to how far away the desired position is
						#ig, then I can use Array.pop_front()
						#might be a bad idea actually
						
func _init(new_position: Vector2, accesible: bool, new_score = 0)->void:
	position = new_position
	is_accesible = accesible
	score = new_score
