class_name  Drone extends Node2D 
@export var status: Status = Status.new(10,10,10)
@export var sprite: Texture2D
@export var collision_shape: RectangleShape2D
@export var starting_position: Vector2 #TEMP
@export var starting_rotation: float
@export var rotation_ratio: float = 15			#larger values make for slower rotation, has to be >=1
@export var max_engine_power: float = 10
@export var acceleration_mult: float = 0.25
var engine_power: float = 0
#need some sort of resource store or whatevr
#+possibly weapon
var desired_position: Vector2
var current_position: Vector2
 #the actual thing won't be pathfinding, this is simply to move the drone from A to B, a short segment that will be actually gotten via a drone group controller,
var sprite_rid: RID
var body_rid: RID
var shape_rid: RID
var travel_direction: Vector2
var estimated_distance_to_stop: float
var lerp_weight: float

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
	PhysicsServer2D.body_set_collision_layer(body_rid,12)
	PhysicsServer2D.body_set_collision_mask(body_rid,12)	#to make them slide below larger units
	PhysicsServer2D.body_attach_object_instance_id(body_rid,self.get_instance_id())

func _ready() -> void:	#TEMP
	desired_position = starting_position
	print(desired_position)
	print(starting_rotation)
	var on_move: Callable = Callable(self,"_move_body")
	_physics_body_setup()
	_sprite_setup()
	PhysicsServer2D.body_set_force_integration_callback(body_rid, on_move, "_body_moved")
	RenderingServer.canvas_item_reset_physics_interpolation(sprite_rid)
	self.status.on_death.connect(_on_death)
	travel_direction = Vector2.from_angle(starting_rotation).normalized()
	estimated_distance_to_stop = (max_engine_power / acceleration_mult) * acceleration_mult + max_engine_power 
	print(estimated_distance_to_stop)
	#print((PhysicsServer2D.body_get_state(body_rid,PhysicsServer2D.BODY_STATE_TRANSFORM).get_origin()))


func Set_desired_coordinates(new_desired_position: Vector2) -> void:
	desired_position = new_desired_position
	#also will need to set up rotation here

func _movement(delta:float)->void:
	lerp_weight = 1 - exp(-(engine_power*2) * delta)		#TODO fix collision issues
	current_position = PhysicsServer2D.body_get_state(body_rid,PhysicsServer2D.BODY_STATE_TRANSFORM).origin
	if abs(current_position - desired_position).length() >= estimated_distance_to_stop:	#temp is position satisfied	#needs to aproximate distance necessary to stop  
		#travel_direction = (travel_direction * rotation_ratio + (desired_position - current_position).normalized()).normalized() # * engine_power?	
		engine_power += acceleration_mult
		#PhysicsServer2D.body_set_state(body_rid,PhysicsServer2D.BODY_STATE_TRANSFORM,Transform2D(travel_direction.angle(),current_position.lerp(current_position + (travel_direction * engine_power), weight)))
		travel_direction = (travel_direction * rotation_ratio + (desired_position - current_position).normalized()).normalized()
		#TODO PINGS signal to get the next desired position from the pathfinding manager, HERE
	else:
		engine_power -= acceleration_mult * 2
	PhysicsServer2D.body_set_state(body_rid,PhysicsServer2D.BODY_STATE_TRANSFORM,Transform2D(travel_direction.angle(),current_position.lerp(current_position + (travel_direction * engine_power), lerp_weight)))
	#print(engine_power)
	engine_power = clampf(engine_power,0,max_engine_power)

func _physics_process(delta: float) -> void:
	#var weight : float = 1 - exp(-(engine_power*2) * delta)		#TODO fix collision issues
	if(!self.is_queued_for_deletion()):
		_movement(delta)
		if Input.is_action_pressed("SPACE"):				#temp
			desired_position = get_global_mouse_position()	#temp
			#print(desired_position)

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
