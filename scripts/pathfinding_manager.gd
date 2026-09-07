extends Node2D	#needs to be a 2D node, due to world2D usage
# Called when the node enters the scene tree for the first time.
#@export var node_border_lenght: int
@export var node_size: int #dist from the center so a node with size 10 is 20x20 square 
@export var maximum_sector_size: int #in nodes width from the center so 2* this for absolute width | height
var shape_rid: RID
var available_pathfinding_sectors: Array



func _ready() -> void:
	pass # Replace with function body.


	#needs to append to the A_P_S array:
	#deleting  might be an issue tho
func generate_navmesh(starting_position:Vector2)->void:
	pass

func generate_pathfinding_sector(starting_position:Vector2i)->void: #->PathfindingSector
	pass

func generate_pathfinding_node(starting_position:Vector2i)->void: #->PathfindingNode
	pass


												#if z-levels are to be implemented, i have to dynamically change col_layer of obj

	#https://docs.godotengine.org/en/stable/tutorials/physics/ray-casting.html
	#https://en.wikipedia.org/wiki/A*_search_algorithm # maybe?
	#possibly make this a new thread # will check perf before doing that
	#https://docs.godotengine.org/en/stable/tutorials/performance/using_multiple_threads.html
	#TODO 
	#Try to figure out the best method of finding nodes, 
	# like 5 pronged incomplete hexagram or sumthin
	#return Output


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
