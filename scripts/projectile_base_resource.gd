class_name ProjectileRes extends Resource
	
@export var health_damage: int
@export var structure_damage: int
@export var armour_damage: int
@export var projectile_speed: float # 0 if hitscan
@export var type: String
@export var element: damage_type
@export var texture: Texture2D
@export var blast_radius: float


enum damage_type {
	BALLISTIC,
	HEAT,
	COLD,
	ELECTRIC
}
