extends RigidBody2D

@export var rotation_speed = 10000
@export var thrustForce = 200
@export var mu_moving = 0.5
@export var mu_static = 0.8  # friction coefficients
var thrusting = false
var rotation_dir = 0

var applied_forces = Vector2.ZERO

var debree_scene = preload("res://scenes/debree.tscn")

func add_force_for_frame(force: Vector2):
	# add_force adds a permanent force, for a temporary one we need to wipe it
	# by undo the force next frame, just keep track of forces applied
	applied_forces += force
	self.apply_central_force(force)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.debree_list.append(self)

func _physics_process(delta: float) -> void:
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
		
	if thrusting:
		thrust = Vector2(sin(rotation), -cos(rotation)) * thrustForce
		
	#var rotation_dir = Vector2(sin(rotation), -cos(rotation))
	constant_force = thrust
	if rotating:
		constant_torque = rotation_dir * rotation_speed
	else:
		constant_torque = 0

func _on_thruster_thrusting(is_thrusting: Variant) -> void:
	thrusting = is_thrusting # Replace with function body.


func _on_pickup_area_area_entered(area: Area2D) -> void:
	#Global.debree_pickup_attempt.emit()
	pass
	#area.reparent(self)
	#Global.debree_list.append(area)
	#area.call("extra")
	#if Global.debree_list.find(area) == -1:
		
