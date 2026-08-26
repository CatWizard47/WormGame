extends Area2D
static var projectile_stats: ProjectileRes
static var start_position: Vector2
static var start_rotation: float
# Called when the node enters the scene tree for the first time.

static func setup(new_position: Vector2, new_rotation: float, Projectile:ProjectileRes) -> void:
	start_position = new_position
	start_rotation = new_rotation
	projectile_stats = Projectile

func _ready() -> void:
	position = start_position
	rotation = start_rotation
	pass # Replace with function body.
#https://docs.godotengine.org/en/stable/tutorials/performance/using_servers.html
#later tho, now base implement

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	self.queue_free()
