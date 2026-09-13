class_name PathfindingNode extends Resource
var position: Vector2i	#should be more performant	
var is_border:bool = false
var neighbours: Dictionary[node_array_direction,PathfindingNode]	#contains other PathfindingNodes, originally Array, buuut, could be effed when 
												#no neighbour between two others
var parent_sector_id: int = 0	#basically just a pointer to the parent sector see:  get_instance_from_id(instance_id: int)
								# 0 = orphaned, needs to be given a sector
var crossing_node_id: Dictionary[node_array_direction, int]  #only applies to crossing nodes obv, points to next sector 	

var is_finished: bool = false	#changed to true after border, 
								#parent_sector_id and
								#crossing_node_id 
								#are filled out

enum node_array_direction{	#to avoid using a dict
	NORTH,
	SOUTH,
	WEST,
	EAST
}

func _init(new_position:Vector2i,new_is_border:bool)->void:
	is_border=new_is_border
	position = new_position	
	crossing_node_id = {}
	
	#crossing_node_id:
	# = -1 if not a crossing
	# = 0 if pending to be found
	# = any different num > 0, probably valid
	
	#dunno if we will have neighbours at the moment of creation
	#actually generating the nav nodes will probably not need to be optimized as thoroughly, since it will only be done occasionally

	#note 4 later implementation
	#main idea is to separate a map into sectors, and then make units pathfind within said sectors,
	#then we can offload the entire pathfinding calc to multiple frames instead of one
	#also the built in a* implement is designed for predefined static postitions so no go
	#
	#also we make units find their own path by doing a shortest-route algorithm on sectors 
	#which necessitates either a constant sized sectors or placing 
	#
	#the most pressing issue is finding a specific memory data obj to contain individual sectors
	#since arrays are more performant than dictionaries (even using Vector2i's) this might neccesitate some sort of heap or tree
	#or we keep the things in this main dictionary while also maintaining their references within each node, leapfroging the lookup it's time 
