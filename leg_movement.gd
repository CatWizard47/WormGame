extends Sprite2D
var leg_reach: int = 10 
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
	if(!step_happening_flag):
		#foot.global_position = foot_placement
		#if inverted_orientation_flag:
		#	pass
		#else:
		#	pass
		foot.global_position = foot_placement
	else:
		if inverted_orientation_flag:
			foot_placement = global_position + parent_velocity/2.0 + parent_velocity.orthogonal() / 2.0
		else:
			foot_placement = global_position + parent_velocity/2.0 - parent_velocity.orthogonal() / 2.0 
		foot.global_position = foot_placement
		if foot_placement.length()>= leg_reach:
			step_happening_flag = false
		print(foot_placement)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	arm = get_node("leg_arm")
	foot = get_node("leg_arm/leg_foot")
	if(rotation < 0):
		inverted_orientation_flag = true #left side of the hull
		arm.position.x += leg_reach / 2.0
		foot.position.x += leg_reach
	else:
		inverted_orientation_flag = false 
		arm.position.x += leg_reach / 2.0
		foot.position.x += leg_reach
	foot_placement = global_position 
	pass 


func _on_step_timer_timeout() -> void:
	step_happening_flag = true
