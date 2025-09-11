extends CharacterBody2D

const SPEED = 300.0
var is_local_player: bool = false

func _ready():
	# Verifica se é o jogador local
	var ws_client = get_node_or_null("/root/WebSocketClient")
	if ws_client and name == ws_client.uuid:
		is_local_player = true
		print("É o jogador local: ", name)

func _physics_process(_delta: float) -> void:
	if is_local_player:
		handle_local_movement()

func handle_local_movement():
	var ws_client = get_node("/root/WebSocketClient")
	if ws_client:
		var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		velocity = direction * SPEED
		move_and_slide()
		
		# Envia a posição para o servidor
		ws_client.send_message("position", {"x": position.x, "y": position.y})
