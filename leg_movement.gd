extends Sprite2D
@export var step_time: float
@export var leg_reach: int = 50 
var foot_placement: Vector2
var foot: RigidBody2D
var arm: Node2D
var step_happening_flag: bool = false
var inverted_orientation_flag: bool = false
var step_cooldown_flag: bool  = true
var parent_velocity: Vector2

func setup(reach: int, time: float) -> void:
	leg_reach = reach
	get_node("Step_timer").wait_time = time	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	parent_velocity = get_parent().velocity
	if(step_happening_flag and step_cooldown_flag):
		foot_placement = global_position + parent_velocity/2.0
		foot.global_position = foot_placement
		step_happening_flag = false
		step_cooldown_flag = false
		get_node("step_timer").start()
		print(foot_placement)
	
	foot.global_position = foot_placement
		#foot.move_and_collide(foot_placement)
		#if foot.position.y < position.y - leg_reach/2.0 or foot.position.y > position.y + leg_reach/2.0:
	if (foot.global_position - global_position).length() >=leg_reach:
		step_happening_flag = true
	


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	arm = get_node("leg_node")
	foot = get_node("leg_node/leg_foot")
	if(rotation < 0):
		inverted_orientation_flag = true #left side of the hull
		arm.position.x += leg_reach / 2.0
		foot.position.x += leg_reach
	else:
		inverted_orientation_flag = false 
		arm.position.x += leg_reach / 2.0
		foot.position.x += leg_reach
	foot_placement = global_position 
	get_node("step_timer").wait_time = step_time


func _on_step_timer_timeout() -> void:
	step_cooldown_flag = true
