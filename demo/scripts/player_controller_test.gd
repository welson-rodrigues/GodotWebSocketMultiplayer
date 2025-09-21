extends CharacterBody2D

const SPEED = 300.0
var is_local_player: bool = false
var can_move: bool = false 

func _ready():
	# Verifica se é o jogador local (comparando UUID)
	var ws_client = get_node_or_null("/root/WebSocketClient")
	if ws_client and name == ws_client.uuid:
		is_local_player = true
		print("É o jogador local: ", name)
	
	# Só libera movimento depois que a cena estiver pronta
	call_deferred("enable_movement")

func enable_movement():
	can_move = true

func _physics_process(_delta: float) -> void:
	# Só o jogador local pode enviar inputs
	if is_local_player and can_move:
		handle_local_movement()

func handle_local_movement():
	# Lê o input, move o jogador e envia a posição para o servidor
	var ws_client = get_node("/root/WebSocketClient")
	if ws_client:
		var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		velocity = direction * SPEED
		move_and_slide()
		
		# Envia a posição atual para o servidor
		ws_client.send_message("position", {"x": position.x, "y": position.y})
