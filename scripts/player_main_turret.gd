class_name PlayerMainTurret extends Marker2D

@export var rotation_speed : float = 0.01		# might have to change these to static after changing this to 
@export var start_rotation_radian: float = 0 	#0rad = aligned with hull #
@export var rotation_limit_radian: float = PI  #must be within [PI, 0), PI to ignore 
@export var turret_texture: Texture2D
@export var gun_texture: Texture2D
@export var allowed_ammunition_type: String 	#shit like 40mm or whatevs = 
@export var cooldown_time:float = 1
@export var maximum_magazine_size: int = 100
@export var burst_fire_horizontal_translate: float = 0
@export var burst_fire_count: int = 1
@export var firing_delay: float = 0.05 # must be at leas 0.05
@export var innacuracy_degrees: float = 1.5
var accuracy_margin_radian: float = 0.001
var left_rotation_limit: float
var right_rotation_limit: float
var mouse_position: Vector2
var desired_rotation: float
var is_rotation_limited: bool = true
var can_fire_flag: bool = true
var Burst_direction: int = -1
var current_burst_count: int
var is_weapon_active: bool = true 				#starting value to be false in actual code
var available_ammunition_types: Array 			#Types of ammunition as in ProjectileRes
var loaded_ammunition: Array					#int array with amm
signal projectile_fired(projectile_position, projectile_rotation, projectile_resource)



func _ready() -> void: 
	#get_node("Cooldown_timer").wait_time = shooting_cooldown	# might be necessary to keep, 
	#get_node("TurretSprite").set_texture(turret_texture)
	#get_node("GunSprite").set_texture(gun_texture)
	get_node("CooldownTimer").wait_time = cooldown_time
	get_node("BurstFireCooldownTimer").wait_time = firing_delay
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
		is_rotation_limited = false

func Load(new_ammunition: ProjectileRes) -> bool:
	if new_ammunition.type == allowed_ammunition_type and loaded_ammunition.size() <= maximum_magazine_size:	
		if !available_ammunition_types.has(new_ammunition):
			available_ammunition_types.append(new_ammunition)
		loaded_ammunition.append(available_ammunition_types.find(new_ammunition))
	else:
		return false
		
	return true


func toggle_active_state()->void:
	if is_weapon_active:
		is_weapon_active = false
	else:
		is_weapon_active = true


func fire() -> void: 
	if can_fire_flag and abs(desired_rotation) < 0.01 and is_weapon_active:
		print(get_n_ammunition_load(5))
		current_burst_count = burst_fire_count
		Burst_direction = Burst_direction * -1
		get_node("BurstFireCooldownTimer").timeout.emit()
		get_node("CooldownTimer").start()
		can_fire_flag = false


func get_n_ammunition_load(n:int)->Array:
	var output:Array = Array()
	if loaded_ammunition.size() >= n:
		for i:int in range(n):
			output.append(available_ammunition_types[loaded_ammunition[-i]])
	return output


func get_new_bullet_position() -> Vector2:
	var Output: Vector2
	Output = global_position
	if burst_fire_count%2 == 0:
		Output += Vector2.from_angle(global_rotation+PI/2.0).normalized() * burst_fire_horizontal_translate * (current_burst_count - burst_fire_count/2.0) * Burst_direction
		Output += Vector2.from_angle(global_rotation+PI/2.0).normalized() * burst_fire_horizontal_translate * 0.5 * Burst_direction
	else:
		Output += Vector2.from_angle(global_rotation+PI/2.0).normalized() * burst_fire_horizontal_translate * (current_burst_count - (burst_fire_count-1)/2.0) * Burst_direction
	Output += Vector2.from_angle(global_rotation).normalized() * get_node("GunSprite").get_rect().size.y * 2
	return Output
	
func get_turret_rotation() -> float:
	return (global_rotation + deg_to_rad(randfn(0.0,innacuracy_degrees/2.0) ))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	if is_weapon_active: #place this into the player node instead
		_rotate()
		
		
func _rotate() -> void:
	mouse_position = get_local_mouse_position()
	desired_rotation = mouse_position.angle() 
	#print( desired_rotation)
	if abs(desired_rotation) > accuracy_margin_radian:	
		if desired_rotation > 0:
			rotation += rotation_speed
		else:
			rotation -= rotation_speed
		if is_rotation_limited:
			rotation = clampf(rotation, left_rotation_limit, right_rotation_limit)
		else:
			if abs(rotation) > PI:
				rotation = -signf(rotation) * PI


func _on_cooldown_timer_timeout() -> void:
	can_fire_flag = true


func _on_burst_fire_cooldown_timer_timeout() -> void:
	if !loaded_ammunition.is_empty() and current_burst_count > 0:
		current_burst_count -= 1
		projectile_fired.emit(get_new_bullet_position(),get_turret_rotation(),available_ammunition_types[loaded_ammunition.pop_back()])
		get_node("BurstFireCooldownTimer").start()
	elif !loaded_ammunition.is_empty():
		can_fire_flag = false
		get_node("CooldownTimer").start()
