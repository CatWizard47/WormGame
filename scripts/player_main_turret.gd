extends Node2D

@export var rotation_speed : float = 0.01
@export var start_rotation_radian: float = 0 # 0rad = aligned with hull #
@export var accuracy_margin_radian: float = 0.001
@export var rotation_limit_radian: float = PI  # must be within [PI, 0), PI to ignore 
@export var maximum_projectiles: int = 1024
@export var turret_texture: Texture2D
@export var gun_texture: Texture2D
var left_rotation_limit: float
var right_rotation_limit: float
var mouse_position: Vector2
var desired_rotation: float
var rotation_flag: bool
var is_weapon_active: bool = true #to be false in actual code


func _ready() -> void: 
	#get_node("Cooldown_timer").wait_time = shooting_cooldown
	get_node("TurretSprite").set_texture(turret_texture)
	get_node("GunSprite").set_texture(gun_texture)
	rotation_flag = true 
	rotation = start_rotation_radian
	left_rotation_limit = start_rotation_radian - rotation_limit_radian
	right_rotation_limit = start_rotation_radian + rotation_limit_radian
	if right_rotation_limit > PI:
		right_rotation_limit -= 2 * PI
	if start_rotation_radian >= PI:	#might need better cond, 
		right_rotation_limit = left_rotation_limit + 2 * rotation_limit_radian	
	elif start_rotation_radian <= -PI:
		left_rotation_limit = right_rotation_limit - 2 * rotation_limit_radian
	if rotation_limit_radian == PI:
		rotation_flag = false


func fire() -> void:
	print("BANG!") # animation 'ere
	pass


func _rotate() -> void:
	mouse_position = get_local_mouse_position()
	desired_rotation = mouse_position.angle() 
	if abs(rotation - desired_rotation) > accuracy_margin_radian:
		if desired_rotation > 0:
			rotation += rotation_speed
		else:
			rotation -= rotation_speed
		if rotation_flag:
			rotation = clampf(rotation, left_rotation_limit, right_rotation_limit)
		else:
			if abs(rotation) > PI:
				rotation = -signf(rotation) * PI


func get_new_bullet_position() -> Vector2:
	var Output: Vector2
	Output = global_position
	Output += Vector2.from_angle(global_rotation).normalized() * get_node("GunSprite").get_rect().size.y
	return Output
	
func get_turret_rotation() -> float:
	return global_rotation

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	if is_weapon_active: #place this into the player node instead
		_rotate()
		#if Input.is_action_pressed("M1_clicked") and can_fire_flag: 
		#	print("Shootat:")
		#	projectile_scene = preload("res://Scenes/projectile.tscn").instantiate()
		#	if current_projectile_iterator < maximum_projectiles and !has_node("Projectile_" + str(current_projectile_iterator)):
		#		projectile_scene.set_name("Projectile_" + str(current_projectile_iterator))
		#		add_child(projectile_scene)
		#		print("Projectile_" + str(current_projectile_iterator))
		#		can_fire_flag = false
		#		get_node("Cooldown_timer").start()
		#	if current_projectile_iterator == maximum_projectiles:
		#		current_projectile_iterator = 0 
		#	current_projectile_iterator += 1
