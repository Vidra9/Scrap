extends Area2D

var is_attached_to_player = false
var node_leading_to_ship : Node2D
var other_connection : Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	node_leading_to_ship = null
	other_connection = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func extra(node):
	other_connection = node

func delete():
	if other_connection != null:
		other_connection.call("delete")
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("ship_parts"):
		if Global.debree_list.find(self) == -1:
			reparent(Global.player)
			Global.debree_list.append(self)
			node_leading_to_ship = area 
			if area != Global.player.get_node("PickupArea"):
				area.call("extra", self)


func _on_mouse_entered() -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		delete()
