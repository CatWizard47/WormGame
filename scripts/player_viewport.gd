extends Control
var PlayerUnit: RigidBody2D
@export var position_value: Label
@export var rotation_value: Label
@export var loco_node_rotation_value: Label
@export var mouse_pos_value: Label
@export var current_salvo_value: Label
@export var next_salvo_value: Label
#these contain at [0] the central Hbox container, and then Vbox containers for Labels and thend Values
var weapon_group_display_containers_0: Array = Array()
var weapon_group_display_containers_1: Array = Array()
var weapon_group_display_containers_2: Array = Array()
var weapon_group_display_containers_3: Array = Array()
#all of these bellow are Label Node Arrays
var weapon_group_display_values_0: Array = Array()
var weapon_group_display_labels_0: Array = Array()
var weapon_group_display_values_1: Array = Array()
var weapon_group_display_labels_1: Array = Array()
var weapon_group_display_values_2: Array = Array()
var weapon_group_display_labels_2: Array = Array()
var weapon_group_display_values_3: Array = Array()
var weapon_group_display_labels_3: Array = Array()
	#As a remainder, every player signal that deals with UI will be connected with functions here,
	#they have to be connected from player script tho, due to ui being a child of the player node
	#this is generally only to follow general style conventions 
func _ready() -> void:
	if get_parent()!=null:
		PlayerUnit = get_parent()
	else:
		print("ERR")


func update_ammunition_counters(Combined_magazine_state:Array)->void:
	#will prolly need to figure out a procedural method of making and breaking H & Vbox cells 4 this 
	pass
	

func update_viewport_position()->void:
	#the camera is to move with mouse movements, may have to do this with a toggle 
	pass


func _adjust_ui_rotation()->void:
	rotation = -PlayerUnit.global_rotation


	#will make individual label and containers 4 each weapon & weapongroup
	#will have to be called on player entering the game scene
	#ofc assumes weapons won't be changed during combat
	#will have to hide all made items
func _prepare_weapon_display(weapon_group_size_array:Array)->void:
	var screen_size: Rect2 = get_viewport_rect()
	for i:int in range(4):
		self.get("weapon_group_display_containers_"+str(i)).append(HBoxContainer.new())
		self.get("weapon_group_display_containers_"+str(i))[0].position = screen_size.size * 0.7	#currently 70%
		self.get("weapon_group_display_containers_"+str(i))[0].size = screen_size.size * 0.3
		self.get("weapon_group_display_containers_"+str(i)).append(VBoxContainer.new())
		self.get("weapon_group_display_containers_"+str(i)).append(VBoxContainer.new())
		add_child(self.get("weapon_group_display_containers_"+str(i))[0]) #this should also instantiate all children of this thing
		self.get("weapon_group_display_containers_"+str(i))[0].add_child(self.get("weapon_group_display_containers_"+str(i))[1])
		self.get("weapon_group_display_containers_"+str(i))[0].add_child(self.get("weapon_group_display_containers_"+str(i))[2])
		for j:int in range(weapon_group_size_array[i]):
			
			print(j)
			pass
	
	#displays a given container, *hides* other ones
func _change_displayed_weapon_group(weapon_group_to_display:int)->void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:		#TEMP, 
	_adjust_ui_rotation()
	position_value.text = str(PlayerUnit.position)
	rotation_value.text = str(PlayerUnit.rotation)
	loco_node_rotation_value.text = str(PlayerUnit.locomotive_rotation)
	mouse_pos_value.text = str(get_global_mouse_position())
	
	
