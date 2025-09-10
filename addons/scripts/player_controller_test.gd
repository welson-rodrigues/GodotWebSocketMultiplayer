extends CharacterBody2D

const SPEED = 300.0

func _physics_process(_delta: float) -> void:
	# Acessa o WebSocketClient através do caminho absoluto
	var ws_client = get_node("/root/WebSocketClient")
	if ws_client and name == ws_client.uuid:
		var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		velocity = direction * SPEED
		move_and_slide()
		
		# Envia a posição para o servidor
		ws_client.send_message("position", {"x": position.x, "y": position.y})
