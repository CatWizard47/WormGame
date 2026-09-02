extends Control
var PlayerUnit: RigidBody2D
@export var position_value: Label
@export var rotation_value: Label
@export var loco_node_rotation_value: Label
@export var mouse_pos_value: Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if get_parent()!=null:
		PlayerUnit = get_parent()
	else:
		print("ERR")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:		#TEMP, 
	rotation = -PlayerUnit.global_rotation
	position_value.text = str(PlayerUnit.position)
	rotation_value.text = str(PlayerUnit.rotation)
	loco_node_rotation_value.text = str(PlayerUnit.locomotive_rotation)
	mouse_pos_value.text = str(get_global_mouse_position())
