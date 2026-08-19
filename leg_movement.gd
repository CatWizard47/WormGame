extends Sprite2D
var leg_reach: int 
var step_time: float
var foot_placement: Vector2


func setup(reach: int, time: float) -> void:
	leg_reach = reach
	step_time = time

func _move(position: Vector2) -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position = 
	pass
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#this will need to decide whether it's left or right facing
	pass # Replace with function body.
