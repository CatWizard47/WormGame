class_name PathfindingNode extends Resource
var position: Vector2i	#should be more performant	
var is_border:bool = false
#var type: node_type
var neighbours: Array	#contains other PathfindingNodes
var parent_sector_id: int = 0	#basically just a pointer to the parent sector see:  get_instance_from_id(instance_id: int)
								# 0 = orphaned, needs to be given a sector
var crossing_node_id: Dictionary[node_array_direction, int]  #only applies to crossing nodes obv, points to next sector 	

	#we don't really need an entire enum type, if we could already use crossing_node_id 

#enum node_type{		
	#INTERNAL = 1,  	#when surrounded by other nodes of this sector
	#BORDER = 2,		#when neighboring an node with a static body or one thats otherwise supposed to be inaccesible 
	#CROSSING = 3	#when borders another pathfinding sector
	#TRANSIT,	#when containing a straight pathway surrounded by inaccesible nodes
				#after some pondering decided that transit nodes are redundant
				#since enums are also ints, nodes are in a sequence that equals their weight, 
				#so units will avoid BORDER and CROSSING nodes whenever possible 
				#applied weights since it starts at 0 on default
#}
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
