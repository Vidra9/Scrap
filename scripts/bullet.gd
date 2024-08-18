extends RigidBody2D

@export var bullet_speed = 700
@export var friendlyTexture: CompressedTexture2D
@export var hostileTexture: CompressedTexture2D
var is_friendly: bool

func set_is_friendly(friendly):
	is_friendly = friendly
	if is_friendly:
		$Sprite2D.texture = friendlyTexture
	else:
		$Sprite2D.texture = hostileTexture

func _on_area_entered(area: Area2D) -> void:
	if is_friendly:
		pass
	else:
		if Global.player and area == Global.player.get_node("PickupArea"):
			Global.bullets.erase(self)
			queue_free()
			return
		if Global.player and area.is_in_group("ship_parts"):
			area.call_deferred("delete")
			Global.bullets.erase(self)
			queue_free()
	

func _on_area_2d_body_entered(body: Node2D) -> void:
	if is_friendly:
		if body.is_in_group("enemy"):
			body.call_deferred("explode")
			Global.bullets.erase(self)
			queue_free()
	else:
		if body == Global.player:
			Global.player.call_deferred("take_damage")
			Global.bullets.erase(self)
			queue_free()
