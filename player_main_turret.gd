extends Node2D

var mouse_position: Vector2
var desired_rotation: float
@export var rotation_speed : float = 0.01
@export var start_rotation_radian: float # is offset by -PI/2 for some reason since rot:0deg = right 
@export var accuracy_margin_radian: float = 0.003

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global_rotation = start_rotation_radian
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	mouse_position = get_viewport().get_mouse_position()
	if Input.is_action_pressed("M1_clicked"): 
		print("Shootat:")
	if mouse_position.x <= global_position.x:
		desired_rotation = atan( (global_position - mouse_position ).y / (global_position - mouse_position ).x) + PI
	else:
		desired_rotation = atan( (global_position - mouse_position ).y / (global_position - mouse_position ).x) 
	if  abs(global_rotation - desired_rotation) > accuracy_margin_radian: 
		if desired_rotation - global_rotation > 0 and desired_rotation - global_rotation < 3/2 * PI:
			global_rotation += rotation_speed
		else:
			global_rotation -=rotation_speed
	else:
		global_rotation = desired_rotation
