class_name PathfindingNodeHeapElement extends Resource

var pathfinding_node: PathfindingNode
var priority: int

func _init(new_pf_node:PathfindingNode,new_node_priority:int)->void:
	pathfinding_node=new_pf_node
	priority=new_node_priority
	
func _to_string() -> String:	#this is only 4 debuging
	return "prio= "+str(priority)
