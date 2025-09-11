extends CharacterBody2D

# Network players são controlados pelo MultiplayerManager
# Eles apenas mostram a posição recebida do servidor

func _ready():
	print("Network player pronto: ", name)
