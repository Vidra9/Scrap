extends RigidBody2D

@export var bullet_scene: PackedScene
@export var movement_speed = 4500
@export var debree_scene: PackedScene
var shouldFlee = false
var shooting = false
var rng = RandomNumberGenerator.new()
var strafe_dir
var movement_chosen = false

var explosionScene = preload("res://scenes/explosion.tscn")

func shoot_bullet():
	var bullet = bullet_scene.instantiate()
	bullet.position = position
	bullet.rotation = rotation
	bullet.call("set_is_friendly", false)
	bullet.linear_velocity = Vector2(sin(rotation), -cos(rotation)) * bullet.bullet_speed
	bullet.set_collision_mask_value(2, false)
	bullet.set_collision_mask_value(1, true)
	bullet.get_node("Area2D").set_collision_mask_value(2, false)
	bullet.get_node("Area2D").set_collision_mask_value(1, true)
	Global.bullets.append(bullet)
	Global.main_scene.add_child(bullet)

func explode():
	Global.enemy_destroyed.emit(self, global_position)
	var explosion = explosionScene.instantiate()
	explosion.global_position = global_position
	explosion.get_node("AnimatedSprite2D").autoplay = "yellow"
	Global.main_scene.call_deferred("add_child", explosion)
	# Push debree somewhere?
	if randi_range(0,1) == 0 and Global.playing:
		var debree = debree_scene.instantiate()
		debree.get_node("CollisionPolygon2D").polygon = debree.get_node("CollisionPolygon2D").polygon.duplicate()
		debree.position = position
		debree.call("set_is_gun_variation", rng.randi_range(0,1) == 0)
		var variant = "variant_%d" % rng.randi_range(1,2)
		debree.call("set_variant", variant)
		Global.main_scene.call_deferred("add_child", debree)
	queue_free()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	#if not shouldFlee and not shooting:
	if Global.player == null:
		return
		
	if Global.player.position:
		look_at(Global.player.position)
		rotation += PI/2
	if movement_chosen:
		return
		
	if shouldFlee:
		var direction = (Global.player.position - position).normalized()
		linear_velocity = direction * movement_speed * delta * -1
		movement_chosen = true
		await get_tree().create_timer(0.7).timeout
		movement_chosen = false
	elif not shooting and not shouldFlee:
		var direction = (Global.player.position - position).normalized()
		linear_velocity = direction * movement_speed * delta
		movement_chosen = true
		await get_tree().create_timer(0.7).timeout
		movement_chosen = false
	elif shooting and not shouldFlee:
		var direction = (Global.player.position - position).normalized()
		direction = direction.rotated(strafe_dir * (3 * PI /8))
		linear_velocity = direction * movement_speed * delta
		movement_chosen = true
		await get_tree().create_timer(0.7).timeout
		movement_chosen = false

func _on_shooting_timer_timeout() -> void:
	shoot_bullet()

func _on_flee_area_body_entered(body: Node2D) -> void:
	if body == Global.player:
		await get_tree().create_timer(0.5).timeout
		shouldFlee = true

func _on_shooting_range_body_entered(body: Node2D) -> void:
	if body == Global.player:
		await get_tree().create_timer(0.5).timeout
		$ShootingTimer.start()
		shooting = true
		strafe_dir = rng.randi_range(0,1)
		if strafe_dir == 0:
			strafe_dir = -1

func _on_shooting_range_body_exited(body: Node2D) -> void:
	if body == Global.player:
		$ShootingTimer.stop()
		shooting = false
		strafe_dir = 0

func _on_flee_area_body_exited(body: Node2D) -> void:
	shouldFlee = false

func _on_body_entered(body: Node) -> void:
	if body == Global.player:
		Global.player.call_deferred("take_damage")
		explode()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("ship_parts") and not Global.player.get_node("PickupArea"):
		if area.call("is_attached"):
			area.call_deferred("delete")
			explode()
