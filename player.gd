extends RigidBody2D

@export var max_engine_power = 100 
@export var acceleration_mult : int = 1
@export var traction_Coefficient : float = 0.02 #MUST BE SMOL
@export var max_velocity: int = 20
var screen_size # Size of the game window. # temp
var velocity : Vector2
var engine_power : float
var rotation_direction : float

func _ready() -> void:
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
		if Input.is_action_pressed("move_backward") and engine_power > -max_engine_power:
			engine_power -=1 * acceleration_mult
			
		if Input.is_action_pressed("move_forward") and engine_power < max_engine_power:
			engine_power +=1 * acceleration_mult
	else:
		engine_power = 0 
		
	if velocity.length() <= 1:
		velocity = Vector2.ZERO
	elif velocity.length() >= max_velocity:
		velocity = velocity.normalized()*max_velocity * 0.99
	
	velocity -= velocity.normalized() * traction_Coefficient * mass * 9.81
	velocity.x += engine_power * cos(rotation_direction)
	velocity.y += engine_power * sin(rotation_direction)

	rotation = rotation_direction
	move_and_collide(velocity * delta)
	get_node("player_main_turret").main_body_rotation=rotation_direction
	#print("position = ",position, " velocity = ", velocity.length(), "speed = ", engine_power)	
