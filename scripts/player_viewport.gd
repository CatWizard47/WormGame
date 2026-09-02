extends Node
var PlayerUnit: RigidBody2D
var position_value: Label
var rotation_value: Label
var loco_node_rotation_value: Label
var mouse_pos_value: Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if get_parent()!=null:
		PlayerUnit = get_parent()
		position_value = get_node("HBoxContainer/VerticalStatValueContainer/PositionValue")
		rotation_value = get_node("HBoxContainer/VerticalStatValueContainer/RotationValue")
		loco_node_rotation_value = get_node("HBoxContainer/VerticalStatValueContainer/LocoNodeRotationValue")
		mouse_pos_value = get_node("HBoxContainer/VerticalStatValueContainer/MousePosValue")
	else:
		print("ERR")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position_value.text = str(PlayerUnit.position)
	rotation_value.text = str(PlayerUnit.rotation)
	loco_node_rotation_value.text = str(PlayerUnit.locomotive_rotation)
	mouse_pos_value.text = str(get_global_mouse_position())
