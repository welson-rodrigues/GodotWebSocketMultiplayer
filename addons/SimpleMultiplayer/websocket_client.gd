extends Node

signal connection_succeeded
signal connection_failed
signal connection_closed
signal room_created(data)
signal room_joined(data)
signal server_error(data)
signal player_joined(data)
signal player_left(data)
signal received_data(data)

var uuid: String = ""
var _peer := WebSocketPeer.new()
var _is_connected := false

# Variável global simples em vez de tipo estático
var instance = null

func _enter_tree():
	instance = self
	print("WebSocketClient autoload carregado")

func _exit_tree():
	instance = null

func _process(_delta):
	if _is_connected:
		_peer.poll()
		var state = _peer.get_ready_state()
		if state == WebSocketPeer.STATE_CLOSED or state == WebSocketPeer.STATE_CLOSING:
			if _is_connected:
				_is_connected = false
				emit_signal("connection_closed")
		
		while _is_connected and _peer.get_available_packet_count() > 0:
			var packet = _peer.get_packet().get_string_from_utf8()
			var data = JSON.parse_string(packet)
			if data is Dictionary:
				handle_incoming_data(data)

func connect_to_server(url: String):
	if _peer.get_ready_state() != WebSocketPeer.STATE_CLOSED:
		push_warning("WebSocket connection is already open or connecting.")
		return
		
	var err = _peer.connect_to_url(url)
	if err != OK:
		emit_signal("connection_failed")
	else:
		_is_connected = true

func send_message(command: String, content: Dictionary):
	if not _is_connected or _peer.get_ready_state() != WebSocketPeer.STATE_OPEN:
		push_warning("Cannot send message, WebSocket is not open.")
		return
	_peer.send_text(JSON.stringify({"cmd": command, "content": content}))

func handle_incoming_data(data: Dictionary):
	var cmd = data.get("cmd", "")
	var content = data.get("content", {})
	match cmd:
		"joined_server":
			uuid = content.get("uuid", "")
			emit_signal("connection_succeeded")
		"room_created":
			emit_signal("room_created", content)
		"room_joined":
			emit_signal("room_joined", content)
		"player_joined":
			emit_signal("player_joined", content)
		"player_left":
			emit_signal("player_left", content)
		"error":
			emit_signal("server_error", content)
		_:
			emit_signal("received_data", data)
