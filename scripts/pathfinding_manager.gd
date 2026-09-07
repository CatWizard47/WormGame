class_name PathfindingManager extends Node2D	#needs to be a 2D node, due to world2D usage
# Called when the node enters the scene tree for the first time.
#@export var node_border_lenght: int
@export var node_size: int #dist from the center so a node with size 10 is 20x20 square 
@export var maximum_sector_size: int #in nodes width from the center so 2* this for absolute width | height
var shape_rid: RID
var available_pathfinding_sectors: Array
var space_state: PhysicsDirectSpaceState2D
var next_node_vector:Vector2i
var node_query_parameters: PhysicsShapeQueryParameters2D = PhysicsShapeQueryParameters2D.new()


func _ready() -> void:
	space_state = get_world_2d().direct_space_state
	shape_rid = PhysicsServer2D.rectangle_shape_create()
	PhysicsServer2D.shape_set_data(shape_rid,Vector2(node_size,node_size))
	next_node_vector = Vector2i(0,-node_size*2) #to point north 
	node_query_parameters.shape_rid = shape_rid 
	#var params: PhysicsShapeQueryParameters2D = PhysicsShapeQueryParameters2D.new()
	#var body_position: Vector2 = (PhysicsServer2D.body_get_state(body_rid,PhysicsServer2D.BODY_STATE_TRANSFORM).get_origin())
	#params.motion = body_position
	#params.shape_rid = explosion_shape_rid# Execute physics queries here...# Release the shape when done with physics queries.
	#var explosion_result = space_state.intersect_shape(params,32)
	pass # Replace with function body.


	#needs to append to the A_P_S array:
	#deleting  might be an issue tho
func generate_navmesh(starting_position:Vector2)->void:
	pass

func generate_pathfinding_sector(starting_position:Vector2i)->void: #->PathfindingSector
	#start from the starting position
	#
	pass

func generate_pathfinding_node(center_position:Vector2i,starting_position:Vector2i)->void: #->PathfindingNode
	#check if extends beyond possible size:
	if (center_position - starting_position).length() >= (node_size * 2 * maximum_sector_size) + node_size:
		#return null
		pass
	else:
		for i: int in range(4):
			node_query_parameters.motion=starting_position + next_node_vector
			_check_collisions(space_state.intersect_shape(node_query_parameters,32))
			#TODO actually implement how this is supposed to work/
			pass
	#check if any neighbors are innaccesible
		#left = -x
		#up = -y
	#check for border and transit conditionals
	#if none above are checked make an internal node
	pass


	#needs to check whether a given node placement is accesible at all:
func _check_collisions(shape_intersect:Array[Dictionary])->bool:
	for result:Dictionary in shape_intersect:
		if !result.is_empty() and instance_from_id(result.get("collider_id")) != null:
			if instance_from_id(result.get("collider_id")).is_class("StaticBody2D"):
				return false #provided I won't add any more stuff that's meant to block things, this should be fine 
	return true	
	#above thing might even need to be simplyfied since we will only be checking collision layer 4 specifically
	#TODO check: /|\

												#if z-levels are to be implemented, i have to dynamically change col_layer of obj

	#https://docs.godotengine.org/en/stable/tutorials/physics/ray-casting.html
	#https://en.wikipedia.org/wiki/A*_search_algorithm # maybe?
	#possibly make this a new thread # will check perf before doing that
	#https://docs.godotengine.org/en/stable/tutorials/performance/using_multiple_threads.html
	#TODO 
	#Try to figure out the best method of finding nodes, 
	# like 5 pronged incomplete hexagram or sumthin
	#return Output


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
