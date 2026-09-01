class_name Status extends Resource
@export var max_health: int
@export var max_armour: int
@export var max_structure: int
@export var max_shield: int
var health: int
var armour: int
var structure: int
var shield: int
signal on_damage_recived	#these are tripped on projectiles and other dmg dealing sources
signal on_death				#obj that have these to connect here


func _init(maximum_health:int, maximum_armour: int, maximum_structure: int, maximum_shield: int):
	max_health = maximum_health
	health = maximum_health
	max_armour = maximum_armour
	armour = maximum_armour
	max_structure = maximum_structure
	structure = maximum_structure
	max_shield = maximum_shield
	shield = 0 
	on_damage_recived.connect(damage_check)

func deal_damage(health_damage: int, structure_damage: int, armour_damage: int):
	on_damage_recived.emit()
	pass

func damage_check()->void:
	if(health<=0):
		on_death.emit()
