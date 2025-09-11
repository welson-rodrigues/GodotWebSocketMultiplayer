extends Node2D

func _ready():
	# Registra o PlayerContainer no MultiplayerManager
	var player_container = $PlayerContainer
	var mp_manager = get_node("/root/MultiplayerManager")
	if mp_manager and mp_manager.has_method("set_player_container"):
		mp_manager.set_player_container(player_container)
		print("PlayerContainer registrado no MultiplayerManager")
