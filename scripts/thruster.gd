extends Node2D

signal thrusting(thrust_direcion)
var is_thrusting = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if Input.is_action_just_released("thrust") || \
	Input.is_action_just_released("reverse") || \
	Input.is_action_just_released("left") || \
	Input.is_action_just_released("right"):
		is_thrusting = false
		thrusting.emit(0)
