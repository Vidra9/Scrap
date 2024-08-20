extends Area2D

var is_attached_to_player = false
var nodes_leading_to_ship : Array
var other_nodes : Array
var other_to_remove: Array
@export var is_gun_variation: bool = false
var gun_scene = preload("res://scenes/gun_attachment.tscn")
var gun_attachement
var explosionScene = preload("res://scenes/explosion.tscn")

func set_variant(variant: String):
	$AnimationPlayer.play(variant)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	nodes_leading_to_ship = []
	other_nodes = []
	Global.game_over.connect(delete)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func add_other_node(node):
	if other_nodes.find(node) == -1:
		other_nodes.append(node)

func remove_ship_node(node) -> bool:
	nodes_leading_to_ship.erase(node)
	return nodes_leading_to_ship.size() == 0 #mark debree for deletion

func delete_other_node(node):
	other_nodes.erase(node)

func delete_self_and_other():
	for node in other_nodes:
		Global.debree_list.erase(self)
		node.queue_free()
	queue_free()
	Global.update_num_of_attached_debree.emit()

func delete():
	other_to_remove = []
	if other_nodes.size() > 0:
		for node in other_nodes:
			if node.call("remove_ship_node", self):
				node.delete()
				other_to_remove.append(node)
				
	
	for node in other_to_remove:
		node.call_deferred("delete_self_and_other")
	
	for node in nodes_leading_to_ship:
		if node != Global.player.get_node("PickupArea"):
			node.call("delete_other_node", self)
	
	Global.debree_list.erase(self)
	if gun_attachement != null:
		Global.player.call_deferred("remove_gun", gun_attachement)
	
	Global.play_explosion.emit(global_position)
	var explosion = explosionScene.instantiate()
	explosion.global_position = global_position
	explosion.get_node("AnimatedSprite2D").autoplay = "default"
	Global.main_scene.call_deferred("add_child", explosion)
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	if (Global.player and area == Global.player.get_node("PickupArea")) ||\
		(area.is_in_group("ship_parts") and area.call("is_attached")):
		if Global.debree_list.find(self) == -1:
			call_deferred("reparent", Global.player)
			set_collision_mask_value(1, true)
			set_collision_layer_value(1, true)
			Global.debree_list.append(self)
			Global.update_num_of_attached_debree.emit()
			if nodes_leading_to_ship.find(area) == -1:
				nodes_leading_to_ship.append(area) 
			if area != Global.player.get_node("PickupArea"):
				area.call("add_other_node", self)
			if is_gun_variation:
				Global.attach_gun.emit(gun_attachement)

func _on_mouse_entered() -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		delete()
		
func set_is_gun_variation(gun_variation):
	is_gun_variation = gun_variation
	if is_gun_variation:
		gun_attachement = gun_scene.instantiate()
		gun_attachement.call("set_shoot_origin", self)
		#gun_attachement.position = position
		#gun_attachement.rotation = rotation
		add_child(gun_attachement)

func is_attached():
	return nodes_leading_to_ship.size() > 0
