# Simple WebSocket Multiplayer for Godot

![Godot Version](https://img.shields.io/badge/Godot-4.x-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

Um addon simples para Godot 4.x que fornece uma base sólida para jogos multiplayer usando WebSockets. Este projeto inclui um lobby funcional, sistema de salas, sincronização de jogadores e um servidor Node.js de exemplo, pronto para ser usado.

Este addon foi desenvolvido com a exportação para **plataformas mobile** em mente e é totalmente compatível.

## Funcionalidades

* **Conexão Automática:** O cliente se conecta automaticamente a um servidor pré-configurado.
* **Lobby Simples:** Interface para criar e entrar em salas com códigos.
* **Sincronização de Partida:** O jogo só começa quando o número desejado de jogadores entra na sala.
* **Gerenciador de Players:** Spawna e remove automaticamente os jogadores locais e de rede.
* **Sincronização de Posição:** Exemplo básico de como sincronizar a posição dos jogadores.
* **Servidor Node.js de Exemplo:** Inclui um servidor Express + WebSocket pronto para usar.

## Instalação

1.  Baixe este projeto ou clone o repositório.
2.  Copie a pasta `SimpleMultiplayer` que está dentro de `addons/` para a pasta `addons/` do seu próprio projeto.
3.  Vá em **Projeto -> Configurações do Projeto... -> Plugins** e ative o plugin "Simple WebSocket Multiplayer". Os Singletons (`WebSocketClient` e `MultiplayerManager`) serão carregados automaticamente.

## Guia de Uso Rápido

### Passo 1: Configurar o Servidor

Você precisará de um servidor Node.js rodando para que os clientes possam se conectar. O código do servidor está incluído neste projeto.

#### Teste Local (Localhost)

Ideal para desenvolver e testar na sua própria máquina.

1.  Abra a pasta do servidor em um terminal.
2.  Instale as dependências: `npm install`
3.  Inicie o servidor: `node server.js`

#### Teste Online (com Render.com)

Para jogar com amigos pela internet, você pode hospedar o servidor gratuitamente em serviços como o Render.com.

O passo a passo completo de como configurar e fazer o deploy do servidor no Render.com é ensinado no meu canal do YouTube!

**➡️ [Link para o seu canal ou vídeo específico aqui]**

### Passo 2: Configurar o Cliente (Godot)

1.  No editor da Godot, vá em **Projeto -> Configurações do Projeto... -> Simple Multiplayer**.
2.  Você encontrará a propriedade `Server Url`.
    * Para **testes locais**, use: `ws://127.0.0.1:9090`
    * Para o **servidor online** no Render, use o endereço que ele te fornecer, lembrando de usar `wss://` (WebSocket Seguro): `wss://seu-servidor.onrender.com`

### Passo 3: Criar a Cena de Lobby

Você pode usar a cena `lobby_example.tscn` como base. O sistema funciona através de sinais emitidos pelo Singleton `WebSocketClient`.

Exemplo de como reagir aos eventos no script do seu lobby:

```gdscript
func _ready():
    var ws_client = get_node("/root/WebSocketClient")
    
    # Conecta aos sinais para dar feedback ao jogador
    ws_client.connect("connection_succeeded", Callable(self, "_on_connection_succeeded"))
    ws_client.connect("room_created", Callable(self, "_on_room_created"))
    ws_client.connect("start_game", Callable(self, "_on_start_game"))

func _on_connection_succeeded():
    status_label.text = "Conectado! Crie ou entre em uma sala."

func _on_room_created(data: Dictionary):
    var code = data.get("code", "ERRO")
    status_label.text = "Sala criada: %s. Aguardando jogadores..." % code

func _on_start_game():
    # Lógica para carregar a cena principal do jogo
    get_tree().change_scene_to_file("res://world.tscn")
