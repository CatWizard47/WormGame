class_name PathfindingSector extends Resource
var position: Vector2i
var neighbours: Array 	 
var contained_nodes:Dictionary[Vector2i, PathfindingNode] #will contain every node within keys are to be Vector2i


#neighbors need to have 2 get methods, 
#1 for shortest route only providing all neighboring sectors, 
#2 needs to give every crossing PFnode to a given neighbor

#note 4 optimizing l8tr
#Lookup times 4 dicts are slower than arrays so
# it might be worth considering checking a given PFnode's neighbours instead, 
# some basic research says ifs are generally slower than lookups but that was on multiple if statements, not a single one like here
