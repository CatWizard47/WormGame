extends Control
var PlayerUnit: RigidBody2D
@export var position_value: Label
@export var rotation_value: Label
@export var loco_node_rotation_value: Label
@export var mouse_pos_value: Label
@export var current_salvo_value: Label
@export var next_salvo_value: Label

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
		
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:		#TEMP, 
	_adjust_ui_rotation()
	position_value.text = str(PlayerUnit.position)
	rotation_value.text = str(PlayerUnit.rotation)
	loco_node_rotation_value.text = str(PlayerUnit.locomotive_rotation)
	mouse_pos_value.text = str(get_global_mouse_position())
