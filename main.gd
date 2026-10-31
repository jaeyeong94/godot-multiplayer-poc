extends Node2D

const PLAYER_SCENE := preload("res://player.tscn")
const DEFAULT_PORT := 8080
const DEFAULT_ADDRESS := "127.0.0.1"

@onready var world: Node2D = $World
@onready var status_label: Label = $UI/VBoxContainer/StatusLabel
@onready var address_edit: LineEdit = $UI/VBoxContainer/AddressEdit
@onready var port_edit: LineEdit = $UI/VBoxContainer/PortEdit
@onready var host_button: Button = $UI/VBoxContainer/HostButton
@onready var join_button: Button = $UI/VBoxContainer/JoinButton


func _ready() -> void:
	host_button.pressed.connect(_on_host_pressed)
	join_button.pressed.connect(_on_join_pressed)
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


func _set_status(text: String) -> void:
	status_label.text = "Status: " + text


func _get_port() -> int:
	return int(port_edit.text) if port_edit.text.is_valid_int() else DEFAULT_PORT


func _on_host_pressed() -> void:
	if multiplayer.multiplayer_peer != null:
		return
	# Note: a browser tab cannot listen on a socket, so hosting only works
	# from a desktop (or dedicated) build; web builds are Join-only.
	var peer := WebSocketMultiplayerPeer.new()
	var err := peer.create_server(_get_port())
	if err != OK:
		_set_status("Failed to host (error %d)" % err)
		return
	multiplayer.multiplayer_peer = peer
	_set_status("Hosting on port %d" % _get_port())
	_spawn_player(1)


func _on_join_pressed() -> void:
	if multiplayer.multiplayer_peer != null:
		return
	var address := address_edit.text.strip_edges()
	if address.is_empty():
		address = DEFAULT_ADDRESS
	var port := _get_port()
	if address.begins_with("ws://") or address.begins_with("wss://"):
		if address.rfind(":", 6) == -1:
			address += ":%d" % port
	else:
		address = "ws://%s:%d" % [address, port]
	var peer := WebSocketMultiplayerPeer.new()
	var err := peer.create_client(address)
	if err != OK:
		_set_status("Failed to connect (error %d)" % err)
		return
	multiplayer.multiplayer_peer = peer
	_set_status("Connecting to %s ..." % address)


func _spawn_player(id: int) -> void:
	var player := PLAYER_SCENE.instantiate()
	player.name = str(id)
	player.position = Vector2(randf_range(96.0, viewport_width() - 96.0), randf_range(96.0, 552.0))
	world.add_child(player, true)


func viewport_width() -> float:
	return 1152.0


func _despawn_player(id: int) -> void:
	var node := world.get_node_or_null(NodePath(str(id)))
	if node != null:
		node.queue_free()


func _on_peer_connected(id: int) -> void:
	# The server (authority) spawns a player for every connecting peer.
	if multiplayer.is_server():
		_spawn_player.call_deferred(id)
	_set_status("Peer %d connected" % id)


func _on_peer_disconnected(id: int) -> void:
	if multiplayer.is_server():
		_despawn_player.call_deferred(id)
	_set_status("Peer %d disconnected" % id)


func _on_connected_to_server() -> void:
	_set_status("Connected")


func _on_connection_failed() -> void:
	_set_status("Connection failed")
	_reset_peer()


func _on_server_disconnected() -> void:
	_set_status("Server disconnected")
	_reset_peer()


func _reset_peer() -> void:
	multiplayer.multiplayer_peer = null
	for child in world.get_children():
		child.queue_free()
