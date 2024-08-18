extends Node2D

@export var player_scene : PackedScene
@export var chasing_enemy_scene : PackedScene
var chaser_wait_time = 3
@export var shooter_enemy_scene : PackedScene
var shooter_wait_time = 5
@export var sprinkle_enemy_scene : PackedScene
var sprinkle_wait_time = 7
@export var return_force_strength: float = 250
var player_out_of_map = false
var enemies: Array

func get_random_enemy_spawn_point() -> Vector2:
	$SpawnPath/EnemySpawnLocation.progress_ratio = randf()
	return $SpawnPath/EnemySpawnLocation.global_position

func start_game():
	Global.playing = true
	$MainMenu.visible = false
	Global.score = 0
	$hud.update_score()
	$hud.visible = true
	$GameOver.visible = false
	$ChaserSpawnTimer.start(chaser_wait_time)
	$ShooterSpawnTimer.start(shooter_wait_time)
	$SprinkleSpawnTimer.start(sprinkle_wait_time)
	
	$DifficultyTimer.start()
	
	Global.player = player_scene.instantiate()
	Global.player.position = $SpawnPosition.position
	Global.player.scale = Vector2(0.2, 0.2)
	add_child(Global.player)
	Global.health_changed.emit()
	
	Global.enemy_destroyed.connect(enemy_destroyed_callback)
	Global.play_explosion.connect(play_explosion)

func game_over():
	Global.playing = false
	$AudioStreamPlayer2D.seek(0)
	if $AudioStreamPlayer2D.playing:
		$AudioStreamPlayer2D.stop()
	for enemy in enemies:
		enemy.call_deferred("queue_free")
	enemies.clear()
	for bullet in Global.bullets:
		bullet.call_deferred("queue_free")
	Global.bullets.clear()
	for debree in Global.debree_list:
		debree.call_deferred("queue_free")
	Global.debree_list.clear()
	
	$ShooterSpawnTimer.stop()
	$ChaserSpawnTimer.stop()
	$SprinkleSpawnTimer.stop()
	$BombSpawnTimer.stop()
	$DifficultyTimer.start()
	
	$hud.visible = false
	$GameOver.visible = true
	Global.enemy_destroyed.disconnect(enemy_destroyed_callback)
	Global.play_explosion.disconnect(play_explosion)
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.playing = false
	Global.main_scene = self
	$hud.visible = false
	$MainMenu.visible = true
	$GameOver.visible = false
	Global.start_game.connect(start_game)
	Global.game_over.connect(game_over)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if Global.player:
		$SpawnPath.global_position = Global.player.global_position
		$hud.call("update_debug_cf", $SpawnPath.global_position)
		$hud.call("update_shooter_timer", $DifficultyTimer.time_left)
		$hud.call("update_chaser_timer", $ChaserSpawnTimer.time_left)
	
	if player_out_of_map:
		var return_vector = Vector2.from_angle(\
			Global.player.global_position.direction_to($SpawnPosition.global_position).angle())\
		 	* return_force_strength
		Global.player.call_deferred("add_extra_constant_force", return_vector)
	
	if Global.playing and !$AudioStreamPlayer2D.playing:
		$AudioStreamPlayer2D.global_position = Global.player.global_position
		$AudioStreamPlayer2D.play()
		pass

func createShootingEnemy(pos: Vector2):
	var shooting_enemy = shooter_enemy_scene.instantiate()
	shooting_enemy.global_position = pos
	shooting_enemy.call("look_at", Global.player.global_position)
	shooting_enemy.global_rotation += PI/2
	#enemy.call("set_gun", false) #to inst with gun
	add_child(shooting_enemy)
	enemies.append(shooting_enemy)
	
func createChasingEnemy(pos: Vector2):
	var enemy = chasing_enemy_scene.instantiate()
	enemy.global_position = pos
	enemy.call("look_at", Global.player.global_position)
	enemy.global_rotation += PI/2
	#enemy.call("set_gun", false) #to inst with gun
	add_child(enemy)
	enemies.append(enemy)
	
func createSprinkleEnemy(pos: Vector2):
	var enemy = sprinkle_enemy_scene.instantiate()
	enemy.global_position = pos
	add_child(enemy)
	enemies.append(enemy)

func _on_playable_area_area_exited(area: Area2D) -> void:
	pass

func _on_playable_area_body_exited(body: Node2D) -> void:
	if body == Global.player:
		player_out_of_map = true
	if Global.bullets.find(body) != -1:
		await get_tree().create_timer(3.0).timeout
		if body != null:
			Global.bullets.erase(body)
			body.queue_free()

func _on_playable_area_body_entered(body: Node2D) -> void:
	if body == Global.player:
		Global.player.call_deferred("add_extra_constant_force", Vector2.ZERO)
		player_out_of_map = false


func _on_chaser_spawn_timer_timeout() -> void:
	var spawn_location = get_random_enemy_spawn_point()
	createChasingEnemy(spawn_location)

func _on_shooter_spawn_timer_timeout() -> void:
	var spawn_location = get_random_enemy_spawn_point()
	createShootingEnemy(spawn_location)

func _on_difficulty_timer_timeout() -> void:
	$ShooterSpawnTimer.wait_time = $ShooterSpawnTimer.wait_time - $ShooterSpawnTimer.wait_time/2
	$ChaserSpawnTimer.wait_time = $ChaserSpawnTimer.wait_time - $ChaserSpawnTimer.wait_time/2
	$SprinkleSpawnTimer.wait_time = $SprinkleSpawnTimer.wait_time - $SprinkleSpawnTimer.wait_time/2

func enemy_destroyed_callback(enemy, pos):
	enemies.erase(enemy)
	Global.score += 1
	$hud.update_score()
	$EnemyExplode.global_position = Global.player.global_position
	$EnemyExplode.play()
	await $EnemyExplode.finished
	$EnemyExplode.seek(0)

func play_explosion(pos):
	$EnemyExplode.global_position = Global.player.global_position
	$EnemyExplode.play()
	await $EnemyExplode.finished
	$EnemyExplode.seek(0)

func _on_sprinkle_spawn_timer_timeout() -> void:
	var spawn_location = get_random_enemy_spawn_point()
	createSprinkleEnemy(spawn_location)
