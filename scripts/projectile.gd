
class_name Projectile extends RigidBody2D
static var projectile_stats: ProjectileRes
static var start_position: Vector2
static var start_rotation: float
static var is_projectile: bool = true
var sprite: Sprite2D
var velocity
var collision_flag: bool = false


static func setup(new_position: Vector2, new_rotation: float, Projectile:ProjectileRes) -> void:
	start_position = new_position
	start_rotation = new_rotation
	projectile_stats = Projectile

func _ready() -> void:
	position = start_position
	rotation = start_rotation
	get_node("Sprite2D").rotation = start_rotation
	get_node("ProjectileCollision")
	if projectile_stats.projectile_speed == 0:
		_hitscan_fire()
	else:
		velocity = Vector2.from_angle(start_rotation).normalized() * projectile_stats.projectile_speed
		var new_collision_shape = RectangleShape2D.new() 
		new_collision_shape.set_size(Vector2(projectile_stats.projectile_speed * 10, 5))
		#new_collision_shape.set_radius(5.1)
		#print(velocity)
		self.collision_mask = 12
		get_node("ProjectileCollision").set_shape(new_collision_shape)
	pass # Replace with function body.
	#https://docs.godotengine.org/en/stable/tutorials/performance/ausing_servers.html
	#later tho, now base implement


func _physics_process(delta: float) -> void: 
	#print(delta)
	move_and_collide(velocity * delta * 100,false,0.1)
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(position, velocity * delta * 100)
	query.exclude = [self.get_rid()]
	var result = space_state.intersect_ray(query)
	print(instance_from_id(result.collider_id).has_method("_on_impact"))
	if collision_flag and !instance_from_id(result.collider_id).has_method("_on_impact") and !instance_from_id(result.collider_id).is_queued_for_deletion():
		_deal_damage(instance_from_id(result.collider_id))
	#if !instance_from_id(result.collider_id).get_class() == "Projectile":
	#	queue_free()
	


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
