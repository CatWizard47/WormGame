extends Sprite2D
var leg_reach: int 
var foot_placement: Vector2
var foot: Sprite2D
var arm: Sprite2D
var step_happening_flag: bool = false
var inverted_orientation_flag: bool = false 
var parent_velocity: Vector2

func setup(reach: int, time: float) -> void:
	leg_reach = reach
	get_node("Step_timer").wait_time = time	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	parent_velocity = get_parent().velocity
	print(parent_velocity)
	if(!step_happening_flag):
		foot.global_position -= parent_velocity
		foot.position.x = clampf(foot.position.x, -100,100)
		foot.position.y = clampf(foot.position.y, -100,100) 
		pass
	else:
		step_happening_flag = false
		pass



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	arm = get_node("leg_arm")
	foot = get_node("leg_arm/leg_foot")
	if(rotation < 0):
		inverted_orientation_flag = true #left side of the hull
	else:
		inverted_orientation_flag = false 
	pass 


func _on_step_timer_timeout() -> void:
	step_happening_flag = true
