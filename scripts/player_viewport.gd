extends Control
var PlayerUnit: RigidBody2D
@export var position_value: Label
@export var rotation_value: Label
@export var loco_node_rotation_value: Label
@export var mouse_pos_value: Label
@export var current_salvo_value: Label
@export var next_salvo_value: Label
#these contain at [0] the central Hbox container, and then Vbox containers for Labels and thend Values
var weapon_group_display_container_0: HBoxContainer = HBoxContainer.new()
var weapon_group_display_container_1: HBoxContainer = HBoxContainer.new()
var weapon_group_display_container_2: HBoxContainer = HBoxContainer.new()
var weapon_group_display_container_3: HBoxContainer = HBoxContainer.new()
#all of these contain arrays for displayed objects, size of each is equal to weapon group size
#the contained arrays: have a vbox at [0], and gun label at [1], what follows is salvo_size * 2 of labels each containing a projectile about to be fired
#pwobably will have to connect a fire signal from turrets to here, 2 sync our salvos with ui 
var weapon_group_display_array_0: Array = Array()
var weapon_group_display_array_1: Array = Array()
var weapon_group_display_array_2: Array = Array()
var weapon_group_display_array_3: Array = Array()

var viewport_move_distance: float
var maximum_camera_offset: float
var viewport_movement_multiplier: int = 400	#

	#As a remainder, every player signal that deals with UI will be connected with functions here,
	#they have to be connected from player script tho, due to ui being a child of the player node
	#this is generally only to follow general style conventions 
func _ready() -> void:
	if get_parent()!=null:
		PlayerUnit = get_parent()
	else:
		print("ERR")
	viewport_move_distance = (get_viewport_rect().size).length() * 0.10
	maximum_camera_offset = (get_viewport_rect().size).length() * 0.25

func update_ammunition_counters(combined_magazine_state:Array,projectile:Variant)->void:
	#if projectile is Variant, remove projectile, else add provided to top
	#will have to add projectiles to [1] or otherwise the lowest empty that isn't last, of the given vbox array, ofc 
	pass
	

func update_viewport_position()->void:
	#the camera is to move with mouse movements, may have to do this with a toggle 
	var local_mouse_position:Vector2 = get_local_mouse_position()
	if local_mouse_position.length() <= maximum_camera_offset:
		position = local_mouse_position.normalized() * (local_mouse_position.length() / maximum_camera_offset) * viewport_movement_multiplier
		position = position.rotated(-PlayerUnit.global_rotation)
		if position.length() >= maximum_camera_offset:
			position -= position * 0.05


func _adjust_ui_rotation()->void:
	rotation = -PlayerUnit.global_rotation

	#will make individual label and containers 4 each weapon & weapongroup
	#will have to be called on player entering the game scene
	#ofc assumes weapons won't be changed during combat
	#will have to hide all made items
func _prepare_weapon_display(weapon_group_size_array:Array)->void:
	var screen_size: Rect2 = get_viewport_rect()
	for i:int in range(4):
		self.get("weapon_group_display_container_"+str(i)).position = screen_size.size * 0.7	#currently 70%
		self.get("weapon_group_display_container_"+str(i)).size = screen_size.size * 0.3
		add_child(self.get("weapon_group_display_container_"+str(i))) 
		for j:int in range(weapon_group_size_array[i]):
			
			print(j)
			pass
	
	#displays a given container, *hides* other ones
func _change_displayed_weapon_group(weapon_group_to_display:int)->void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:		#TEMP, 
	_adjust_ui_rotation()
	update_viewport_position()
	#print(get_local_mouse_position().length())
	#print(viewport_move_distance," ",viewport_move_distance*5)
	position_value.text = str(PlayerUnit.position)
	rotation_value.text = str(PlayerUnit.rotation)
	loco_node_rotation_value.text = str(PlayerUnit.locomotive_rotation)
	mouse_pos_value.text = str(get_local_mouse_position())
	
	
