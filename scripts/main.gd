extends Node2D

@export var player_scene : PackedScene
var ship

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.player = player_scene.instantiate()
	Global.player.position = $SpawnPosition.position
	add_child(Global.player)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	pass
