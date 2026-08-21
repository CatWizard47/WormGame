extends RigidBody2D
@export var parent_velocity: Vector2 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	parent_velocity = get_parent().velocity
	if parent_velocity.length() > 0:
		global_rotation = parent_velocity.normalized().angle()	
