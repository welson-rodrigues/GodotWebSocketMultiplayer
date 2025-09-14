@tool
extends EditorPlugin

func _enter_tree():
	# Adiciona as cenas do plugin para fácil acesso
	add_autoload_singleton("WebSocketClient", "res://addons/SimpleMultiplayer/websocket_client.gd")
	add_autoload_singleton("MultiplayerManager", "res://addons/SimpleMultiplayer/multiplayer_manager.tscn")
	
	print("Plugin SimpleMultiplayer carregado!")

func _exit_tree():
	remove_autoload_singleton("WebSocketClient")
	remove_autoload_singleton("MultiplayerManager")
	
	print("Plugin SimpleMultiplayer descarregado!")
