extends Node

const IP_ADDRESS: String = "localhost"
const PORT: int = 2026

var peer := NodeTunnelPeer.new()

signal server_created

func _ready() -> void:
	multiplayer.multiplayer_peer = peer
	peer.connect_to_relay("relay.nodetunnel.io", 9998)
	
	await  peer.relay_connected

func start_server() -> void:
	peer.host()
	
	await peer.hosting
	
	DisplayServer.clipboard_set(peer.online_id)
	
	#multiplayer.multiplayer_peer = peer
	server_created.emit()

func start_client(join_id : String) -> void:
	peer.join(join_id)
	
	await peer.joined
	#peer.create_client(IP_ADDRESS, PORT)
	multiplayer.multiplayer_peer = peer 
