extends RigidBody2D

@export var max_rotation_speed = 7000
var rotation_speed = 7000
var min_rotation_speed
@export var maxThrustForce = 200
var thrustForce
var min_thrust_force
@export var mu_moving = 0.5
@export var mu_static = 0.8  # friction coefficients

@export var bullet_scene: PackedScene
@export var health: int = 3
@export var pill_rotation_speed = 400

var thrusting = 0
var rotation_dir = 0

var applied_forces = Vector2.ZERO
var can_shoot = true

var attached_guns: Array
var explosionScene = preload("res://scenes/explosion.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	attached_guns = []
	Global.attach_gun.connect(attach_gun)
	Global.debree_list.append(self)
	min_rotation_speed = rotation_speed * 0.1
	thrustForce = maxThrustForce
	min_thrust_force = maxThrustForce * 0.1
	Global.update_num_of_attached_debree.connect(update_rotation_speed)

func _process(delta: float) -> void:
	$Pill.global_position = global_position
	if Input.is_action_just_pressed("shoot") and can_shoot:
		can_shoot = false
		shoot()
		$ShootCooldown.start()
		await $ShootCooldown.timeout
		can_shoot = true
	
	# TODO: fix back rotations
	if thrusting:
		$Pill.global_rotation_degrees += pill_rotation_speed * delta

func _physics_process(_delta: float) -> void:
	var rotating = false
	var thrust = Vector2.ZERO
	var thrust_dir = Vector2(sin(rotation), -cos(rotation))
	thrusting = 0
	if Input.is_action_pressed("thrust"):
		thrusting = 1
		thrust_dir = Vector2(0, -1)
	if Input.is_action_pressed("reverse"):
		thrusting = 1
		thrust_dir = Vector2(0, 1)
	if Input.is_action_pressed("left"):
		if thrusting:
			thrust_dir += Vector2(-1, 0)
		else:
			thrust_dir = Vector2(-1, 0)
			thrusting = 1
	if Input.is_action_pressed("right"):
		if thrusting:
			thrust_dir += Vector2(1, 0)
		else:
			thrust_dir = Vector2(1, 0)
			thrusting = 1
		
	if thrusting != 0:
		thrust = thrust_dir * thrustForce * thrusting
		
	constant_force = thrust
	#if rotating:
		#constant_torque = rotation_dir * rotation_speed
	#else:
		#constant_torque = 0
	look_at(get_global_mouse_position())
	rotate(PI/2)
	

func _on_thruster_thrusting(thrust_direcion: Variant) -> void:
	thrusting = thrust_direcion # Replace with function body.

func _on_pickup_area_area_entered(area: Area2D) -> void:
	pass
		
func add_extra_constant_force(force):
	constant_force += force

func take_damage():
	if health == 0:
		return
	health -= 1
	if health == 0:
		Global.play_explosion.emit(global_position)

		var explosion = explosionScene.instantiate()
		explosion.global_position = global_position
		explosion.get_node("AnimatedSprite2D").autoplay = "default"
		Global.main_scene.call_deferred("add_child", explosion)
		
		Global.game_over.emit()
		Global.health_changed.emit()
		Global.player = null
		queue_free()
	else:
		Global.health_changed.emit()
		$AnimationPlayer.play("hp_%d" % health)

func update_rotation_speed():
	rotation_speed = max_rotation_speed\
	 - (Global.debree_list.size() * Global.rotation_speed_change)
	thrustForce = maxThrustForce - (Global.debree_list.size() * Global.thrust_penalty)

func shoot():
	var bullet = bullet_scene.instantiate()
	bullet.position = position
	bullet.rotation = rotation
	bullet.call("set_is_friendly", true)
	bullet.linear_velocity = Vector2(sin(rotation), -cos(rotation)) * bullet.bullet_speed
	Global.bullets.append(bullet)
	Global.main_scene.add_child(bullet)
	for gun in attached_guns:
		gun.call_deferred("shoot")

func attach_gun(gun: Object):
	if attached_guns.find(gun) == -1:
		attached_guns.append(gun)
	
func remove_gun(gun: Object):
	attached_guns.erase(gun)
