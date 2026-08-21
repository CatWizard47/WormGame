extends Node2D

@export var rotation_speed : float = 0.01
@export var start_rotation_radian: float = 0 # 0rad = aligned with hull #
@export var accuracy_margin_radian: float = 0.01
@export var rotation_limit_radian: float = PI  # must be within [PI, 0), PI to ignore 
var left_rotation_limit: float
var right_rotation_limit: float
var mouse_position: Vector2
var desired_rotation: float
var rotation_flag: bool


# Called when the node enters the scene tree for the first time.
func _ready() -> void: 
	rotation_flag = true 
	rotation = start_rotation_radian
	left_rotation_limit = start_rotation_radian - rotation_limit_radian
	right_rotation_limit = start_rotation_radian + rotation_limit_radian
	if right_rotation_limit > PI:
		right_rotation_limit -= 2 * PI
	if start_rotation_radian >= PI:	#might need better cond, 
		right_rotation_limit = left_rotation_limit + 2 * rotation_limit_radian	
	elif start_rotation_radian <= -PI:
		left_rotation_limit = right_rotation_limit - 2 * rotation_limit_radian
	if rotation_limit_radian == PI:
		rotation_flag = false


func rotation_drive_check() -> bool:
	return ( desired_rotation - global_rotation  > 0 and  desired_rotation - global_rotation < PI ) or desired_rotation - global_rotation < -PI 


func _rotate() -> void:
	mouse_position = get_local_mouse_position()
	desired_rotation = mouse_position.angle() 
	if desired_rotation > 0:
		rotation += rotation_speed
	else:
		rotation -= rotation_speed
	if rotation_flag:
		rotation = clampf(rotation, left_rotation_limit, right_rotation_limit)
	else:
		if abs(rotation) > PI:
			rotation = -signf(rotation) * PI
	print(rotation)
		
	#print("cond = ", desired_rotation - global_rotation, "  desired = " ,desired_rotation)
	#print("global = ", global_rotation, "  local = " ,rotation)
	#print(left_rotation_limit, "  ",rotation," ", right_rotation_limit)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void: 
	_rotate()
	if Input.is_action_pressed("M1_clicked"): 
		print("Shootat:") 
	
