# lobby_example.gd
extends Control

@onready var server_url_line_edit = $VBoxContainer/ServerUrlLineEdit
@onready var connect_button = $VBoxContainer/ConnectButton
@onready var room_code_line_edit = $VBoxContainer/HBoxContainer/RoomCodeLineEdit
@onready var join_room_button = $VBoxContainer/HBoxContainer/JoinRoomButton
@onready var create_room_button = $VBoxContainer/CreateRoomButton
@onready var status_label = $VBoxContainer/StatusLabel

# Guardamos a referência dos singletons para não ter que chamar Engine.get_singleton() toda hora
var WebSocketClient = null
var MultiplayerManager = null

func _ready() -> void:
	# Verifica se o primeiro singleton essencial existe
	if Engine.has_singleton("WebSocketClient"):
		WebSocketClient = Engine.get_singleton("WebSocketClient")
	else:
		push_error("WebSocketClient não encontrado! Certifique-se de que o plugin está ativo.")
		status_label.text = "ERRO: WebSocketClient não encontrado."
		return # PARAR a execução para evitar mais erros.

	# Verifica se o segundo singleton existe
	if Engine.has_singleton("MultiplayerManager"):
		MultiplayerManager = Engine.get_singleton("MultiplayerManager")
	else:
		push_error("MultiplayerManager não encontrado! Certifique-se de que o plugin está ativo.")
		status_label.text = "ERRO: MultiplayerManager não encontrado."
		return # PARAR a execução.

	# Conecta os sinais dos botões às funções deste script
	connect_button.connect("pressed", Callable(self, "_on_connect_button_pressed"))
	join_room_button.connect("pressed", Callable(self, "_on_join_room_button_pressed"))
	create_room_button.connect("pressed", Callable(self, "_on_create_room_button_pressed"))

	# Conecta aos sinais do addon para receber feedback
	WebSocketClient.connect("connection_succeeded", Callable(self, "_on_connection_succeeded"))
	WebSocketClient.connect("connection_failed", Callable(self, "_on_connection_failed"))
	WebSocketClient.connect("room_created", Callable(self, "_on_room_created"))
	WebSocketClient.connect("room_joined", Callable(self, "_on_room_joined"))
	WebSocketClient.connect("server_error", Callable(self, "_on_server_error"))

func _on_connect_button_pressed() -> void:
	status_label.text = "Conectando..."
	WebSocketClient.connect_to_server(server_url_line_edit.text)

func _on_join_room_button_pressed() -> void:
	status_label.text = "Entrando na sala..."
	WebSocketClient.send_message("join_room", {"code": room_code_line_edit.text})

func _on_create_room_button_pressed() -> void:
	status_label.text = "Criando sala..."
	WebSocketClient.send_message("create_room", {})

# --- Funções que recebem feedback do addon ---

func _on_connection_succeeded() -> void:
	status_label.text = "Conectado! Crie ou entre em uma sala."

func _on_connection_failed() -> void:
	status_label.text = "Falha na conexão."

func _on_room_created(data: Dictionary) -> void:
	status_label.text = "Sala criada! Código: %s" % data.get("code")

func _on_room_joined(data: Dictionary) -> void:
	status_label.text = "Entrou na sala: %s" % data.get("code")
	MultiplayerManager.spawn_player(WebSocketClient.uuid, true) # Cria o jogador local

func _on_server_error(data: Dictionary) -> void:
	status_label.text = "Erro: %s" % data.get("msg")
