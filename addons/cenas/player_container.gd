extends Node

func _ready():
	print("PlayerContainer pronto!")
	var mp_manager = get_node("/root/MultiplayerManager")
	if mp_manager and mp_manager.has_method("set_player_container"):
		mp_manager.set_player_container(self)
		print("PlayerContainer registrado no MultiplayerManager")
	else:
		print("ERRO: MultiplayerManager não encontrado")
