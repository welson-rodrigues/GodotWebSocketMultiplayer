extends CharacterBody2D

const SPEED = 300.0
var is_local_player: bool = false
var can_move: bool = false 

func _ready():
	# Verifica se é o jogador local
	var ws_client = get_node_or_null("/root/WebSocketClient")
	if ws_client and name == ws_client.uuid:
		is_local_player = true
		print("É o jogador local: ", name)
	
	# Usa call_deferred para garantir que a função seja chamada após o primeiro frame
	call_deferred("enable_movement")

func enable_movement():
	# Libera o movimento
	can_move = true

func _physics_process(_delta: float) -> void:
	# Só processa o movimento se for o jogador local E se o movimento estiver liberado
	if is_local_player and can_move:
		handle_local_movement()

func handle_local_movement():
	var ws_client = get_node("/root/WebSocketClient")
	if ws_client:
		var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		velocity = direction * SPEED
		move_and_slide()
		
		# Envia a posição para o servidor
		ws_client.send_message("position", {"x": position.x, "y": position.y})	
