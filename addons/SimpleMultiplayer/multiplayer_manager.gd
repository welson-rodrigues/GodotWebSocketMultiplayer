# multiplayer_manager.gd
extends Node

@export var player_scene: PackedScene
@export var network_player_scene: PackedScene
@export var player_container_path: NodePath

var player_nodes = {} # Dicionário para guardar os nós dos jogadores

# Guardamos a referência do singleton
var WebSocketClient = null

func _ready():
	# Verificamos se o singleton existe. Se não, emitimos um erro e paramos a execução.
	if not Engine.has_singleton("WebSocketClient"):
		push_error("WebSocketClient não encontrado! Verifique se o plugin está ativo e a ordem dos Autoloads.")
		return

	# Se existe, pegamos a referência uma única vez.
	WebSocketClient = Engine.get_singleton("WebSocketClient")
	
	# Conectamos os sinais
	WebSocketClient.connect("player_joined", Callable(self, "_on_player_joined"))
	WebSocketClient.connect("player_left", Callable(self, "_on_player_left"))
	WebSocketClient.connect("received_data", Callable(self, "_on_received_data"))

func spawn_player(uuid: String, is_local: bool):
	if not player_scene or not network_player_scene:
		push_error("Cenas de jogador não configuradas no MultiplayerManager!")
		return
		
	var scene = player_scene if is_local else network_player_scene
	var player = scene.instantiate()
	player.name = uuid
	get_node(player_container_path).add_child(player)
	player_nodes[uuid] = player

func remove_player(uuid: String):
	if player_nodes.has(uuid):
		player_nodes[uuid].queue_free()
		player_nodes.erase(uuid)

func _on_player_joined(data: Dictionary):
	var new_uuid = data.get("uuid")
	spawn_player(new_uuid, false)

func _on_player_left(data: Dictionary):
	var left_uuid = data.get("uuid")
	remove_player(left_uuid)

func _on_received_data(data: Dictionary):
	var cmd = data.get("cmd")
	var content = data.get("content")
	var sender_uuid = content.get("uuid")

	if cmd == "update_position":
		if player_nodes.has(sender_uuid):
			player_nodes[sender_uuid].position = Vector2(content.x, content.y)
	
	# O usuário do addon adicionaria suas próprias lógicas de "update_action" aqui
