extends Control

@onready var server_url_line_edit = $VBoxContainer/ServerUrlLineEdit
@onready var connect_button = $VBoxContainer/ConnectButton
@onready var room_code_line_edit = $VBoxContainer/HBoxContainer/RoomCodeLineEdit
@onready var join_room_button = $VBoxContainer/HBoxContainer/JoinRoomButton
@onready var create_room_button = $VBoxContainer/CreateRoomButton
@onready var status_label = $VBoxContainer/StatusLabel

func _ready() -> void:
	# Conecta os botões
	connect_button.connect("pressed", Callable(self, "_on_connect_button_pressed"))
	join_room_button.connect("pressed", Callable(self, "_on_join_room_button_pressed"))
	create_room_button.connect("pressed", Callable(self, "_on_create_room_button_pressed"))
	
	# Conecta aos sinais do WebSocketClient
	call_deferred("_connect_websocket_signals")

func _connect_websocket_signals():
	var ws_client = get_node("/root/WebSocketClient")
	if ws_client:
		ws_client.connect("connection_succeeded", Callable(self, "_on_connection_succeeded"))
		ws_client.connect("connection_failed", Callable(self, "_on_connection_failed"))
		ws_client.connect("room_created", Callable(self, "_on_room_created"))
		ws_client.connect("room_joined", Callable(self, "_on_room_joined"))
		ws_client.connect("server_error", Callable(self, "_on_server_error"))
		status_label.text = "Pronto para conectar"
	else:
		status_label.text = "WebSocketClient não disponível"

func _on_connect_button_pressed() -> void:
	var ws_client = get_node("/root/WebSocketClient")
	if ws_client:
		status_label.text = "Conectando..."
		ws_client.connect_to_server(server_url_line_edit.text)
	else:
		status_label.text = "WebSocketClient não disponível"

func _on_join_room_button_pressed() -> void:
	var ws_client = get_node("/root/WebSocketClient")
	if ws_client:
		status_label.text = "Entrando na sala..."
		ws_client.send_message("join_room", {"code": room_code_line_edit.text})
	else:
		status_label.text = "WebSocketClient não disponível"

func _on_create_room_button_pressed() -> void:
	var ws_client = get_node("/root/WebSocketClient")
	if ws_client:
		status_label.text = "Criando sala..."
		ws_client.send_message("create_room", {})
	else:
		status_label.text = "WebSocketClient não disponível"

# --- Funções que recebem feedback ---
func _on_connection_succeeded() -> void:
	status_label.text = "Conectado! Crie ou entre em uma sala."

func _on_connection_failed() -> void:
	status_label.text = "Falha na conexão."

func _on_room_created(data: Dictionary):
	status_label.text = "Sala criada! Código: %s" % data.get("code")
	# ✅ CARREGA O MUNDO TAMBÉM QUANDO CRIA UMA SALA
	call_deferred("_load_world_scene")

func _on_room_joined(data: Dictionary):
	status_label.text = "Entrou na sala: %s" % data.get("code")
	# ✅ CARREGA O MUNDO QUANDO ENTRA NUMA SALA
	call_deferred("_load_world_scene")
	
func _load_world_scene():
	print("Carregando mundo do jogo...")
	var error = get_tree().change_scene_to_file("res://addons/cenas/test_world.tscn")
	if error != OK:
		print("ERRO ao carregar cena do mundo: ", error)
	else:
		print("Mundo do jogo carregado com sucesso!")
