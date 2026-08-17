extends Node2D

var mouse_position: Vector2
var desired_rotation: float
@export var rotation_speed : float = 0.01
@export var start_rotation_radian: float = 0 # 0rad = aligned with hull #
@export var accuracy_margin_radian: float = 0.01
@export var rotation_limit_radian: float = PI/2 # must be within (PI, 0]  0 to ignore 
var left_rotation_limit: float
var right_rotation_limit: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global_rotation = start_rotation_radian
	if start_rotation_radian >= 0:
		left_rotation_limit = start_rotation_radian - PI + rotation_limit_radian
		right_rotation_limit = start_rotation_radian - PI - rotation_limit_radian
		if right_rotation_limit <= -PI:
			right_rotation_limit += 2 * PI
			
	else:
		left_rotation_limit = start_rotation_radian + PI - rotation_limit_radian
		right_rotation_limit = start_rotation_radian + PI + rotation_limit_radian
		if left_rotation_limit >= PI:
			right_rotation_limit -= 2 * PI
			


func rotation_drive_check() -> bool:
	return ( desired_rotation - global_rotation  > 0 and  desired_rotation - global_rotation < PI ) or desired_rotation - global_rotation < -PI 

func rotation_limit_check() -> bool:
	return rotation < right_rotation_limit  and rotation > left_rotation_limit 

func _rotate() -> void:
	mouse_position = get_global_mouse_position()
	desired_rotation = atan2( (mouse_position - global_position).y , (mouse_position - global_position).x) 	
	if  abs(global_rotation - desired_rotation) > accuracy_margin_radian: 
		#shitass conditional, but works
		if rotation_drive_check():
			if rotation_limit_check():
				rotation += rotation_speed
				rotation = clampf(rotation,left_rotation_limit * 0.99,right_rotation_limit * 0.99)
		else:
			if rotation_limit_check():
				rotation -=rotation_speed
				rotation = clampf(rotation,left_rotation_limit * 0.99,right_rotation_limit * 0.99)
	else:
		global_rotation = desired_rotation
	#print("cond = ", desired_rotation - global_rotation, "  desired = " ,desired_rotation)
	#print("global = ", global_rotation, "  local = " ,rotation)
	print(left_rotation_limit, "  ",rotation," ", right_rotation_limit)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void: 
	_rotate()
	if Input.is_action_pressed("M1_clicked"): 
		print("Shootat:") 
	
