extends CanvasLayer

func _ready():
	# A função OS.has_feature("mobile") retorna verdadeiro
	# se o jogo estiver rodando em um dispositivo móvel (Android/iOS).
	if not OS.has_feature("mobile"):
		# Se não for mobile, esconde todos os controles.
		hide()
