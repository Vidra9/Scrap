extends Node2D

enum projectile_type {SINGLE, QUAD}
@export var bullet_scene: PackedScene
var shoot_origin: Object

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func shoot():
	var bullet = bullet_scene.instantiate()
	bullet.global_position = shoot_origin.global_position
	bullet.global_rotation = shoot_origin.global_rotation
	bullet.call("set_is_friendly", true)
	bullet.linear_velocity = \
	Vector2(sin(shoot_origin.global_rotation), -cos(shoot_origin.global_rotation))\
	 * bullet.bullet_speed
	Global.bullets.append(bullet)
	Global.main_scene.add_child(bullet)

func set_shoot_origin(origin: Object):
	shoot_origin = origin
