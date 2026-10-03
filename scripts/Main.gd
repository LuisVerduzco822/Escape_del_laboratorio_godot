extends Node2D
## Escena raíz del juego. Gestiona qué se muestra en cada momento:
## el menú principal, el HUD + nivel en curso, o la pantalla final
## (game over / victoria). Reacciona a las señales de GameManager;
## nunca decide la lógica de juego por sí misma.

@export var level_scenes: Array[PackedScene]
@export var pixel_font: Font

@onready var level_holder: Node2D = $LevelHolder
@onready var menu_layer: CanvasLayer = $MenuLayer
@onready var hud_layer: CanvasLayer = $HUDLayer
@onready var end_layer: CanvasLayer = $EndLayer
@onready var end_title: Label = $EndLayer/CenterContainer/VBoxContainer/TitleStack/TitleLabel
@onready var end_title_shadow: Label = $EndLayer/CenterContainer/VBoxContainer/TitleStack/TitleShadow
@onready var end_score: Label = $EndLayer/CenterContainer/VBoxContainer/ScoreSummaryLabel
@onready var retry_button: Button = $EndLayer/CenterContainer/VBoxContainer/RetryButton
@onready var menu_button: Button = $EndLayer/CenterContainer/VBoxContainer/MenuButton

var current_level_node: Node = null
var pause_label: Label = null
var death_sequence_active := false
var end_focus_token := 0


func _ready() -> void:
	_apply_pixel_font()
	GameManager.level_changed.connect(_on_level_changed)
	GameManager.game_over.connect(_on_game_over)
	GameManager.victory.connect(_on_victory)
	menu_layer.play_pressed.connect(_start_game)
	menu_layer.quit_pressed.connect(func(): get_tree().quit())
	for button in [retry_button, menu_button]:
		var other: Button = menu_button if button == retry_button else retry_button
		button.focus_neighbor_top = button.get_path_to(other)
		button.focus_neighbor_bottom = button.get_path_to(other)
		button.focus_neighbor_left = button.get_path_to(other)
		button.focus_neighbor_right = button.get_path_to(other)

	menu_layer.visible = true
	hud_layer.visible = false
	end_layer.visible = false

	# Main sigue procesando aunque el juego esté en pausa; solo los
	# niveles se detienen.
	process_mode = Node.PROCESS_MODE_ALWAYS
	level_holder.process_mode = Node.PROCESS_MODE_PAUSABLE
	_build_pause_label()


## Aplica la fuente pixel (Press Start 2P) como fuente por defecto de
## toda la interfaz. Se hace por código para que el proyecto abra sin
## errores la primera vez que Godot importa la fuente.
func _apply_pixel_font() -> void:
	if pixel_font:
		var theme := ThemeDB.get_default_theme()
		theme.default_font = pixel_font
		theme.default_font_size = 8


func _build_pause_label() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 10
	add_child(layer)
	pause_label = Label.new()
	pause_label.text = "PAUSA\nESC para continuar"
	pause_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pause_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	pause_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pause_label.add_theme_font_size_override("font_size", 12)
	pause_label.add_theme_color_override("font_color", Color(1, 1, 1))
	pause_label.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	pause_label.add_theme_constant_override("outline_size", 5)
	pause_label.visible = false
	layer.add_child(pause_label)


func _unhandled_input(event: InputEvent) -> void:
	if not death_sequence_active and event.is_action_pressed("ui_cancel") and hud_layer.visible:
		get_tree().paused = not get_tree().paused
		pause_label.visible = get_tree().paused


func _start_game() -> void:
	end_focus_token += 1
	death_sequence_active = false
	get_tree().paused = false
	pause_label.visible = false
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
		push_error("Falta configurar la escena del nivel %d en Main.tscn" % n)
		return
	var level_scene: PackedScene = level_scenes[n - 1]
	current_level_node = level_scene.instantiate()
	level_holder.add_child(current_level_node)


func _on_game_over() -> void:
	if death_sequence_active:
		return
	death_sequence_active = true
	pause_label.visible = false
	get_tree().paused = true
	AudioManager.stop_music()
	AudioManager.play_sfx("gameover")
	if AudioManager.sfx_gameover.stream:
		await AudioManager.sfx_gameover.finished
	else:
		await get_tree().process_frame
	_show_end_screen("GAME OVER")


func _on_victory() -> void:
	_show_end_screen("¡GANASTE! Laboratorio liberado")


func _show_end_screen(title: String) -> void:
	death_sequence_active = false
	end_focus_token += 1
	get_tree().paused = false
	pause_label.visible = false
	hud_layer.visible = false
	retry_button.focus_mode = Control.FOCUS_NONE
	menu_button.focus_mode = Control.FOCUS_NONE
	end_layer.visible = true
	_enable_end_buttons_when_input_released(end_focus_token)
	end_title.text = title
	end_title_shadow.text = title
	end_score.text = "Puntuación final: %d" % GameManager.score
	if current_level_node:
		current_level_node.queue_free()
		current_level_node = null


func _enable_end_buttons_when_input_released(token: int) -> void:
	# Espacio también activa ui_accept. No enfocar botones hasta que se
	# suelte la tecla usada durante el juego y pase un fotograma limpio.
	while Input.is_action_pressed("ui_accept"):
		await get_tree().process_frame
	await get_tree().process_frame
	if token != end_focus_token or not end_layer.visible:
		return
	retry_button.focus_mode = Control.FOCUS_ALL
	menu_button.focus_mode = Control.FOCUS_ALL
	retry_button.grab_focus()


func _on_retry_button_pressed() -> void:
	_start_game()


func _on_menu_button_pressed() -> void:
	end_focus_token += 1
	end_layer.visible = false
	menu_layer.visible = true
	menu_layer.select_play_button.call_deferred()
