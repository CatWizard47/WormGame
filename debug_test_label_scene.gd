extends Control
@export var label_node: Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.scale=Vector2(0.5,0.5)
	pass # Replace with function body.

func change_text(text:String)->void:
	label_node.text=text

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
