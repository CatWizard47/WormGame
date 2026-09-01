class_name Status extends Resource
@export var max_health: int
@export var max_armour: int
@export var max_structure: int
var health: int
var armour: int
var structure: int
signal on_damage_recived	#these are tripped on projectiles and other dmg dealing sources
signal on_death				#obj that have these to connect here


func _init(maximum_health:int, maximum_armour: int, maximum_structure: int):
	max_health = maximum_health
	health = maximum_health
	max_armour = maximum_armour
	armour = maximum_armour
	max_structure = maximum_structure
	structure = maximum_structure
	on_damage_recived.connect(damage_check)

func deal_damage(health_damage: int, structure_damage: int, armour_damage: int):
	var dealt_damage: int
	#print(health,"=health ",structure, " = structure ", armour, " = armour" )
	#print(health_damage,"=health_dmg ",structure_damage, " = structure_dmg ", armour_damage, " = armour_dmg" )
	if armour > 0:
		dealt_damage = armour_damage
		armour -= dealt_damage
		armour = clamp(armour, 0, max_armour)
	if structure > 0: 
		dealt_damage = (structure_damage - armour)
		structure -= dealt_damage
		structure = clamp(structure, 0, max_structure)
	if health > 0:
		dealt_damage = (health_damage - armour) * ( 1 - (structure/max_structure))
		health -= dealt_damage
		health = clamp(health, 0, max_health)
	on_damage_recived.emit()

func damage_check()->void:
	if(health<=0):
		on_death.emit()
