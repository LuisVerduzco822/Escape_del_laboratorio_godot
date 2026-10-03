extends Node
## Autoload (Singleton) que guarda el estado global de la partida:
## vidas, puntos, nivel actual e items restantes del nivel en curso.
## Se comunica con el resto del juego exclusivamente mediante señales.

signal score_changed(new_score: int)
signal lives_changed(new_lives: int)
signal level_changed(new_level: int)
signal item_collected(remaining: int)
signal ammo_changed(remaining: int, reloading: bool)
signal game_over
signal victory

const MAX_LEVEL := 3
const START_LIVES := 4
const MAX_AMMO := 8
const RELOAD_TIME := 1.5

var score := 0
var lives := START_LIVES
var current_level := 1
var items_remaining := 0
var ammo := MAX_AMMO
var reload_timer := 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	_setup_input_actions()


func _process(delta: float) -> void:
	if reload_timer <= 0.0:
		return
	reload_timer = maxf(reload_timer - delta, 0.0)
	if reload_timer == 0.0:
		_reset_ammo()


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
	_reset_ammo()
	score_changed.emit(score)
	lives_changed.emit(lives)
	level_changed.emit(current_level)


func consume_shot() -> bool:
	if ammo <= 0 or reload_timer > 0.0:
		return false
	ammo -= 1
	if ammo == 0:
		reload_timer = RELOAD_TIME
	ammo_changed.emit(ammo, reload_timer > 0.0)
	return true


func _reset_ammo() -> void:
	ammo = MAX_AMMO
	reload_timer = 0.0
	ammo_changed.emit(ammo, false)


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
	if lives <= 0:
		return
	lives = maxi(lives - damage, 0)
	lives_changed.emit(lives)
	if lives <= 0:
		game_over.emit()
	else:
		AudioManager.play_sfx("hit")


func level_complete() -> void:
	if current_level >= MAX_LEVEL:
		AudioManager.stop_music()
		AudioManager.play_sfx("victory")
		victory.emit()
	else:
		current_level += 1
		_reset_ammo()
		level_changed.emit(current_level)
