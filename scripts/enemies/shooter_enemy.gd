extends RigidBody2D

@export var bullet_scene: PackedScene
@export var movement_speed = 3000
var shouldFlee = false
var shooting = false

func shoot_bullet():
	var bullet = bullet_scene.instantiate()
	bullet.position = position
	bullet.rotation = rotation
	bullet.linear_velocity = Vector2(sin(rotation), -cos(rotation)) * bullet.bullet_speed
	bullet.set_collision_mask_value(2, false)
	bullet.set_collision_mask_value(1, true)
	bullet.get_node("Area2D").set_collision_mask_value(2, false)
	bullet.get_node("Area2D").set_collision_mask_value(1, true)
	bullet.call("set_is_friendly", false)
	Global.bullets.append(bullet)
	Global.main_scene.add_child(bullet)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	#if not shouldFlee and not shooting:
	if Global.player and Global.player.position:
		look_at(Global.player.position)
		rotation += PI/2
	if Global.player and not shooting and not shouldFlee:
		var direction = (Global.player.position - position).normalized()
		global_rotation = lerp_angle(global_rotation, direction.angle() + PI/2, delta)
		linear_velocity = direction * movement_speed * delta

func _on_shooting_timer_timeout() -> void:
	shoot_bullet()

func _on_flee_area_body_entered(body: Node2D) -> void:
	if body == Global.player:
		shouldFlee = true
		linear_velocity = Vector2.ZERO

func _on_shooting_range_body_entered(body: Node2D) -> void:
	if body == Global.player:
		$ShootingTimer.start()
		shooting = true
		linear_velocity = Vector2.ZERO

func _on_shooting_range_body_exited(body: Node2D) -> void:
	if body == Global.player:
		$ShootingTimer.stop()
		shooting = false
		linear_velocity = Vector2.ZERO
		

func _on_flee_area_body_exited(body: Node2D) -> void:
	shouldFlee = false
	linear_velocity = Vector2.ZERO
	
