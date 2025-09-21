@tool
extends EditorPlugin

func _enter_tree():
	# Adiciona os autoloads para facilitar o uso
	add_autoload_singleton("WebSocketClient", "res://addons/SimpleMultiplayer/websocket_client.gd")
	add_autoload_singleton("MultiplayerManager", "res://addons/SimpleMultiplayer/multiplayer_manager.tscn")
	print("Plugin SimpleMultiplayer carregado!")

func _exit_tree():
	# Remove os autoloads ao desativar o plugin
	remove_autoload_singleton("WebSocketClient")
	remove_autoload_singleton("MultiplayerManager")
	print("Plugin SimpleMultiplayer descarregado!")
