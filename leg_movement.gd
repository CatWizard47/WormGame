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
var parent_rotation: float


func _animate_leg_arm() -> void:
	arm.global_position = ( foot.global_position + global_position ) / 2.0
	arm.global_rotation = atan2( (global_position - foot.global_position).y , (global_position - foot.global_position).x)
	arm.scale.x = (global_position - foot.global_position).length() /10

func _find_foot_placement() -> void:
	foot_placement = global_position + parent_velocity/2.0 
	var rotated_vector: Vector2
	rotated_vector.x=0
	rotated_vector.y=30
	if inverted_orientation_flag: 
		foot_placement -= rotated_vector.rotated(parent_rotation)
	else:
		foot_placement += rotated_vector.rotated(parent_rotation)
	foot.global_position = foot_placement
	step_happening_flag = false
	step_cooldown_flag = false
	get_node("step_timer").start()
	
	
func _process(delta: float) -> void:
	parent_velocity = get_parent().velocity
	parent_rotation = get_parent().rotation
	if(step_happening_flag and step_cooldown_flag):
		_find_foot_placement()
	foot.global_position = foot_placement # to zmienić na move_and_collide() tylko że w lokalnym
	if (foot.global_position - global_position).length() >= leg_reach:
		step_happening_flag = true
	#if inverted_orientation_flag:
	#	if foot.position.y >= 5:
	#		_find_foot_placement()
	#else:
	#	if foot.position.y <= -5:
	#		_find_foot_placement() 
	_animate_leg_arm()
	


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	arm = get_node("leg_node/leg_arm_sprite")
	foot = get_node("leg_node/leg_foot")
	if(rotation < 0):
		inverted_orientation_flag = true #left side of the hull
	else:
		inverted_orientation_flag = false 
	arm.position.x += leg_reach / 2.0
	foot.position.x += leg_reach + 10
	foot_placement = global_position 
	get_node("step_timer").wait_time = step_time


func _on_step_timer_timeout() -> void:
	step_cooldown_flag = true
