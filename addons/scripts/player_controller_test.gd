# player_controller_test.gd (VERSÃO CORRIGIDA)
extends CharacterBody2D

const SPEED = 300.0

# Criamos uma variável para guardar a referência do nosso singleton
var WebSocketClient = null

func _ready() -> void:
	# No _ready, nós pedimos ao Godot para nos dar o singleton.
	# Isso garante que o addon já tenha sido carregado.
	if Engine.has_singleton("WebSocketClient"):
		WebSocketClient = Engine.get_singleton("WebSocketClient")

func _physics_process(_delta: float) -> void:
	# Se a referência não foi encontrada, não faz nada.
	if not WebSocketClient:
		return

	# Apenas envia a posição se for o jogador local
	if name == WebSocketClient.uuid:
		var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		velocity = direction * SPEED
		move_and_slide()
		
		# Envia a posição para o servidor
		WebSocketClient.send_message("position", {"x": position.x, "y": position.y})
