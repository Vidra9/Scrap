extends Node2D

signal thrusting(is_thrusting)
var is_thrusting = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("thrust") and !is_thrusting:
		is_thrusting = true
		thrusting.emit(is_thrusting)
	if Input.is_action_just_released("thrust"):
		is_thrusting = false
		thrusting.emit(is_thrusting)
