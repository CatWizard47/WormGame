extends RigidBody2D

@export var status: Status = Status.new(100,100,100)
@export var max_engine_power = 10 #max velocity is 10 times this
@export var acceleration_mult : float = 0.5
@export var traction_Coefficient : float = 0.02 #MUST BE SMOL
@export var locomotion_node_rotation_speed: float = 0.025 # in radians
@export var test_projectile: ProjectileRes
var node_rids: Array = Array()
var screen_size # Size of the game window. # temp
var velocity: Vector2
var engine_power: float
var locomotive_rotation: float
var locomotive_nodes: Node
var locomotive_nodes_rotated_this_tick: bool = false
var powertrain_radian_ratio:float
var locomotive_node_count: float
enum weapon_groups{	#hipothetically not needed to be written like this, also may need to switch to a bool array for multiple weapon gr.s at once
	ONE = 1,			#TODO IN UI needs to change active weapon with reparent(node) method.
	TWO = 2,
	THREE = 3,
	FOUR = 4
}
var player_controlled_weapon_group: int	
var projectile_scene


func _ready() -> void:
	screen_size = get_viewport_rect().size
	locomotive_nodes = get_node("locomotion_nodes")
	locomotive_node_count = locomotive_nodes.get_child_count()
	position = screen_size/4 #TEMP
	_update_all_rids()
	_connect_fire_signals()
	player_controlled_weapon_group = weapon_groups.ONE #TEMP
	#get_node("weapon_group_1/player_main_turret").allowed_ammunition_type = "TEST" #TEMP


func _connect_fire_signals()->void: #should not be more than 4 weapon groups	#this is terrible and in need of rework
	if !get_node("weapon_group_1").get_children().is_empty():	
		for node: Node in get_node("weapon_group_1").get_children():
			node.Projectile_fired.connect(_instantiate_projectile)
	if !get_node("weapon_group_2").get_children().is_empty():
		for node: Node in get_node("weapon_group_1").get_children():
			node.Projectile_fired.connect(_instantiate_projectile)
	if !get_node("weapon_group_3").get_children().is_empty():
		for node: Node in get_node("weapon_group_1").get_children():
			node.Projectile_fired.connect(_instantiate_projectile)
	if !get_node("weapon_group_4").get_children().is_empty():
		for node: Node in get_node("weapon_group_1").get_children():
			node.Projectile_fired.connect(_instantiate_projectile)


func _update_all_rids() -> void:
	for loco_node: Node in locomotive_nodes.get_children():
		node_rids.append(loco_node.get_rid())
	node_rids.append(self.get_rid())
	

func _rotate_locomotive_nodes(rotation_speed:float) ->void:
	locomotive_rotation = 0
	for loco_node: Node in locomotive_nodes.get_children():
		locomotive_rotation += loco_node.change_rotation(rotation_speed)
	locomotive_rotation = locomotive_rotation / locomotive_node_count
	if abs(locomotive_rotation) > PI/2.02:	#crude implement but werks
		locomotive_nodes_rotated_this_tick = false
	else:	 
		locomotive_nodes_rotated_this_tick = true
	
		
func _animate_locomotive_nodes(speed:float)->void:
	for loco_node: Node in locomotive_nodes.get_children():
		loco_node.animate(speed)
		
		
func _stop_locomotive_node_animation()->void:
	for loco_node: Node in locomotive_nodes.get_children():
		loco_node.pause_animation()		


func _movement(delta: float) -> void:
	locomotive_nodes_rotated_this_tick = false
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
		if	!locomotive_nodes_rotated_this_tick:
			_animate_locomotive_nodes(engine_power)
	else:
		engine_power = 0
		if !locomotive_nodes_rotated_this_tick:
			_stop_locomotive_node_animation() 
	powertrain_radian_ratio=abs(locomotive_rotation / (PI / 2.01))	
	if  locomotive_rotation > 0.01:	#devided by 80 to seem more 'realistic' ig
		rotation -= ( engine_power / (max_engine_power * 80) ) * powertrain_radian_ratio	
	elif locomotive_rotation < 0.01:
		rotation += ( engine_power / (max_engine_power * 80) ) * powertrain_radian_ratio	
	velocity -= velocity.normalized() * traction_Coefficient * mass * 9.81
	velocity = Vector2.from_angle(rotation).normalized() 
	velocity = velocity * engine_power * 10 * (1 - powertrain_radian_ratio)
	if velocity.length() <= 1:
		velocity = Vector2.ZERO		
	move_and_collide(velocity * delta)
	
func _fire_weapon_group()-> void:
	#var projectile 
	#var weapon_group_node: Node = get_node("weapon_group_" + str(player_controlled_weapon_group))
	for node: Node in get_node("weapon_group_" + str(player_controlled_weapon_group)).get_children():
		node.Load(test_projectile) #TEMP
		node.Load(test_projectile)
		node.Load(test_projectile)
		node.Load(test_projectile)
		node.fire()


func _instantiate_projectile(projectile_position:Vector2, projectile_rotation:float, created_projectile:ProjectileRes) -> void:
	#projectile_scene = preload("res://Scenes/projectile.tscn").instantiate()
	projectile_scene = Projectile.new(projectile_position, projectile_rotation, created_projectile,node_rids,12)
	add_sibling(projectile_scene)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	_movement(delta)
	if Input.is_action_pressed("M1_clicked"):
		_fire_weapon_group()
		#print(get_node("turret_nodes/player_main_turret").get_new_bullet_position())
	#print("position = ",position, " velocity = ", velocity.length(), "speed = ", engine_power)	
