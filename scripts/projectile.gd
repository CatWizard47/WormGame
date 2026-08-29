
class_name Projectile extends Node2D
static var projectile_stats: ProjectileRes
static var start_position: Vector2
static var start_rotation: float
static var is_projectile: bool = true
static var sprite: Texture2D
static var collision_shape: CircleShape2D
var sprite_rid
var body_rid
var shape_rid
var velocity
var collision_flag: bool = false


static func setup(new_position: Vector2, new_rotation: float, Projectile:ProjectileRes) -> void:
	start_position = new_position
	start_rotation = new_rotation
	projectile_stats = Projectile
	sprite = projectile_stats.texture
	collision_shape = CircleShape2D.new()
	collision_shape.radius = 2


func _setup_sprite() -> void:
	sprite_rid = RenderingServer.canvas_item_create()
	RenderingServer.canvas_item_set_parent(sprite_rid, get_canvas_item())
	RenderingServer.canvas_item_add_texture_rect(sprite_rid, Rect2(-sprite.get_size() / 2, sprite.get_size()), sprite)
	#somehow have to set global_coords to localhere dun ask
	RenderingServer.canvas_item_set_transform(sprite_rid,Transform2D(0,Vector2.ZERO))
	RenderingServer.canvas_item_reset_physics_interpolation(sprite_rid)

func _move_body(state,index):
	RenderingServer.canvas_item_set_transform(sprite_rid,state.transform)
	
func _setup_body() -> void:
	body_rid = PhysicsServer2D.body_create()
	PhysicsServer2D.body_set_mode(body_rid,PhysicsServer2D.BODY_MODE_RIGID)
	shape_rid = PhysicsServer2D.circle_shape_create()
	PhysicsServer2D.shape_set_data(shape_rid, collision_shape.radius)
	PhysicsServer2D.body_add_shape(body_rid,shape_rid)
	PhysicsServer2D.body_set_space(body_rid,get_world_2d().space)
	PhysicsServer2D.body_set_state(body_rid,PhysicsServer2D.BODY_STATE_TRANSFORM,Transform2D(start_rotation,start_position))
	PhysicsServer2D.body_set_param(body_rid,PhysicsServer2D.BODY_PARAM_GRAVITY_SCALE,0)
	PhysicsServer2D.body_set_collision_layer(body_rid,0)
	PhysicsServer2D.body_set_collision_mask(body_rid,12)
	PhysicsServer2D.body_apply_central_force(body_rid,Vector2.from_angle(start_rotation).normalized() * projectile_stats.projectile_speed*100)

func _ready() -> void:
	var on_move = Callable(self,"_move_body")
	#position = start_position
	#rotation = start_rotation
	_setup_body()
	_setup_sprite()
	PhysicsServer2D.body_set_force_integration_callback(body_rid, on_move, "_body_moved")
	if projectile_stats.projectile_speed == 0:
		_hitscan_fire()
	else:
		velocity = Vector2.from_angle(start_rotation).normalized() * projectile_stats.projectile_speed
		#self.collision_mask = 12
	# Replace with function body.
	#https://docs.godotengine.org/en/stable/tutorials/performance/using_servers.html
	#later tho, now base implement


func is_valid_target(id: int) -> bool:
	return (!instance_from_id(id).is_class("Projectile") and !instance_from_id(id).is_queued_for_deletion() and instance_from_id(id).is_class("RigidBody2D"))


func _physics_process(delta: float) -> void: 
	#print(delta)
	#move_and_collide(velocity * delta,false,0.1)
	#position +=  velocity*delta
	var space_state = get_world_2d().direct_space_state
	var ray_query = PhysicsRayQueryParameters2D.create(global_position, global_position + velocity.normalized() * 10 )
	ray_query.exclude = [sprite_rid,body_rid,shape_rid]
	var ray_result = space_state.intersect_ray(ray_query)
	var body_query = PhysicsShapeQueryParameters2D.new()
	body_query.shape = collision_shape
	body_query.exclude = [sprite_rid,body_rid,shape_rid]
	var body_result = space_state.intersect_shape(body_query,1)
	#print(body_result[0])
	#print(global_position)
	if !ray_result.is_empty() and instance_from_id(ray_result.collider_id) != null:
		if collision_flag and is_valid_target(ray_result.collider_id):
			_deal_damage(instance_from_id(ray_result.collider_id))
		elif(collision_flag and instance_from_id(ray_result.collider_id).is_class("StaticBody2D") and ray_result.shape != 0):
			_remove_this()
	if !body_result.is_empty() and instance_from_id(body_result[0].collider_id) != null:
		if collision_flag and is_valid_target(body_result[0].collider_id):
			_deal_damage(instance_from_id(body_result[0].collider_id))
		elif(collision_flag and instance_from_id(body_result[0].collider_id).is_class("StaticBody2D") and body_result[0].shape != 0):
			#print(instance_from_id(body_result[0].collider_id).get_class())
			_remove_this()
	


func _deal_damage(body: Node2D) -> void:
	_remove_this()
	pass

func _explode() -> void:
	#will increase collision shape size (gradually? or Instantly?)
	_remove_this()
	pass
	
func _on_timer_timeout() -> void:
	_explode()

func _hitscan_fire() -> void:
	pass

func _remove_this()->void:
	print("sprite",sprite_rid,"body=",body_rid,"shape=",shape_rid)
	if sprite_rid.is_valid() and instance_from_id(sprite_rid.get_id()) != null:
		if instance_from_id(sprite_rid.get_id()).is_queued_for_deletion():
			RenderingServer.free_rid(sprite_rid)
	if body_rid.is_valid() and instance_from_id(body_rid.get_id()) != null:
		if instance_from_id(body_rid.get_id()).is_queued_for_deletion(): 
			PhysicsServer2D.free_rid(body_rid)
	if shape_rid.is_valid() and instance_from_id(shape_rid.get_id()) != null:
		if instance_from_id(shape_rid.get_id()).is_queued_for_deletion():
			PhysicsServer2D.free_rid(shape_rid)
	queue_free()

func _on_impact(body: Node) -> void:
	#_deal_damage(body)
	#print("TEST")
	_remove_this()
	pass # Replace with function body.


func _on_start_up_timer_timeout() -> void:
	collision_flag = true


func _on_explode_timer_timeout() -> void:
	_explode()
