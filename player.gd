extends Area2D

@export var max_detached_speed = 100 # How fast the player will move (pixels/sec).
@export var acceleration_mult : int = 1
@export var traction_maintained_percentage: float = 0.975 #MUST BE SMOL
@export var max_velocity: int = 20
var screen_size # Size of the game window.
var velocity : Vector2
var detached_speed : float
var rotation_direction : float
signal hit


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rotation_direction = 3*PI/2
	screen_size = get_viewport_rect().size
	position = screen_size/2


func start(pos):
	position = pos
	show()
	get_node("CollisionShape2D").disabled = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("move_right"):
		rotation_direction += 0.05
		if rotation_direction >= 2*PI:
			rotation_direction = 0
			
	if Input.is_action_pressed("move_left"):
		rotation_direction -= 0.05
		if rotation_direction <= 0:
			rotation_direction = 2*PI
	
	if(Input.is_action_pressed("move_backward") or Input.is_action_pressed("move_forward")):		
		if Input.is_action_pressed("move_backward") and detached_speed > -max_detached_speed:
			detached_speed -=1 * acceleration_mult
			
		if Input.is_action_pressed("move_forward") and detached_speed < max_detached_speed:
			detached_speed +=1 * acceleration_mult
	else:
		detached_speed = 0 
		
	velocity.x = velocity.x * traction_maintained_percentage 
	velocity.y = velocity.y * traction_maintained_percentage  
	if velocity.length() <= 1:
		velocity = Vector2.ZERO
	elif velocity.length() >= max_velocity:
		velocity = velocity.normalized()*max_velocity * 0.99
	
	velocity.x += detached_speed * cos(rotation_direction)
	velocity.y += detached_speed * sin(rotation_direction)

	rotation = rotation_direction
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
	print("position = ",position, " velocity = ", velocity.length(), "speed = ", detached_speed)	

func _on_body_entered(body: Node2D) -> void:
	hide() # Player disappears after being hit.
	hit.emit()
	# Must be deferred as we can't change physics properties on a physics callback.
	get_node("CollisionShape2D").set_deferred("disabled", true)
