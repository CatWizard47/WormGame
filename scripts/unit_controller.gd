class_name  Drone extends Node2D 
@export var status: Status = Status.new(10,10,10)
@export var sprite: Texture2D
@export var collision_shape: RectangleShape2D
@export var starting_position: Vector2 #TEMP
@export var starting_rotation: float
@export var rotation_ratio: float = 5			#larger values make for slower rotation, has to be >=1
@export var max_engine_power: float = 10
@export var acceleration_mult: float = 0.25
var engine_power: float = 0
#need some sort of resource store or whatevr
#+possibly weapon
var desired_position: Vector2
var current_position: Vector2
var next_position : Vector2 
var soft_collisions_query_params: PhysicsShapeQueryParameters2D =PhysicsShapeQueryParameters2D.new()
var soft_collisions_query_result: PackedFloat32Array
var space_state: PhysicsDirectSpaceState2D	#TODO consider changing this to init arg? 
 #the actual thing won't be pathfinding, this is simply to move the drone from A to B, a short segment that will be actually gotten via a drone group controller,
var sprite_rid: RID
var body_rid: RID
var shape_rid: RID
var travel_vector: Vector2
var estimated_distance_to_stop: float
var lerp_weight: float
var can_take_orders: bool = true	#TEMP
#TEMP#
var Move_path: Array = Array()
var order_cooldown:float = 0.5
var order_timer:Timer = Timer.new()
var PFM: PathfindingManager = PathfindingManager.new() #TEMP

#func _init(start_position:Vector2, start_rotation:float):
#	position=start_position
#	rotation=start_rotation

func _sprite_setup()->void:
	sprite_rid = RenderingServer.canvas_item_create()
	RenderingServer.canvas_item_set_parent(sprite_rid, get_canvas_item())
	RenderingServer.canvas_item_add_texture_rect(sprite_rid, Rect2(-sprite.get_size() / 2, sprite.get_size()), sprite)
	RenderingServer.canvas_item_set_transform(sprite_rid,Transform2D(starting_rotation,starting_position))	#position/rotation will be in a local position relative to parent, have to keep in mind
	RenderingServer.canvas_item_set_z_index(sprite_rid,10)

func _move_body(state,index):
	RenderingServer.canvas_item_set_transform(sprite_rid,state.transform)
	
func _physics_body_setup() -> void:
	body_rid = PhysicsServer2D.body_create()
	PhysicsServer2D.body_set_mode(body_rid,PhysicsServer2D.BODY_MODE_RIGID)
	shape_rid = PhysicsServer2D.rectangle_shape_create()
	PhysicsServer2D.shape_set_data(shape_rid, collision_shape.size)
	PhysicsServer2D.body_add_shape(body_rid,shape_rid)
	PhysicsServer2D.body_set_space(body_rid,get_world_2d().space)
	PhysicsServer2D.body_set_state(body_rid,PhysicsServer2D.BODY_STATE_TRANSFORM,Transform2D(starting_rotation,starting_position))
	PhysicsServer2D.body_set_param(body_rid,PhysicsServer2D.BODY_PARAM_GRAVITY_SCALE,0)
	#PhysicsServer2D.body_set_param(body_rid,PhysicsServer2D.BODY_PARAM_MASS,1)
	PhysicsServer2D.body_set_collision_layer(body_rid,4)
	PhysicsServer2D.body_set_collision_mask(body_rid,12)	#to make them slide below larger units	#TODO check if 12 is oke on layer 2,4 probly not
	PhysicsServer2D.body_attach_object_instance_id(body_rid,self.get_instance_id())
	#soft collision setup below
	soft_collisions_query_params.shape_rid = shape_rid
	soft_collisions_query_params.collision_mask = 12

func _ready() -> void:	#TEMP
	#print(instance_from_id(self.get_instance_id()))
	#TEMP
	add_child(PFM)
	PFM.generate_navmesh(Vector2i(300,300))
	#TEMP	
	space_state = get_world_2d().direct_space_state
	desired_position = starting_position
	order_timer.wait_time = order_cooldown
	order_timer.timeout.connect(_on_order_cooldown_timeout)
	self.add_child(order_timer)
	#print(desired_position)
	#print(starting_rotation)
	var on_move: Callable = Callable(self,"_move_body")
	_physics_body_setup()
	_sprite_setup()
	PhysicsServer2D.body_set_force_integration_callback(body_rid, on_move, "_body_moved")
	RenderingServer.canvas_item_reset_physics_interpolation(sprite_rid)
	self.status.on_death.connect(_on_death)
	travel_vector = Vector2.from_angle(starting_rotation).normalized()
	estimated_distance_to_stop = (max_engine_power / acceleration_mult) * acceleration_mult + max_engine_power 
	#print(estimated_distance_to_stop)
	#print((PhysicsServer2D.body_get_state(body_rid,PhysicsServer2D.BODY_STATE_TRANSFORM).get_origin()))
	
	#TEMP
	#TEMP
	
	
func Set_desired_coordinates(new_desired_position: Vector2) -> void:
	desired_position = new_desired_position
	#also will need to set up rotation here


func _movement(delta:float)->void:
	lerp_weight = 1 - exp(-(engine_power*2) * delta)		#TODO fix collision issues
	current_position = PhysicsServer2D.body_get_state(body_rid,PhysicsServer2D.BODY_STATE_TRANSFORM).origin
	if abs(current_position - desired_position).length() >= estimated_distance_to_stop:	#temp is position satisfied	#needs to aproximate distance necessary to stop  
		engine_power += acceleration_mult
		travel_vector = (travel_vector * rotation_ratio + (desired_position - current_position).normalized()).normalized()
		if(abs((desired_position - current_position).angle()) >= PI):	#terrible, however works 
			travel_vector = Vector2.from_angle(travel_vector.angle() + signi(randi_range(-10,10))*PI/8).normalized()
		#TODO PINGS signal to get the next desired position from the pathfinding manager, HERE
	else:
		engine_power -= acceleration_mult * 2
		if Move_path.size() > 0:
			desired_position = Move_path.pop_back()
	soft_collisions_query_params.transform = PhysicsServer2D.body_get_state(body_rid,PhysicsServer2D.BODY_STATE_TRANSFORM) 
	#next_position = current_position - current_position.lerp(current_position + (travel_direction * engine_power), lerp_weight)
	soft_collisions_query_params.motion =  current_position.lerp(current_position + (travel_vector * engine_power), lerp_weight)
	soft_collisions_query_result = space_state.cast_motion(soft_collisions_query_params)
	#print(soft_collisions_query_result)
	PhysicsServer2D.body_set_state(body_rid,PhysicsServer2D.BODY_STATE_TRANSFORM,Transform2D(travel_vector.angle(),current_position.lerp(current_position + (travel_vector * engine_power), lerp_weight)))
	#print(engine_power)
	engine_power = clampf(engine_power,0,max_engine_power)


func _physics_process(delta: float) -> void:
	#var weight : float = 1 - exp(-(engine_power*2) * delta)		#TODO fix collision issues
	if(!self.is_queued_for_deletion()):
		_movement(delta)
		if Input.is_action_pressed("SPACE") and	can_take_orders:			#temp
			#TEMP
			#print(PFM.find_nearest_node(Vector2(600,30)))
			#PFM.find_nearest_node(get_global_mouse_position())
			Move_path = PFM.find_path(current_position,get_global_mouse_position())
			can_take_orders = false
			order_timer.start()
			#print(PFM.find_path(current_position,get_global_mouse_position()))
			#var heaptest:PathfindingNodeHeap = PathfindingNodeHeap.new()
			#for i:int in range(10):
			#	heaptest.insert(PathfindingNode.new(Vector2i(1,1),false),randi_range(0,100))
				#print(heaptest.heap)
			#for i:int in range(10):
				#print(heaptest.pop_min())
			#	heaptest.pop_min()
		#		print(heaptest.heap)
			#TEMP
			#desired_position = get_global_mouse_position()	#temp
			#var test:Vector2i
			#for i: int in range(4):
				#test.x =sin(i*(PI/2))
				#test.y =cos(i*(PI/2))
				#print(test)
				#node_query_parameters.motion=starting_position + next_node_vector
				#rotate next_node_vector by PI/2 here
				#_check_collisions(space_state.intersect_shape(node_query_parameters,32))
				#TODO actually implement how this is supposed to work/


func _on_death()->void:
	_remove_this()	


func _remove_this()->void:
	#print("sprite",sprite_rid,"body=",body_rid,"shape=",shape_rid)
	if(!self.is_queued_for_deletion()):
		if sprite_rid.is_valid():
			RenderingServer.canvas_item_clear(sprite_rid)
			RenderingServer.free_rid(sprite_rid)
		if body_rid.is_valid():
			PhysicsServer2D.body_set_collision_layer(body_rid,0)
			PhysicsServer2D.body_set_collision_mask(body_rid,0)
			PhysicsServer2D.body_clear_shapes(body_rid)
			PhysicsServer2D.free_rid(body_rid)
		if shape_rid.is_valid():
			PhysicsServer2D.free_rid(shape_rid)
	queue_free()

	#backup if i ever 4 get	
func _on_tree_exiting() -> void:
	_remove_this()
	
func _on_order_cooldown_timeout() -> void:
	can_take_orders = true
