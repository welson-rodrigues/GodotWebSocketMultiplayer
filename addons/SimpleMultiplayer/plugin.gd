@tool
extends EditorPlugin

const WEBSOCKET_CLIENT_PATH = "res://addons/SimpleMultiplayer/websocket_client.gd"
const MULTIPLAYER_MANAGER_PATH = "res://addons/SimpleMultiplayer/multiplayer_manager.gd"

func _enter_tree():
	# Registra os singletons
	#add_autoload_singleton("WebSocketClient", WEBSOCKET_CLIENT_PATH)
	#add_autoload_singleton("MultiplayerManager", MULTIPLAYER_MANAGER_PATH)
	print("Addon Simple Multiplayer Ativado!")

func _exit_tree():
	#remove_autoload_singleton("WebSocketClient")
	#remove_autoload_singleton("MultiplayerManager")
	print("Addon Simple Multiplayer Desativado.")
