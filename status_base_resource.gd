class_name Status extends Resource
@export var max_health: int
@export var max_armour: int
@export var max_structure: int
@export var max_shield: int
var health: int
var armour: int
var structure: int
var shield: int

func _init(maximum_health:int, maximum_armour: int, maximum_structure: int, maximum_shield: int):
	max_health = maximum_health
	health = maximum_health
	max_armour = maximum_armour
	armour = maximum_armour
	max_structure = maximum_structure
	structure = maximum_structure
	max_shield = maximum_shield
	shield = 0 
