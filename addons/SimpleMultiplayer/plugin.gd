@tool
extends EditorPlugin

func _enter_tree():
	add_autoload_singleton("WebSocketClient", "res://addons/SimpleMultiplayer/websocket_client.gd")
	add_autoload_singleton("MultiplayerManager", "res://addons/SimpleMultiplayer/multiplayer_manager.gd")
	print("Addon Simple Multiplayer Ativado!")

func _exit_tree():
	remove_autoload_singleton("WebSocketClient")
	remove_autoload_singleton("MultiplayerManager")
	print("Addon Simple Multiplayer Desativado.")
