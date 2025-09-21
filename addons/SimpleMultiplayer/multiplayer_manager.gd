extends Node

# Cenas configuráveis: jogador local e jogador em rede
@export var player_scene: PackedScene
@export var network_player_scene: PackedScene

# Guarda os jogadores ativos na partida
var player_nodes = {}
# Guarda spawns que precisam ser processados depois que o PlayerContainer existir
var pending_spawns: Array = []

func _ready():
	# Logs úteis para depuração
	print("Player Scene configurada? ", player_scene != null)
	print("Network Player Scene configurada? ", network_player_scene != null)
	
	# Conecta os sinais do WebSocketClient (chamado de forma adiada para garantir que tudo carregou)
	call_deferred("_connect_signals")

func set_player_container(container: Node):
	# Define a cena que vai conter os jogadores
	var player_container = container
	print("PlayerContainer recebido: ", player_container.name)
	
	# Processa spawns que estavam pendentes antes do PlayerContainer existir
	for spawn_data in pending_spawns:
		_spawn_player_now(spawn_data.uuid, spawn_data.is_local, spawn_data.player_data)
	pending_spawns.clear()

func spawn_player(uuid: String, is_local: bool, player_data: Dictionary = {}):
	# Garante que as cenas estão configuradas
	if not player_scene or not network_player_scene:
		push_error("Cenas de jogador não configuradas!")
		return
	
	# Verifica se o PlayerContainer já existe na cena atual
	var player_container = get_tree().current_scene.get_node_or_null("PlayerContainer")
	if player_container:
		# Spawn imediato
		_spawn_player_now(uuid, is_local, player_data)
	else:
		# Caso ainda não exista, guarda para spawnar depois
		print("PlayerContainer não disponível, adiando spawn: ", uuid)
		pending_spawns.append({"uuid": uuid, "is_local": is_local, "player_data": player_data})

func _spawn_player_now(uuid: String, is_local: bool, player_data: Dictionary = {}):
	# Escolhe a cena certa (local ou de rede)
	var scene = player_scene if is_local else network_player_scene
	var player = scene.instantiate()
	player.name = uuid
	
	# Define a posição inicial, se existir no player_data
	if player_data.has("x") and player_data.has("y"):
		player.position = Vector2(player_data.x, player_data.y)
	
	# Adiciona o jogador na cena e salva no dicionário
	var player_container = get_tree().current_scene.get_node("PlayerContainer")
	player_container.add_child(player)
	player_nodes[uuid] = player
	print("Jogador spawnado: ", uuid, " (local: ", is_local, ")")

func remove_player(uuid: String):
	# Remove jogador quando desconecta
	if player_nodes.has(uuid):
		player_nodes[uuid].queue_free()
		player_nodes.erase(uuid)

func update_player_position(uuid: String, position: Vector2):
	# Atualiza posição de um jogador remoto
	if player_nodes.has(uuid):
		player_nodes[uuid].position = position

func _connect_signals():
	# Conecta os sinais do WebSocketClient ao MultiplayerManager
	var ws_client = get_node("/root/WebSocketClient")
	if ws_client:
		ws_client.connect("spawn_local_player", Callable(self, "_on_spawn_local_player"))
		ws_client.connect("spawn_new_player", Callable(self, "_on_spawn_new_player"))
		ws_client.connect("spawn_network_players", Callable(self, "_on_spawn_network_players"))
		ws_client.connect("update_position", Callable(self, "_on_update_position"))
		ws_client.connect("player_disconnected", Callable(self, "_on_player_disconnected"))
		print("Sinais de gameplay conectados com sucesso")
	else:
		print("WebSocketClient não encontrado")

# --- Callbacks para os sinais recebidos do servidor ---
func _on_spawn_local_player(player_data: Dictionary):
	var ws_client = get_node("/root/WebSocketClient")
	if ws_client:
		spawn_player(ws_client.uuid, true, player_data)

func _on_spawn_new_player(player_data: Dictionary):
	var player_uuid = player_data.get("uuid", "")
	if player_uuid:
		spawn_player(player_uuid, false, player_data)

func _on_spawn_network_players(players_data: Array):
	for player_data in players_data:
		var player_uuid = player_data.get("uuid", "")
		if player_uuid:
			spawn_player(player_uuid, false, player_data)

func _on_update_position(position_data: Dictionary):
	var uuid = position_data.get("uuid", "")
	var x = position_data.get("x", 0)
	var y = position_data.get("y", 0)
	
	if uuid and player_nodes.has(uuid):
		player_nodes[uuid].position = Vector2(x, y)

func _on_player_disconnected(player_data: Dictionary):
	var uuid = player_data.get("uuid", "")
	if uuid and player_nodes.has(uuid):
		remove_player(uuid)
