extends RigidBody2D
var maintained_rotation: float
var horizontal_orientation_inverted_flag: bool = false
var vertical_orientation_inverted_flag: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if position.y < 0:
		vertical_orientation_inverted_flag = true
	if position.x < 0:
		horizontal_orientation_inverted_flag = true	

func change_rotation(rotation_speed: float) -> void:
	if horizontal_orientation_inverted_flag:
		rotation += rotation_speed
	else:
		rotation -= rotation_speed
	rotation = clampf( rotation , -PI / 2.0, +PI / 2.0)

#this output is going to get += to the parent, 
func apply_thrust(engine_power:float) -> Array: #[0.x|1.y] Vector2, velocity; [2] added rotation in radian
	var Output: Array = [0,0,0]
	Output[0] = (Vector2.from_angle(rotation) * engine_power).x
	Output[1] = (Vector2.from_angle(rotation) * engine_power).y
	if horizontal_orientation_inverted_flag:
		Output[2] = -atan2(Output[1],Output[0]) / 100.0	
	else:
		Output[2] = atan2(Output[1],Output[0]) / 100.0
	return Output

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:	
	pass
