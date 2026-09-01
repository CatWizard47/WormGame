extends Node2D	#needs to be a 2D node, due to world2D usage


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func Find_path(PositionA:Vector2, PositionB:Vector2)->Array:
	var Output:Array = Array()	#Returns an array of positions, 
	#https://docs.godotengine.org/en/stable/tutorials/physics/ray-casting.html
	#https://en.wikipedia.org/wiki/A*_search_algorithm # maybe?
	#possibly make this a new thread # will check perf before doing that
	#https://docs.godotengine.org/en/stable/tutorials/performance/using_multiple_threads.html
	#TODO 
	#Try to figure out the best method of finding nodes, 
	# like 5 pronged incomplete hexagram or sumthin
	return Output


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
