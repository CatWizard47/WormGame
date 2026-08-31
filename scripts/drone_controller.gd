class_name  Drone extends Node2D 
@export var status: Status = Status.new(10,10,10,0)
var sprite_rid: RID
var body_rid: RID
var shape_rid: RID


func _sprite_setup()->void:
	sprite_rid = RenderingServer.canvas_item_create()
	RenderingServer.canvas_item_set_parent(sprite_rid, get_canvas_item())
	#RenderingServer.canvas_item_add_texture_rect(sprite_rid, Rect2(-sprite.get_size() / 2, sprite.get_size()), sprite)
	#somehow have to set global_coords to localhere dun ask
	#RenderingServer.canvas_item_set_transform(sprite_rid,Transform2D(start_rotation,start_position))
	RenderingServer.canvas_item_set_z_index(sprite_rid,10)
	pass

func _move_body(state,index):
	RenderingServer.canvas_item_set_transform(sprite_rid,state.transform)
	
func _physics_body_setup() -> void:
	body_rid = PhysicsServer2D.body_create()
	PhysicsServer2D.body_set_mode(body_rid,PhysicsServer2D.BODY_MODE_RIGID_LINEAR)
	shape_rid = PhysicsServer2D.circle_shape_create()
	#PhysicsServer2D.shape_set_data(shape_rid, collision_shape.radius)
	PhysicsServer2D.body_add_shape(body_rid,shape_rid)
	PhysicsServer2D.body_set_space(body_rid,get_world_2d().space)
	#PhysicsServer2D.body_set_state(body_rid,PhysicsServer2D.BODY_STATE_TRANSFORM,Transform2D(start_rotation,start_position))
	PhysicsServer2D.body_set_param(body_rid,PhysicsServer2D.BODY_PARAM_GRAVITY_SCALE,0)
	PhysicsServer2D.body_set_collision_layer(body_rid,0)
	PhysicsServer2D.body_set_collision_mask(body_rid,12)
	#PhysicsServer2D.body_apply_central_force(body_rid,Vector2.from_angle(start_rotation).normalized() * projectile_stats.projectile_speed*100)

func _ready() -> void:
	_physics_body_setup()
	_sprite_setup()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
