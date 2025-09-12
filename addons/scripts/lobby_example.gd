extends Control

#@onready var server_url_line_edit = $VBoxContainer/ServerUrlLineEdit
@onready var connect_button = $VBoxContainer/ConnectButton
@onready var room_code_line_edit = $VBoxContainer/HBoxContainer/RoomCodeLineEdit
@onready var join_room_button = $VBoxContainer/HBoxContainer/JoinRoomButton
@onready var create_room_button = $VBoxContainer/CreateRoomButton
@onready var status_label = $VBoxContainer/StatusLabel

const DEFAULT_SERVER_URL = "ws://localhost:9090"

func _ready() -> void:
	# Conecta os botões
	connect_button.connect("pressed", Callable(self, "_on_connect_button_pressed"))
	join_room_button.connect("pressed", Callable(self, "_on_join_room_button_pressed"))
	create_room_button.connect("pressed", Callable(self, "_on_create_room_button_pressed"))
	
	# Conecta aos sinais do WebSocketClient
	call_deferred("_connect_websocket_signals")
	
	status_label.text = "Conectando ao servidor..."
	
	# Pega a URL das Configurações do Projeto
	var server_url = ProjectSettings.get_setting("simple_multiplayer/server_url", DEFAULT_SERVER_URL)
	print("Conectando em: ", server_url)
	
	var ws_client = get_node("/root/WebSocketClient")
	if ws_client:
		ws_client.connect_to_server(server_url)
	else:
		status_label.text = "WebSocketClient não disponível"
		push_error("WebSocketClient Autoload não encontrado!")

func _connect_websocket_signals():
	var ws_client = get_node("/root/WebSocketClient")
	if ws_client:
		ws_client.connect("connection_succeeded", Callable(self, "_on_connection_succeeded"))
		ws_client.connect("connection_failed", Callable(self, "_on_connection_failed"))
		ws_client.connect("room_created", Callable(self, "_on_room_created"))
		ws_client.connect("room_joined", Callable(self, "_on_room_joined"))
		ws_client.connect("server_error", Callable(self, "_on_server_error"))
		
		# ✅ LINHA ADICIONADA PARA OUVIR O SINAL DE INÍCIO DE JOGO
		ws_client.connect("start_game", Callable(self, "_load_world_scene"))
		
		status_label.text = "Pronto para conectar"
	else:
		status_label.text = "WebSocketClient não disponível"

#func _on_connect_button_pressed() -> void:
	#var ws_client = get_node("/root/WebSocketClient")
	#if ws_client:
		#status_label.text = "Conectando..."
		#ws_client.connect_to_server(server_url_line_edit.text)
	#else:
		#status_label.text = "WebSocketClient não disponível"

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
	# - REMOVE O CARREGAMENTO DA CENA DAQUI
	status_label.text = "Sala criada! Código: %s. Aguardando outro jogador..." % data.get("code")
	# Desabilita botões para evitar ações duplicadas
	join_room_button.disabled = true
	create_room_button.disabled = true
	room_code_line_edit.editable = false

func _on_room_joined(data: Dictionary):
	# - REMOVE O CARREGAMENTO DA CENA DAQUI TAMBÉM
	# O sinal 'start_game' vai cuidar disso para todos ao mesmo tempo.
	status_label.text = "Entrou na sala: %s. Aguardando início..." % data.get("code")
	# Desabilita botões
	join_room_button.disabled = true
	create_room_button.disabled = true
	room_code_line_edit.editable = false
	
func _load_world_scene():
	print("==========================================")
	print("✅ SINAL 'start_game' RECEBIDO! Trocando de cena agora...")
	print("==========================================")
	
	var scene_path = "res://addons/cenas/test_world.tscn"
	var error = get_tree().change_scene_to_file(scene_path)
	
	if error != OK:
		# Se houver um erro, o código vai entrar aqui
		print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
		push_error("ERRO CRÍTICO AO CARREGAR A CENA DO MUNDO!")
		print("Caminho da cena: ", scene_path)
		print("Código do Erro: ", error)
		print("Verifique se o caminho do arquivo está correto e se a cena não tem erros.")
		print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	else:
		print("Mundo do jogo carregado com sucesso!")
