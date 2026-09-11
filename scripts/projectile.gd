
class_name Projectile extends Node2D
var projectile_stats: ProjectileRes 
var start_position: Vector2
var end_position: Vector2
var start_rotation: float
var is_projectile: bool = true
var sprite: Texture2D
var collision_shape: CircleShape2D
var excluded_RIDS: Array
var sprite_rid: RID
var body_rid: RID
var shape_rid: RID
var velocity: Vector2
var current_collision_mask:int
var explode_timer: Timer = Timer.new()


func _init(new_position: Vector2, new_rotation: float, NewProjectile:ProjectileRes,RIDS_to_exclude:Array,collision_mask:int,aimpoint:Vector2)->void:
	start_position = new_position
	start_rotation = new_rotation
	projectile_stats = NewProjectile
	sprite = projectile_stats.texture
	collision_shape = CircleShape2D.new()
	collision_shape.radius = 0.5
	excluded_RIDS = RIDS_to_exclude
	current_collision_mask = collision_mask
	end_position = aimpoint

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
	PhysicsServer2D.body_set_collision_mask(body_rid,current_collision_mask)
	PhysicsServer2D.body_attach_object_instance_id(body_rid,self.get_instance_id())
	PhysicsServer2D.body_apply_central_impulse(body_rid,Vector2.from_angle(start_rotation).normalized() * projectile_stats.projectile_speed)
	#might need to rework line above


func _ready() -> void:
	add_child(explode_timer)
	explode_timer.timeout.connect(_explode)
	var on_move:Callable = Callable(self,"_move_body")
	_setup_body()
	_setup_sprite()
	PhysicsServer2D.body_set_force_integration_callback(body_rid, on_move, "_body_moved")
	RenderingServer.canvas_item_reset_physics_interpolation(sprite_rid)
	#if projectile_stats.blast_radius > 0:	#to mimic hitting the ground 
	explode_timer.wait_time = ((end_position-start_position).length() / (projectile_stats.projectile_speed ) + 0.05)  #minimum timer length
	explode_timer.start()
	if projectile_stats.projectile_speed == 0:
		_hitscan_fire()
	else:
		velocity = Vector2.from_angle(start_rotation).normalized() * projectile_stats.projectile_speed 
		#self.collision_mask = 12
	#https://docs.godotengine.org/en/stable/tutorials/performance/using_servers.html
	#later tho, now base implement # actually done!


func is_valid_target(id: int) -> bool:
	return (!instance_from_id(id).is_class("Projectile") and !instance_from_id(id).is_queued_for_deletion() and !instance_from_id(id).is_class("StaticBody2D"))


func _physics_process(_delta: float) -> void: 
	var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var body_position: Vector2 = (PhysicsServer2D.body_get_state(body_rid,PhysicsServer2D.BODY_STATE_TRANSFORM).get_origin())
	var ray_query :PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(body_position, body_position + velocity.normalized()*10 )
	ray_query.exclude = excluded_RIDS # possibly redundant line # actually not, since not setting collision mask, might be change later
	var ray_result = space_state.intersect_ray(ray_query)
	if !ray_result.is_empty() and instance_from_id(ray_result.get("collider_id")) != null:
		#print(ray_result)
		if is_valid_target(ray_result.get("collider_id")):
			_deal_damage(instance_from_id(ray_result.get("collider_id")))
		elif(instance_from_id(ray_result.get("collider_id")).is_class("StaticBody2D")):
			_remove_self()


func _deal_damage(body: Node2D) -> void:
	if body.get("status") != null:
		body.status.deal_damage(projectile_stats.health_damage,projectile_stats.structure_damage,projectile_stats.armour_damage)
	_remove_self()
	pass


func _explode() -> void:	#TODO
	#will increase collision shape size (gradually? or Instantly?)
	#var body_query = PhysicsShapeQueryParameters2D.create()
	var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var explosion_shape_rid:RID= PhysicsServer2D.circle_shape_create()
	PhysicsServer2D.shape_set_data(explosion_shape_rid, projectile_stats.blast_radius)
	var params: PhysicsShapeQueryParameters2D = PhysicsShapeQueryParameters2D.new()
	var body_position: Vector2 = (PhysicsServer2D.body_get_state(body_rid,PhysicsServer2D.BODY_STATE_TRANSFORM).get_origin())
	params.transform = Transform2D(0,body_position)
	params.shape_rid = explosion_shape_rid# Execute physics queries here...# Release the shape when done with physics queries.
	var explosion_result = space_state.intersect_shape(params,32)
	for result:Dictionary in explosion_result:
		if !result.is_empty() and instance_from_id(result.get("collider_id")) != null:
			#print(result)
			if is_valid_target(result.get("collider_id")):
				_deal_damage(instance_from_id(result.get("collider_id")))
	PhysicsServer2D.free_rid(explosion_shape_rid)
	#print("boom")
	_remove_self()


func _hitscan_fire() -> void:	#TODO
	pass


func _remove_self()->void:
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
