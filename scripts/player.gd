extends RigidBody2D

@export var max_engine_power = 10 #max velocity is 10 times this
@export var acceleration_mult : float = 0.5
@export var traction_Coefficient : float = 0.02 #MUST BE SMOL
@export var locomotion_node_rotation_speed: float = 0.025
@export var max_rotation_speed_radian:float
var locomotive_nodes: Node
var screen_size # Size of the game window. # temp
var velocity: Vector2
var engine_power: float
var locomotive_rotation: float
var powertrain_radian_ratio:float
var node_count: float


func _ready() -> void:
	screen_size = get_viewport_rect().size
	locomotive_nodes = get_node("locomotion_nodes")
	node_count = locomotive_nodes.get_child_count()
	position = screen_size/2


func start(pos):
	position = pos
	show()
	get_node("CollisionShape2D").disabled = false


func _rotate_locomotive_nodes(rotation_speed:float) ->void:
	locomotive_rotation = 0
	for loco_node: Node in locomotive_nodes.get_children():
		locomotive_rotation += loco_node.change_rotation(rotation_speed)
	locomotive_rotation = locomotive_rotation / node_count 
		

func _movement(delta: float) -> void:
	if Input.is_action_pressed("move_right"):
		_rotate_locomotive_nodes(locomotion_node_rotation_speed)
			
	if Input.is_action_pressed("move_left"):
		_rotate_locomotive_nodes(-locomotion_node_rotation_speed)
	
	##TODO - Movement comm to set loco_nodes rotation to 0 
	#not sure if needed tho, the margin makes it somewhat unnecessary
	
	if(Input.is_action_pressed("move_backward") or Input.is_action_pressed("move_forward")):		
		if Input.is_action_pressed("move_backward") and engine_power > -max_engine_power:
			engine_power -=1 * acceleration_mult
			
		if Input.is_action_pressed("move_forward") and engine_power < max_engine_power:
			engine_power +=1 * acceleration_mult
	else:
		engine_power = 0 
	
	powertrain_radian_ratio=abs(locomotive_rotation / (PI / 2.01))	
	if  locomotive_rotation > 0.01:	#devided by 80 to seem more 'realistic' ig
		rotation -= ( engine_power / (max_engine_power * 80) ) * powertrain_radian_ratio
		
	elif locomotive_rotation < 0.01:
		rotation += ( engine_power / (max_engine_power * 80) ) * powertrain_radian_ratio
		
	velocity -= velocity.normalized() * traction_Coefficient * mass * 9.81
	velocity = Vector2.from_angle(rotation).normalized() 
	velocity = velocity * engine_power * 10 * (1 - powertrain_radian_ratio)
	print(velocity.length())
	if velocity.length() <= 1:
		velocity = Vector2.ZERO
			
	move_and_collide(velocity * delta)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	_movement(delta)
	#print("position = ",position, " velocity = ", velocity.length(), "speed = ", engine_power)	
