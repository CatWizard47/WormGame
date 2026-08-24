class_name ProjectileRes extends Resource
	
@export var health_damage: int
@export var structure_damage: int
@export var armour_damage: int
@export var projectile_speed: float
@export var texture: Texture2D
@export var type: weapon_type

enum weapon_type {
	BALLISTIC,
	EXPLOSIVE,
	ENERGY
}
