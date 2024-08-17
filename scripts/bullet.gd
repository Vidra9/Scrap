extends RigidBody2D

@export var bullet_speed = 700

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("ship_parts"):
		area.call_deferred("delete")
		Global.bullets.erase(self)
		queue_free()
	if area.is_in_group("enemy"):
		area.call_deferred("explode")
		Global.bullets.erase(self)
		queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == Global.player:
		Global.player.call_deferred("take_damage")
