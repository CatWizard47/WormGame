class_name PathfindingManager extends Node2D	#needs to be a 2D node, due to world2D usage
# Called when the node enters the scene tree for the first time.
#@export var node_border_lenght: int
@export var node_size: int = 15#dist from the center so a node with size 10 is 20x20 square 
@export var maximum_sector_size: int = 100#in nodes width from the center so 2* this for absolute width | height
var shape_rid: RID
var available_pathfinding_sectors: Array
var space_state: PhysicsDirectSpaceState2D
var next_node_vector:Vector2i
var node_query_parameters: PhysicsShapeQueryParameters2D = PhysicsShapeQueryParameters2D.new()
var current_navmesh:Dictionary[Vector2i, PathfindingNode] 

func _ready() -> void:
	space_state = get_world_2d().direct_space_state
	shape_rid = PhysicsServer2D.rectangle_shape_create()
	PhysicsServer2D.shape_set_data(shape_rid,Vector2(node_size,node_size))
	next_node_vector = Vector2i(0,-node_size*2) #to point north 
	node_query_parameters.shape_rid = shape_rid 
	node_query_parameters.collision_mask = 8 #default value maybe will have to change it l8tr


	#needs to append to the A_P_S array:
	#deleting  might be an issue tho
	
	#actually will be the primary loop thing here
	#this will generate a navmesh, appending it to the navmesh dict
	#periodically it will call sector generator function, 
	#which will carve out a certain area 
func generate_navmesh(current_position:Vector2i)->void:
	print("generating navmesh")
	current_navmesh.clear()	#probably unnecesary but whatevr
	var positions_to_check:	Array = Array() #in Vector2i
	var positions_checked: 	Array = Array()
	var neighbours_of_node:Array = Array()
	var added_position:Vector2i = Vector2i.ZERO
	node_query_parameters.motion = current_position
	node_query_parameters.transform = Transform2D(0,current_position)
	#print(node_query_parameters.transform)
	#print(node_query_parameters.motion)
	#print(instance_from_id(space_state.intersect_shape(node_query_parameters,32)[0].get("collider_id")).position)
	
	if !_check_collisions(space_state.intersect_shape(node_query_parameters,32)):
		neighbours_of_node = _add_pathfinding_node(current_navmesh,positions_checked,current_position)
		#neighbours_of_node = generate_pathfinding_node(current_navmesh,current_position)
		#positions_checked.append(current_position)
		for direction in neighbours_of_node:
			added_position = current_position +(_get_direction_vector(direction) * node_size * 2)
			if positions_checked.find(added_position)==-1:
				positions_to_check.append(added_position) 
		while positions_to_check.size()>0:
			current_position = positions_to_check.pop_back()
			neighbours_of_node = _add_pathfinding_node(current_navmesh,positions_checked,current_position)
			#positions_checked.append(current_position)
			#neighbours_of_node = generate_pathfinding_node(current_navmesh,current_position)
			for direction in neighbours_of_node:
				added_position = current_position + (_get_direction_vector(direction) * node_size * 2)
				if positions_checked.find(added_position)==-1:
					positions_to_check.append(added_position) 
	#print(current_navmesh)
	DEBUG_force_labels_on_nodes()


#func generate_pathfinding_sector(starting_position:Vector2i, is_starting_position_central:bool)->void: #->PathfindingSector
	#start from the starting position
	#will need to provide the center position as 
	#(node_size * 2 * maximum_sector_size) + node_size
	#from the initial starting node?
	#in a given axis?
	#pass

func _get_direction_vector(direction:int)->Vector2i:	#matches the direction enum of nodes
	match direction:
		0:
			return Vector2i(0,-1)
		1:
			return Vector2i(1,0)
		2:
			return Vector2i(0,1)
		3:
			return Vector2i(-1,0)
		_:
			return Vector2i.ZERO
	
	
	#returns an array of neighbours
	#really only made to make code more readable, somewhat
func _add_pathfinding_node(dict_to_append_to:Dictionary[Vector2i,PathfindingNode],positions_checked:Array,position_to_check:Vector2i) -> Array:
	positions_checked.append(position_to_check)
	return generate_pathfinding_node(dict_to_append_to,position_to_check)
	
	#Has to be safeguarded and only provided accesible nodes,
func generate_pathfinding_node(dict_to_append_to:Dictionary[Vector2i,PathfindingNode],node_position:Vector2i)->Array:
	var neighbour_array: Array = _check_neighboring_node_collisions(node_position)
	if neighbour_array.size() < 4:
		dict_to_append_to[node_position] = PathfindingNode.new(node_position,true)
	else:
		dict_to_append_to[node_position] = PathfindingNode.new(node_position,false)
	#DEBUG_make_label_for_position(node_position) #DEBUG #COMM OUT L8TR
	return neighbour_array
	

	#checks if any neighboring nodes are inaccesible, returns array of that equals node_direction enum
	#returned Array is all accesible nodes
func _check_neighboring_node_collisions(position_to_check:Vector2i)-> Array:
	var output:Array = Array()
	for i: int in range(4):
		next_node_vector = _get_direction_vector(i)
		node_query_parameters.transform=Transform2D(0,position_to_check + next_node_vector)
		if !_check_collisions(space_state.intersect_shape(node_query_parameters,32)) and node_query_parameters.transform.origin:
			output.append(i) #i is the exact same as node_direction enum
	#print(output)
	return output


	#needs to check whether a given node placement is accesible at all:
	#returns true when collisions present, false otherwise
func _check_collisions(shape_intersect:Array[Dictionary])->bool:
	for result:Dictionary in shape_intersect:
		if !result.is_empty() and instance_from_id(result.get("collider_id")) != null:
			if instance_from_id(result.get("collider_id")).is_class("StaticBody2D"):
				#print(instance_from_id(result.get("collider_id")))
				return true #provided I won't add any more stuff that's meant to block things, this should be fine 
	return false
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
func _process(_delta: float) -> void:
	pass
	
	#current plan is as follows:
	#generate a sector navmesh with all nodes  possesing a crossing_node_id = 0
	# then do another pass of every node in a sector? 
	#assigning referances to neighbours and checking for border / crossing cond?
	# obv this is to change central node_position with maximum size?
	#but then will have to make a more complex long range pathfinging algo 
	#or not will just have to avg the position of every node to get the central position of sector ig 


	#maybe i just gotta make a navmesh first, then divide the thing into sectors

func _remove_this()->void:
	PhysicsServer2D.free_rid(shape_rid)

func DEBUG_force_labels_on_nodes()->void:
	for key in current_navmesh:
		var debug_scene = preload("res://debug_test_label_scene.tscn").instantiate()
		debug_scene.change_text(str(key))
		debug_scene.position = key
		add_child(debug_scene)

func DEBUG_make_label_for_position(label_position:Vector2i)->void:
	var debug_scene = preload("res://debug_test_label_scene.tscn").instantiate()
	debug_scene.change_text(str("position= ",str(label_position)))
	debug_scene.position = label_position
	add_child(debug_scene)
	
	
