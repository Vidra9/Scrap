extends RigidBody2D

@export var rotation_speed = 7000
@export var thrustForce = 200
@export var mu_moving = 0.5
@export var mu_static = 0.8  # friction coefficients

@export var bullet_scene: PackedScene
@export var health: int = 3

var thrusting = 0
var rotation_dir = 0

var applied_forces = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.debree_list.append(self)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("shoot"):
		var bullet = bullet_scene.instantiate()
		bullet.position = position
		bullet.rotation = rotation
		bullet.linear_velocity = Vector2(sin(rotation), -cos(rotation)) * bullet.bullet_speed
		Global.bullets.append(bullet)
		Global.main_scene.add_child(bullet)

func _physics_process(_delta: float) -> void:
	var rotating = false
	var thrust = Vector2.ZERO
	if Input.is_action_pressed("left"):
		#rotate(deg_to_rad(-rotation_speed * delta)) # Rotation is clockwise by deafult (rad bullshit)
		rotation_dir = -1
		rotating = true
	if Input.is_action_pressed("right"):
		#rotate(deg_to_rad(rotation_speed * delta))
		rotation_dir = 1
		rotating = true
		
	if thrusting != 0:
		thrust = Vector2(sin(rotation), -cos(rotation)) * thrustForce * thrusting
		
	#var rotation_dir = Vector2(sin(rotation), -cos(rotation))
	constant_force = thrust
	if rotating:
		constant_torque = rotation_dir * rotation_speed
	else:
		constant_torque = 0

func _on_thruster_thrusting(thrust_direcion: Variant) -> void:
	thrusting = thrust_direcion # Replace with function body.


func _on_pickup_area_area_entered(area: Area2D) -> void:
	pass
		
func add_extra_constant_force(force):
	constant_force += force

func take_damage():
	health -= 1
	Global.health_changed.emit()
	if health == 0:
		Global.player = null
		queue_free()
