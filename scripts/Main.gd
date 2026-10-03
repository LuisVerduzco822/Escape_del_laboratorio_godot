extends Node2D
## Escena raíz del juego. Gestiona qué se muestra en cada momento:
## el menú principal, el HUD + nivel en curso, o la pantalla final
## (game over / victoria). Reacciona a las señales de GameManager;
## nunca decide la lógica de juego por sí misma.

@export var level_scenes: Array[PackedScene] = []

@onready var level_holder: Node2D = $LevelHolder
@onready var menu_layer: CanvasLayer = $MenuLayer
@onready var hud_layer: CanvasLayer = $HUDLayer
@onready var end_layer: CanvasLayer = $EndLayer
@onready var end_title: Label = $EndLayer/CenterContainer/VBoxContainer/TitleStack/TitleLabel
@onready var end_title_shadow: Label = $EndLayer/CenterContainer/VBoxContainer/TitleStack/TitleShadow
@onready var end_score: Label = $EndLayer/CenterContainer/VBoxContainer/ScoreSummaryLabel
@onready var retry_button: Button = $EndLayer/CenterContainer/VBoxContainer/RetryButton
@onready var pause_layer: CanvasLayer = $PauseLayer

var current_level_node: Node = null
var end_focus_token := 0


func _ready() -> void:
	GameManager.max_level = level_scenes.size()
	GameManager.level_changed.connect(_on_level_changed)
	GameManager.game_over.connect(_on_game_over)
	GameManager.victory.connect(_on_victory)
	menu_layer.play_pressed.connect(_start_game)

	menu_layer.visible = true
	hud_layer.visible = false
	end_layer.visible = false

	# Main sigue procesando aunque el juego esté en pausa; solo los
	# niveles se detienen.
	process_mode = Node.PROCESS_MODE_ALWAYS
	level_holder.process_mode = Node.PROCESS_MODE_PAUSABLE
	pause_layer.visible = false
	menu_layer.focus_play_button()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and hud_layer.visible:
		get_tree().paused = not get_tree().paused
		pause_layer.visible = get_tree().paused


func _start_game() -> void:
	end_focus_token += 1
	_clear_ui_focus()
	get_tree().paused = false
	pause_layer.visible = false
	GameManager.start_new_game()
	menu_layer.visible = false
	end_layer.visible = false
	hud_layer.visible = true


func _on_level_changed(n: int) -> void:
	# Diferido: este cambio se dispara desde un callback de física
	# (el jugador toca la salida) y no se pueden crear cuerpos físicos
	# nuevos en ese momento.
	_load_level.call_deferred(n)


func _load_level(n: int) -> void:
	if current_level_node:
		current_level_node.queue_free()
	if n < 1 or n > level_scenes.size() or level_scenes[n - 1] == null:
		push_error("Falta la escena del nivel %d en Main." % n)
		return
	var level_scene: PackedScene = level_scenes[n - 1]
	current_level_node = level_scene.instantiate()
	level_holder.add_child(current_level_node)


func _on_game_over() -> void:
	_show_end_screen("GAME OVER")


func _on_victory() -> void:
	_show_end_screen("¡GANASTE! Laboratorio liberado")


func _show_end_screen(title: String) -> void:
	end_focus_token += 1
	get_tree().paused = false
	pause_layer.visible = false
	hud_layer.visible = false
	end_layer.visible = true
	end_title.text = title
	end_title_shadow.text = title
	end_score.text = "Puntuación final: %d" % GameManager.score
	_focus_end_button_when_input_released(end_focus_token)
	if current_level_node:
		current_level_node.queue_free()
		current_level_node = null


func _focus_end_button_when_input_released(token: int) -> void:
	# Espacio activa ui_accept y también es la tecla de salto.
	while Input.is_action_pressed("ui_accept"):
		await get_tree().process_frame
	await get_tree().process_frame
	if token == end_focus_token and end_layer.visible:
		retry_button.grab_focus()


func _on_retry_button_pressed() -> void:
	_start_game()


func _on_menu_button_pressed() -> void:
	end_focus_token += 1
	end_layer.visible = false
	menu_layer.visible = true
	menu_layer.focus_play_button()


func _clear_ui_focus() -> void:
	var focused_control := get_viewport().gui_get_focus_owner()
	if focused_control:
		focused_control.release_focus()
