extends Control

# Campos da interface
@onready var room_code_line_edit = $VBoxContainer/HBoxContainer/RoomCodeLineEdit
@onready var join_room_button = $VBoxContainer/HBoxContainer/JoinRoomButton
@onready var create_room_button = $VBoxContainer/CreateRoomButton
@onready var status_label = $VBoxContainer/StatusLabel

# URL padrão do servidor (pode trocar para wss:// quando usar no Render)
const DEFAULT_SERVER_URL = "ws://localhost:9090"

func _ready() -> void:
	# Conecta os botões da interface
	join_room_button.connect("pressed", Callable(self, "_on_join_room_button_pressed"))
	create_room_button.connect("pressed", Callable(self, "_on_create_room_button_pressed"))
	
	# Conecta aos sinais do WebSocketClient
	call_deferred("_connect_websocket_signals")
	
	status_label.text = "Conectando ao servidor..."
	
	# Lê a URL configurada no ProjectSettings (ou usa a padrão)
	var server_url = ProjectSettings.get_setting("simple_multiplayer/server_url", DEFAULT_SERVER_URL)
	print("Conectando em: ", server_url)
	
	# Conecta ao servidor
	var ws_client = get_node("/root/WebSocketClient")
	if ws_client:
		ws_client.connect_to_server(server_url)
	else:
		status_label.text = "WebSocketClient não disponível"
		push_error("WebSocketClient Autoload não encontrado!")

func _connect_websocket_signals():
	# Conecta todos os sinais do WebSocketClient
	var ws_client = get_node("/root/WebSocketClient")
	if ws_client:
		ws_client.connect("connection_succeeded", Callable(self, "_on_connection_succeeded"))
		ws_client.connect("connection_failed", Callable(self, "_on_connection_failed"))
		ws_client.connect("room_created", Callable(self, "_on_room_created"))
		ws_client.connect("room_joined", Callable(self, "_on_room_joined"))
		ws_client.connect("server_error", Callable(self, "_on_server_error"))
		
		# Carrega o mundo apenas quando o servidor avisar
		ws_client.connect("start_game", Callable(self, "_load_world_scene"))
		
		status_label.text = "Pronto para conectar"
	else:
		status_label.text = "WebSocketClient não disponível"

func _on_join_room_button_pressed() -> void:
	# Pede para entrar em uma sala
	var ws_client = get_node("/root/WebSocketClient")
	if ws_client:
		status_label.text = "Entrando na sala..."
		ws_client.send_message("join_room", {"code": room_code_line_edit.text})

func _on_create_room_button_pressed() -> void:
	# Pede para criar uma nova sala
	var ws_client = get_node("/root/WebSocketClient")
	if ws_client:
		status_label.text = "Criando sala..."
		ws_client.send_message("create_room", {})

func _on_connection_succeeded() -> void:
	status_label.text = "Conectado! Crie ou entre em uma sala."

func _on_connection_failed() -> void:
	status_label.text = "Falha na conexão."

func _on_room_created(data: Dictionary):
	status_label.text = "Sala criada! Código: %s. Aguardando outro jogador..." % data.get("code")
	# Desabilita botões para evitar cliques duplos
	join_room_button.disabled = true
	create_room_button.disabled = true
	room_code_line_edit.editable = false

func _on_room_joined(data: Dictionary):
	status_label.text = "Entrou na sala: %s. Aguardando início..." % data.get("code")
	join_room_button.disabled = true
	create_room_button.disabled = true
	room_code_line_edit.editable = false
	
func _load_world_scene():
	# Troca para a cena do jogo quando todos estiverem prontos
	var scene_path = "res://demo/cenas/test_world.tscn"
	var error = get_tree().change_scene_to_file(scene_path)
	
	if error != OK:
		push_error("ERRO ao carregar a cena do mundo!")
	else:
		print("Mundo do jogo carregado com sucesso!")
