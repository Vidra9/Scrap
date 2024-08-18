extends CanvasLayer

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if visible and not $AudioStreamPlayer2D.playing:
		$AudioStreamPlayer2D.play()

func _on_start_game_pressed() -> void:
	Global.start_game.emit()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_visibility_changed() -> void:
	$AudioStreamPlayer2D.seek(0)
	if not visible and $AudioStreamPlayer2D.playing:
		$AudioStreamPlayer2D.stop()
