class_name PathfindingSector extends Resource
var position: Vector2i	#the centre of a specific sector, might be used for aproximating length of any given route
var neighbours: Array 	 
var contained_nodes:Dictionary[Vector2i, PathfindingNode] 


#neighbors need to have 2 get methods, 
#1 for shortest route only providing all neighboring sectors, 
#2 needs to give every crossing PFnode to a given neighbor

#note 4 optimizing l8tr
#Lookup times 4 dicts are slower than arrays so
# it might be worth considering checking a given PFnode's neighbours instead, 
# some basic research says ifs are generally slower than lookups but that was on multiple if statements, not a single one like here

#size needs to be constant, but will probably put that in the actuall PFmanager instead,
#but that can cause another issue with possiblity of sectors having more than one group of PFnodes that aren't connected to one another
#so maybe only give a sector a maximum size instead,  manufacturing more sectors  that aren't attached to any sort of overarching grid
