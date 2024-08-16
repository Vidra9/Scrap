extends RigidBody2D

@export var rotation_speed = 100
@export var thrustForce = 200
@export var mu_moving = 40
var thrusting = false

var applied_forces = Vector2.ZERO

func add_force_for_frame(force: Vector2):
	# add_force adds a permanent force, for a temporary one we need to wipe it
	# by undo the force next frame, just keep track of forces applied
	applied_forces += force
	self.apply_central_force(force)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#Input handling
	if Input.is_action_pressed("left"):
		rotate(deg_to_rad(-rotation_speed * delta)) # Rotation is clockwise by deafult (rad bullshit)
	if Input.is_action_pressed("right"):
		rotate(deg_to_rad(rotation_speed * delta))
		
	if thrusting:
		var thrust_force = Vector2(sin(rotation), -cos(rotation)) * thrustForce
		#$RigidBody2D.apply_central_force(thrust_force)
		add_force_for_frame(thrust_force)

	if self.linear_velocity.length() > 0:
		self.add_force_for_frame(- self.mass * mu_moving * self.linear_velocity.normalized())

func _on_thruster_thrusting(is_thrusting: Variant) -> void:
	thrusting = is_thrusting # Replace with function body.
