extends Node

var debree_list: Array
var player
var main_scene
var bullets: Array
var rotation_speed_change = 500
var thrust_penalty = 10
var score = 0
var playing = false

signal debree_pickup_attempt
signal health_changed
signal update_num_of_attached_debree
signal start_game
signal game_over
signal enemy_destroyed(enemy: Object, pos: Vector2)
signal attach_gun(gun: Object)
signal play_explosion(pos: Vector2)
