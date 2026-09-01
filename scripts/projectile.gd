
class_name Projectile extends Node2D
static var projectile_stats: ProjectileRes
static var start_position: Vector2
static var start_rotation: float
static var is_projectile: bool = true
static var sprite: Texture2D
static var collision_shape: CircleShape2D
static var excluded_RIDS: Array
var sprite_rid
var body_rid
var shape_rid
var velocity
var collision_flag: bool = false


static func setup(new_position: Vector2, new_rotation: float, NewProjectile:ProjectileRes,RIDS_to_exclude:Array) -> void:
	start_position = new_position
	start_rotation = new_rotation
	projectile_stats = NewProjectile
	sprite = projectile_stats.texture
	collision_shape = CircleShape2D.new()
	collision_shape.radius = 0.5
	excluded_RIDS = RIDS_to_exclude
	#print(excluded_RIDS)


func _setup_sprite() -> void:
	sprite_rid = RenderingServer.canvas_item_create()
	RenderingServer.canvas_item_set_parent(sprite_rid, get_canvas_item())
	RenderingServer.canvas_item_add_texture_rect(sprite_rid, Rect2(-sprite.get_size() / 2, sprite.get_size()), sprite)
	#somehow have to set global_coords to localhere dun ask
	RenderingServer.canvas_item_set_transform(sprite_rid,Transform2D(start_rotation,start_position))
	RenderingServer.canvas_item_set_z_index(sprite_rid,10)

func _move_body(state,index):
	RenderingServer.canvas_item_set_transform(sprite_rid,state.transform)
	
func _setup_body() -> void:
	body_rid = PhysicsServer2D.body_create()
	PhysicsServer2D.body_set_mode(body_rid,PhysicsServer2D.BODY_MODE_RIGID_LINEAR)
	shape_rid = PhysicsServer2D.circle_shape_create()
	PhysicsServer2D.shape_set_data(shape_rid, collision_shape.radius)
	PhysicsServer2D.body_add_shape(body_rid,shape_rid)
	PhysicsServer2D.body_set_space(body_rid,get_world_2d().space)
	PhysicsServer2D.body_set_state(body_rid,PhysicsServer2D.BODY_STATE_TRANSFORM,Transform2D(start_rotation,start_position))
	PhysicsServer2D.body_set_param(body_rid,PhysicsServer2D.BODY_PARAM_GRAVITY_SCALE,0)
	PhysicsServer2D.body_set_collision_layer(body_rid,0)
	PhysicsServer2D.body_set_collision_mask(body_rid,12)
	PhysicsServer2D.body_apply_central_force(body_rid,Vector2.from_angle(start_rotation).normalized() * projectile_stats.projectile_speed*100)


	#TODO possibly change velocity to be representative of actuall reality
func _ready() -> void:
	var on_move = Callable(self,"_move_body")
	_setup_body()
	_setup_sprite()
	PhysicsServer2D.body_set_force_integration_callback(body_rid, on_move, "_body_moved")
	RenderingServer.canvas_item_reset_physics_interpolation(sprite_rid)
	if projectile_stats.projectile_speed == 0:
		_hitscan_fire()
	else:
		velocity = Vector2.from_angle(start_rotation).normalized() * projectile_stats.projectile_speed * 100
		#self.collision_mask = 12
	#https://docs.godotengine.org/en/stable/tutorials/performance/using_servers.html
	#later tho, now base implement


func is_valid_target(id: int) -> bool:
	return (!instance_from_id(id).is_class("Projectile") and !instance_from_id(id).is_queued_for_deletion() and instance_from_id(id).is_class("RigidBody2D"))


func _physics_process(_delta: float) -> void: 
	var space_state = get_world_2d().direct_space_state
	var body_position = (PhysicsServer2D.body_get_state(body_rid,PhysicsServer2D.BODY_STATE_TRANSFORM).get_origin())
	var ray_query = PhysicsRayQueryParameters2D.create(body_position, body_position + velocity.normalized()*10 )
	ray_query.exclude = excluded_RIDS # possibly redundant line # actually not, since not setting collision mask, might be change later
	#print(ray_query.exclude)			#gotta think bout this 
	var ray_result = space_state.intersect_ray(ray_query)
	if !ray_result.is_empty() and instance_from_id(ray_result.collider_id) != null and collision_flag:
		if is_valid_target(ray_result.collider_id):
			_deal_damage(instance_from_id(ray_result.collider_id))
		elif(instance_from_id(ray_result.collider_id).is_class("StaticBody2D")):# and ray_result.shape != 0):
			#print("delet")
			_remove_self()


func _deal_damage(body: Node2D) -> void:
	print(body)
	if body.get("status") != null:
		body.status.deal_damage(projectile_stats.health_damage,projectile_stats.structure_damage,projectile_stats.armour_damage)
	_remove_self()
	pass

func _explode() -> void:
	#will increase collision shape size (gradually? or Instantly?)
	_remove_self()
	pass
	
func _on_timer_timeout() -> void:
	_explode()

func _hitscan_fire() -> void:
	pass

func _remove_self()->void:
	#print("sprite",sprite_rid,"body=",body_rid,"shape=",shape_rid)
	if sprite_rid.is_valid() and instance_from_id(sprite_rid.get_id()) != null:
		if instance_from_id(sprite_rid.get_id()).is_queued_for_deletion():
			RenderingServer.canvas_item_clear(sprite_rid)
			RenderingServer.free_rid(sprite_rid)
	if body_rid.is_valid() and instance_from_id(body_rid.get_id()) != null:
		if instance_from_id(body_rid.get_id()).is_queued_for_deletion(): 
			PhysicsServer2D.body_set_collision_mask(body_rid,0)
			PhysicsServer2D.free_rid(body_rid)
	if shape_rid.is_valid() and instance_from_id(shape_rid.get_id()) != null:
		if instance_from_id(shape_rid.get_id()).is_queued_for_deletion():
			PhysicsServer2D.free_rid(shape_rid)
	queue_free()


func _on_start_up_timer_timeout() -> void:
	collision_flag = true


func _on_explode_timer_timeout() -> void:
	_explode()
