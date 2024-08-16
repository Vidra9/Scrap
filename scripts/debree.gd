extends Area2D

var is_attached_to_player = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func extra():
	print("ass")


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("ship_parts"):
		reparent(Global.player)
		Global.debree_list.append(self)
		extra()
