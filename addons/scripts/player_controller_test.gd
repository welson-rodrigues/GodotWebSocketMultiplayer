# player_controller_test.gd
extends CharacterBody2D

const SPEED = 300.0

func _physics_process(delta):
	# Apenas envia a posição se for o jogador local
	if name == WebSocketClient.uuid:
		var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		velocity = direction * SPEED
		move_and_slide()
		
		# Envia a posição para o servidor
		WebSocketClient.send_message("position", {"x": position.x, "y": position.y})
