class_name PathfindingManager extends Node2D	#needs to be a 2D node, due to world2D usage
# Called when the node enters the scene tree for the first time.
#@export var node_border_lenght: int
@export var node_size: int = 10 #dist from the center so a node with size 10 is 20x20 square 
								#needs to be suitably small or navmesh will be innacurate
@export var maximum_sector_size: int = 100#in nodes width from the center so 2* this for absolute width | height
var shape_rid: RID
var available_pathfinding_sectors: Array
var space_state: PhysicsDirectSpaceState2D
var next_node_vector:Vector2i
var node_query_parameters: PhysicsShapeQueryParameters2D = PhysicsShapeQueryParameters2D.new()
var current_navmesh:Dictionary[Vector2i, PathfindingNode] 
var positions_checked: 	Array = Array()	#placed here in case of using generate_navmesh to append rather than generate
signal finished_navmesh_generation

	#TODO This whole thing will probably be using a separate thread rhather than running on main,
	
func _ready() -> void:
	space_state = get_world_2d().direct_space_state
	shape_rid = PhysicsServer2D.rectangle_shape_create()
	PhysicsServer2D.shape_set_data(shape_rid,Vector2(node_size,node_size))
	node_query_parameters.shape_rid = shape_rid 
	node_query_parameters.collision_mask = 8 #default value maybe will have to change it l8tr
	current_navmesh.clear()	#probably unnecesary but whatevr
	
	#print(_check_neighboring_node_collisions(Vector2i(300,300)))


	#needs to append to the A_P_S array:
	#deleting  might be an issue tho
	
	#actually will be the primary loop thing here
	#this will generate a navmesh, appending it to the navmesh dict
	#periodically it will call sector generator function, 
	#which will carve out a certain area 
	#should be fine to use for appending navmesh too
func generate_navmesh(start_position:Vector2)->void:
	print("generating navmesh")
	var current_position : Vector2i = flatten_coordinates_to_int(start_position)
	var neighbours_of_node: Array = Array()
	var added_position:Vector2i = Vector2i.ZERO
	node_query_parameters.transform = Transform2D(0,current_position)
	var positions_to_check:	Array = Array() #in Vector2i
	positions_to_check.append(start_position)
	while positions_to_check.size()>0:
		current_position = positions_to_check.pop_back()
		neighbours_of_node = add_pathfinding_node(current_navmesh,positions_checked,current_position)
		for direction in neighbours_of_node:
			added_position = current_position + (get_direction_vector(direction) * (node_size * 2))
			if positions_checked.find(added_position)==-1:
				positions_to_check.append(added_position) 
	
	_apply_node_neighbour_references()
	#var test = current_navmesh.keys().pick_random()
	#print(current_navmesh[test].neighbours)
	#print(test)
	DEBUG_force_labels_on_nodes()


#func generate_pathfinding_sector(starting_position:Vector2i, is_starting_position_central:bool)->void: #->PathfindingSector
	#start from the starting position
	#will need to provide the center position as 
	#(node_size * 2 * maximum_sector_size) + node_size
	#from the initial starting node?
	#in a given axis?
	#pass
	
	
	#will return null if too far, max distance is like 3 
func find_nearest_node(position_to_check: Vector2) -> Variant:
	var node_position: Vector2i = flatten_coordinates_to_int(position_to_check)	#this will adjust this to the grid
	var checking_vector: Vector2 = Vector2.ZERO
	var max_division:int
	if current_navmesh.has(node_position):
		return node_position
	else:
		for i:int in range(2,6):
			max_division = (2**i)	#+1 since range stops b4 second value
			for j:int in range(0,max_division+1):
				checking_vector = Vector2.from_angle(((2*PI) * j)/max_division).normalized() * 2 * node_size * (i-1)
				print(node_position + flatten_coordinates_to_int(checking_vector))
				if current_navmesh.has(node_position + flatten_coordinates_to_int(checking_vector)):
					return node_position
	return null 
	
	
func find_path(initial_start_position:Vector2,initial_end_position: Vector2) -> void: #->Array: #of vector2i-s
	var start_position: Vector2i = find_nearest_node(initial_start_position)
	var end_position: Vector2i = find_nearest_node(initial_end_position)
	
	pass

func clear_navmesh()->void:
	current_navmesh.clear()
	positions_checked.clear()

	#this is ass but should work for our purposes
func flatten_coordinates_to_int(old_coordinates:Vector2) -> Vector2i:
	var new_coordinates: Vector2i = Vector2i.ZERO
	#node size * 2 = grid square size
	new_coordinates.x = int(old_coordinates.x) - (int(old_coordinates.x)% (node_size * 2)) 
	new_coordinates.y = int(old_coordinates.y) - (int(old_coordinates.y)% (node_size * 2))
	return new_coordinates

func get_direction_vector(direction:int)->Vector2i:	#matches the direction enum of nodes
	match direction:
		0:
			return Vector2i(0,-1)
		1:
			return Vector2i(1,0)
		2:
			return Vector2i(0,1)
		3:
			return Vector2i(-1,0)
		_:	#needs to have a default output, so just as a contingency
			return Vector2i.ZERO
	
	
	#returns an array of neighbours
	#really only made to make code more readable, somewhat
func add_pathfinding_node(dict_to_append_to:Dictionary[Vector2i,PathfindingNode],positions_already_checked:Array,position_to_check:Vector2i) -> Array:
	positions_already_checked.append(position_to_check)
	return _generate_pathfinding_node(dict_to_append_to,position_to_check)
	
	#Has to be safeguarded and only provided accesible nodes,
func _generate_pathfinding_node(dict_to_append_to:Dictionary[Vector2i,PathfindingNode],node_position:Vector2i)->Array:
	var neighbour_array: Array = _check_neighboring_node_collisions(node_position)
	node_query_parameters.transform = Transform2D(0,node_position)
	if !dict_to_append_to.has(node_position):
		if neighbour_array.size() < 4:
			if !_check_collisions(space_state.intersect_shape(node_query_parameters,32)):
				dict_to_append_to[node_position] = PathfindingNode.new(node_position,true)
		else:
			if !_check_collisions(space_state.intersect_shape(node_query_parameters,32)):
				dict_to_append_to[node_position] = PathfindingNode.new(node_position,false)
	#DEBUG_make_label_for_position(node_position) #DEBUG #COMM OUT L8TR
	return neighbour_array
	

	#checks if any neighboring nodes are inaccesible, returns array of that equals node_direction enum
	#returned Array is all accesible nodes
func _check_neighboring_node_collisions(position_to_check:Vector2i)-> Array:
	var output:Array = Array()
	for i: int in range(4):
		next_node_vector = get_direction_vector(i) * node_size * 2
		node_query_parameters.transform=Transform2D(0,position_to_check + next_node_vector)
		if !_check_collisions(space_state.intersect_shape(node_query_parameters,32)):
			output.append(i) #i is the exact same as node_direction enum
	#print(output)
	return output

	#this  is so ass, but will probably save on lookup time  
func _apply_node_neighbour_references()->void:
	for node_position in current_navmesh:
		for i: int in range(4):
			next_node_vector = get_direction_vector(i) * node_size * 2
			if current_navmesh.has(node_position + next_node_vector):
				current_navmesh[node_position].neighbours[i] = current_navmesh[node_position + next_node_vector]

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
	#appended, col_layer 4 in _ready

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
	#debug_scene.change_text(str("position= ",str(label_position)))
	debug_scene.position = label_position
	add_child(debug_scene)
	
	
	#backup if i ever 4 get 
func _on_tree_exiting() -> void:
	_remove_this()
	
