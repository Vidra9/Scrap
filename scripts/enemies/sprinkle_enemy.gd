extends RigidBody2D

@export var bullet_scene: PackedScene
@export var movement_speed = 3500
@export var debree_scene: PackedScene
@export var rotation_speed = 1000

var rotation_dir = 1
var explosionScene = preload("res://scenes/explosion.tscn")

func shoot_bullet(direction):
	var bullet = bullet_scene.instantiate()
	bullet.position = position
	bullet.rotation = direction.angle() + PI/2
	bullet.call("set_is_friendly", false)
	bullet.linear_velocity = direction * bullet.bullet_speed
	bullet.set_collision_mask_value(2, false)
	bullet.set_collision_mask_value(1, true)
	bullet.get_node("Area2D").set_collision_mask_value(2, false)
	bullet.get_node("Area2D").set_collision_mask_value(1, true)
	Global.bullets.append(bullet)
	Global.main_scene.add_child(bullet)

func shoot_bullets():
	shoot_bullet(Vector2(sin(rotation), -cos(rotation))) #UP
	shoot_bullet(Vector2(cos(rotation), sin(rotation))) #RIGHT
	shoot_bullet(Vector2(-cos(rotation), -sin(rotation))) #LEFT
	shoot_bullet(Vector2(-sin(rotation), cos(rotation))) #DOWN

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$ShootingTimer.start()
	var rng = RandomNumberGenerator.new()
	if rng.randi_range(0,1) == 0:
		rotation_dir *= -1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if Global.player == null:
		return
		
	constant_torque = rotation_dir * rotation_speed
	var direction = (Global.player.position - position).normalized()
	linear_velocity = direction * movement_speed * delta
	await get_tree().create_timer(0.7).timeout

func explode():
	Global.enemy_destroyed.emit(self, global_position)
	var rng = RandomNumberGenerator.new()
	var explosion = explosionScene.instantiate()
	explosion.global_position = global_position
	explosion.get_node("AnimatedSprite2D").autoplay = "blue"
	Global.main_scene.call_deferred("add_child", explosion)
	# Push debree somewhere?
	if randi_range(0,1) == 0 and Global.playing:
		var debree = debree_scene.instantiate()
		debree.get_node("CollisionShape2D").shape = debree.get_node("CollisionShape2D").shape.duplicate()
		debree.position = position
		debree.call("set_is_gun_variation", rng.randi_range(0,1) == 0)
		var variant = "variant_%d" % rng.randi_range(1,2)
		debree.call("set_variant", variant)
		Global.main_scene.call_deferred("add_child", debree)
	queue_free()

func _on_shooting_timer_timeout() -> void:
	shoot_bullets()

func _on_body_entered(body: Node) -> void:
	if body == Global.player:
		Global.player.call_deferred("take_damage")
		explode()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("ship_parts") and not Global.player.get_node("PickupArea"):
		if area.call("is_attached"):
			area.call_deferred("delete")
			explode()
