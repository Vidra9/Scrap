extends Node2D

@export var player_scene : PackedScene
@export var return_force_strength: float = 250
var player_out_of_map = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.main_scene = self
	Global.player = player_scene.instantiate()
	Global.player.position = $SpawnPosition.position
	Global.player.scale = Vector2(0.2, 0.2)
	add_child(Global.player)
	Global.health_changed.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if player_out_of_map:
		var return_vector = Vector2.from_angle(\
			Global.player.global_position.direction_to($SpawnPosition.global_position).angle())\
		 	* return_force_strength
		Global.player.call_deferred("add_extra_constant_force", return_vector)
		$hud.call("update_debug_cf", Global.player.constant_force)


func _on_playable_area_area_exited(area: Area2D) -> void:
	pass

func _on_playable_area_body_exited(body: Node2D) -> void:
	if body == Global.player:
		player_out_of_map = true
	if Global.bullets.find(body) != -1:
		await get_tree().create_timer(3.0).timeout
		Global.bullets.erase(body)
		body.queue_free()

func _on_playable_area_body_entered(body: Node2D) -> void:
	if body == Global.player:
		Global.player.call_deferred("add_extra_constant_force", Vector2.ZERO)
		player_out_of_map = false
