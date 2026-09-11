class_name TrackModule extends StaticBody2D
var horizontal_orientation_inverted_flag: bool = false
@export var left_module: AnimatedSprite2D
@export var right_module: AnimatedSprite2D
@export var animation_timer: Timer
var animation_stop_flag: bool = false

func _ready() -> void:
	if position.x < 0:
		horizontal_orientation_inverted_flag = true	
	#print(instance_from_id(self.get_instance_id()))
	#left_module = get_node("Left_module")
	#right_module = get_node("Right_module")
	#animation_timer = get_node("Animation_timer")

func change_rotation(rotation_speed: float) -> float:
	animation_timer.start()
	if horizontal_orientation_inverted_flag:
		rotation -= rotation_speed
		rotation = clampf( rotation , -PI / 2.01, +PI / 2.01)
		right_module.play("Move")
		left_module.play_backwards("Move")
		return rotation
	else:
		rotation += rotation_speed
		rotation = clampf( rotation , -PI / 2.01, +PI / 2.01)
		left_module.play("Move")
		right_module.play_backwards("Move")
		return -rotation

func pause_animation() -> void:
	left_module.pause()
	right_module.pause()
	animation_stop_flag = false
	
func animate(speed: float) -> void:
	left_module.play("Move", signf(speed))
	right_module.play("Move", signf(speed))
	animation_stop_flag = true
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func _on_animation_timer_timeout() -> void:
	#print("TIMEOUT")
	if !animation_stop_flag:
		pause_animation()
