extends Area2D

@export var bullet_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$ShootingTimer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func explode():
	queue_free()

func _on_shooting_timer_timeout() -> void:
	var bullet = bullet_scene.instantiate()
	bullet.position = position
	bullet.rotation = rotation
	bullet.linear_velocity = Vector2(sin(rotation), -cos(rotation)) * bullet.bullet_speed
	bullet.set_collision_mask_value(2, false)
	bullet.set_collision_mask_value(1, true)
	bullet.set_collision_mask_value(3, true)
	bullet.get_node("Area2D").set_collision_mask_value(2, false)
	bullet.get_node("Area2D").set_collision_mask_value(1, true)
	bullet.get_node("Area2D").set_collision_mask_value(3, true)
	Global.bullets.append(bullet)
	Global.main_scene.add_child(bullet)


func _on_body_entered(body: Node2D) -> void:
	if body == Global.player:
		Global.player.call_deferred("take_damage")
		queue_free()
	
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("ship_parts"):
		area.call_deferred("delete")
		queue_free()
