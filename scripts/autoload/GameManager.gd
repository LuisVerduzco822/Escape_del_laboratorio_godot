extends Node
## Autoload (Singleton) que guarda el estado global de la partida:
## vidas, puntos, nivel actual e items restantes del nivel en curso.
## Se comunica con el resto del juego exclusivamente mediante señales.

signal score_changed(new_score: int)
signal lives_changed(new_lives: int)
signal level_changed(new_level: int)
signal item_collected(remaining: int)
signal game_over
signal victory

const MAX_LEVEL := 3
const START_LIVES := 3

var score := 0
var lives := START_LIVES
var current_level := 1
var items_remaining := 0


func _ready() -> void:
	_setup_input_actions()


## Crea en tiempo de ejecución las acciones de input personalizadas
## (dash y shoot) para no depender de configurarlas a mano en el
## editor: así el proyecto funciona igual apenas se abre.
func _setup_input_actions() -> void:
	_ensure_action_key("dash", KEY_SPACE)
	_ensure_action_key("dash", KEY_SHIFT)
	_ensure_action_key("shoot", KEY_J)
	_ensure_action_mouse("shoot", MOUSE_BUTTON_LEFT)


func _ensure_action_key(action_name: String, keycode: int) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	var ev := InputEventKey.new()
	ev.physical_keycode = keycode
	InputMap.action_add_event(action_name, ev)


func _ensure_action_mouse(action_name: String, button_index: int) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	var ev := InputEventMouseButton.new()
	ev.button_index = button_index
	InputMap.action_add_event(action_name, ev)


func start_new_game() -> void:
	score = 0
	lives = START_LIVES
	current_level = 1
	items_remaining = 0
	score_changed.emit(score)
	lives_changed.emit(lives)
	level_changed.emit(current_level)


func add_score(amount: int) -> void:
	score += amount
	score_changed.emit(score)


## Llamado por cada nivel al arrancar, para que el HUD sepa cuántos
## items faltan por recolectar.
func register_level_items(count: int) -> void:
	items_remaining = count
	item_collected.emit(items_remaining)


func collect_item(value: int = 10) -> void:
	items_remaining = max(items_remaining - 1, 0)
	add_score(value)
	item_collected.emit(items_remaining)
	AudioManager.play_sfx("coin")


func player_hit(damage: int = 1) -> void:
	lives -= damage
	lives_changed.emit(lives)
	AudioManager.play_sfx("hit")
	if lives <= 0:
		AudioManager.stop_music()
		AudioManager.play_sfx("gameover")
		game_over.emit()


func level_complete() -> void:
	if current_level >= MAX_LEVEL:
		AudioManager.stop_music()
		AudioManager.play_sfx("victory")
		victory.emit()
	else:
		current_level += 1
		level_changed.emit(current_level)
