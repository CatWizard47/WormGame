extends Node2D	#needs to be a 2D node, due to world2D usage
# Called when the node enters the scene tree for the first time.
@export var node_border_lenght: int

func _ready() -> void:
	pass # Replace with function body.


												#if z-levels are to be implemented, i have to dynamically change col_layer of obj
func Find_path(PositionA:Vector2, PositionB:Vector2,CollisionMask:int = 12)->Array:
	var Output:Array = Array()	#Returns an array of positions, individual units will pathfind to,
	var nodes_parsed: Array = Array()
	var nodes_unparsed: Array = Array()
	var is_not_finished_flag: bool = true
	var start_node: PathfindingNode = PathfindingNode.new(PositionA,true,0)
	var space_state = get_world_2d().direct_space_state
	while is_not_finished_flag:
		pass
	#var ray_query = PhysicsRayQueryParameters2D.create(body_position, body_position + velocity.normalized()*10 )
	#https://docs.godotengine.org/en/stable/tutorials/physics/ray-casting.html
	#https://en.wikipedia.org/wiki/A*_search_algorithm # maybe?
	#possibly make this a new thread # will check perf before doing that
	#https://docs.godotengine.org/en/stable/tutorials/performance/using_multiple_threads.html
	#TODO 
	#Try to figure out the best method of finding nodes, 
	# like 5 pronged incomplete hexagram or sumthin
	return Output


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
