extends RigidBody2D
static var projectile_stats: ProjectileRes
static var start_position: Vector2
static var start_rotation: float
var velocity


static func setup(new_position: Vector2, new_rotation: float, Projectile:ProjectileRes) -> void:
	start_position = new_position
	start_rotation = new_rotation
	projectile_stats = Projectile

func _ready() -> void:
	position = start_position
	rotation = start_rotation
	if projectile_stats.projectile_speed == 0:
		_hitscan_fire()
	else:
		velocity = Vector2.from_angle(rotation).normalized() * projectile_stats.projectile_speed
		#var new_collision_shape = RectangleShape2D.new() 
		var new_collision_shape = CircleShape2D.new()
		#new_collision_shape.set_size(Vector2(3.0, 10.0))
		new_collision_shape.set_radius(20.0)
		self.collision_mask = 0 
		get_node("ProjectileCollision").set_shape(new_collision_shape)
	pass # Replace with function body.
	#https://docs.godotengine.org/en/stable/tutorials/performance/using_servers.html
	#later tho, now base implement


func _process(delta: float) -> void:
	move_and_collide(velocity)

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
	_deal_damage(body)
	print("TEST")
	pass # Replace with function body.


func startup_timer_timeout() -> void:
	self.collision_mask = 12
