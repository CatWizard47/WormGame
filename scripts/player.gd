extends RigidBody2D

@export var max_engine_power = 10 
@export var acceleration_mult : float = 0.5
@export var traction_Coefficient : float = 0.02 #MUST BE SMOL
@export var max_velocity: int = 100
@export var locomotion_node_rotation_speed: float = 0.025
var locomotive_nodes: Node
var screen_size # Size of the game window. # temp
var velocity: Vector2
var engine_power: float
var locomotive_rotation: float
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
	
	if(Input.is_action_pressed("move_backward") or Input.is_action_pressed("move_forward")):		
		if Input.is_action_pressed("move_backward") and engine_power > -max_engine_power:
			#engine_power -=1
			engine_power -=1 * acceleration_mult
			
		if Input.is_action_pressed("move_forward") and engine_power < max_engine_power:
			#engine_power +=1
			engine_power +=1 * acceleration_mult
	else:
		engine_power = 0 
	
		
	#_apply_thrust_with_locomotive_nodes(engine_power)
	if  locomotive_rotation > 0.01:
		#rotation_direction -= engine_power/100.0
		rotation -= engine_power/ (500.0 * PI/2) 
		#if rotation_direction < 0 :
		#	rotation_direction = 2*PI
		#	print("TEST")
	elif locomotive_rotation < 0.01:
		#rotation_direction += engine_power/100.0
		rotation += engine_power/(500.0 * PI/2)
		#if rotation_direction > 2*PI :
		#	rotation_direction = 0
		#	print("AIE")
	print(rotation)
	 
	#print(locomotive_rotation ," <-loco rotation-> ", rotation)	
	#rotation=rotation_direction
	velocity -= velocity.normalized() * traction_Coefficient * mass * 9.81
	#velocity = Vector2.from_angle(rotation).normalized() * engine_power * 10 
	velocity.x += engine_power * cos(rotation)
	velocity.y += engine_power * sin(rotation)
	print(velocity)
	
	if velocity.length() <= 1:
		velocity = Vector2.ZERO
	elif velocity.length() >= max_velocity:
		velocity = velocity.normalized()*max_velocity * 0.99

	move_and_collide(velocity * delta)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	_movement(delta)
	#print("position = ",position, " velocity = ", velocity.length(), "speed = ", engine_power)	
