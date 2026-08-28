class_name Projectile extends RigidBody2D
static var projectile_stats: ProjectileRes
static var start_position: Vector2
static var start_rotation: float
static var is_projectile: bool = true	# Node2D
static var sprite: Texture2D
var sprite_rid
var velocity
var collision_flag: bool = false


static func setup(new_position: Vector2, new_rotation: float, Projectile:ProjectileRes) -> void:
	start_position = new_position
	start_rotation = new_rotation
	projectile_stats = Projectile
	sprite = projectile_stats.texture

func _setup_sprite() -> void:
	sprite_rid = RenderingServer.canvas_item_create()
	RenderingServer.canvas_item_set_parent(sprite_rid, get_canvas_item())
	RenderingServer.canvas_item_add_texture_rect(sprite_rid, Rect2(-sprite.get_size() / 2, sprite.get_size()), sprite)
	#var xform = Transform2D().rotated(start_rotation).translated(start_position)
	#RenderingServer.canvas_item_set_transform(sprite_rid, xform)
	# Reset physics interpolation for this item.
	RenderingServer.canvas_item_reset_physics_interpolation(sprite_rid)

func _ready() -> void:
	_setup_sprite()
	position = start_position
	rotation = start_rotation
	if projectile_stats.projectile_speed == 0:
		_hitscan_fire()
	else:
		velocity = Vector2.from_angle(start_rotation).normalized() * projectile_stats.projectile_speed
		var new_collision_shape = RectangleShape2D.new() 
		new_collision_shape.set_size(Vector2(10, 5))
		#new_collision_shape.set_radius(5.1)
		#print(velocity)
		self.collision_mask = 12
		get_node("ProjectileCollision").set_shape(new_collision_shape)
	pass # Replace with function body.
	#https://docs.godotengine.org/en/stable/tutorials/performance/using_servers.html
	#later tho, now base implement


func is_valid_target(id: int) -> bool:
	return (!instance_from_id(id).has_method("_on_impact") and !instance_from_id(id).is_queued_for_deletion() and instance_from_id(id).is_class("RigidBody2D"))

func _physics_process(delta: float) -> void: 
	#print(delta)
	move_and_collide(velocity * delta,false,0.1)
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(global_position, global_position + velocity.normalized() * 10 )
	query.exclude = [self.get_rid()]
	var result = space_state.intersect_ray(query)
	if !result.is_empty():
		if collision_flag and is_valid_target(result.collider_id):
			_deal_damage(instance_from_id(result.collider_id))
		elif(collision_flag and instance_from_id(result.collider_id).is_class("StaticBody2D")):
			queue_free()
	


func _deal_damage(body: Node2D) -> void:
	queue_free()
	pass

func _explode() -> void:
	#will increase collision shape size (gradually? or Instantly?)
	pass
	
func _on_timer_timeout() -> void:
	_explode()
	queue_free()

func _hitscan_fire() -> void:
	pass


func _on_impact(body: Node) -> void:
	#_deal_damage(body)
	#print("TEST")
	queue_free()
	pass # Replace with function body.


func startup_timer_timeout() -> void:
	collision_flag = true
