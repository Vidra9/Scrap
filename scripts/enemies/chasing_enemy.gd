extends RigidBody2D

@export var bullet_scene: PackedScene
@export var debree_scenes: Array[PackedScene]
@export var movement_speed: int = 12000
@export var rotation_speed: int = 50
var chase = true
var explosionScene = preload("res://scenes/explosion.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if Global.player:
		var direction = (Global.player.position - position).normalized()
		global_rotation = lerp_angle(global_rotation, direction.angle() + PI/2, delta)
		if chase:
			linear_velocity = direction * movement_speed * delta

func explode():
	Global.enemy_destroyed.emit(self, global_position)
	var explosion = explosionScene.instantiate()
	explosion.global_position = global_position
	explosion.get_node("AnimatedSprite2D").autoplay = "red"
	Global.main_scene.call_deferred("add_child", explosion)
	
	var rng = RandomNumberGenerator.new()
	# Push debree somewhere?
	if randi_range(0,1) == 0 and Global.playing:
		var debree = debree_scenes[0].instantiate()
		debree.get_node("CollisionShape2D").shape = debree.get_node("CollisionShape2D").shape.duplicate()
		debree.position = position
		debree.call("set_is_gun_variation", false)
		var variant = "variant_%d" % rng.randi_range(1,2)
		debree.call("set_variant", variant)
		Global.main_scene.call_deferred("add_child", debree)
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body == Global.player:
		Global.player.call_deferred("take_damage")
		explode()
	#pass
	
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("ship_parts") and not Global.player.get_node("PickupArea"):
		if area.call("is_attached"):
			area.call_deferred("delete")
			explode()

func _on_search_area_area_entered(area: Area2D) -> void:
	chase = false
	$SleepingTimer.start()
	await $SleepingTimer.timeout
	chase = true
