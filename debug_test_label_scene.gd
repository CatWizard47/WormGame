extends Control
@export var label_node: Label
@export var texture_node: Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label_node.scale=Vector2(0.5,0.5)
	texture_node.scale = Vector2(0.3,0.3)
	pass # Replace with function body.

func change_text(text:String)->void:
	label_node.text=text

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
