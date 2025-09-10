extends Node

@export var player_scene: PackedScene
@export var network_player_scene: PackedScene
@export var player_container_path: NodePath

var player_nodes = {}

func _ready():
	print("MultiplayerManager carregado")
	
	# Conecta os sinais com um pequeno delay para garantir que WebSocketClient esteja pronto
	call_deferred("_connect_signals")

func _connect_signals():
	# Acessa o WebSocketClient através do autoload global
	var ws_client = get_node("/root/WebSocketClient")
	if ws_client:
		ws_client.connect("player_joined", Callable(self, "_on_player_joined"))
		ws_client.connect("player_left", Callable(self, "_on_player_left"))
		ws_client.connect("received_data", Callable(self, "_on_received_data"))
		print("Sinais conectados com sucesso")
	else:
		print("WebSocketClient não encontrado no /root")

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
