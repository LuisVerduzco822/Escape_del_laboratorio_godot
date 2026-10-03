extends Node
## Autoload (Singleton) con el estado global de la partida: monedas,
## puntos, nivel actual y las cuatro vidas del jugador.

signal score_changed(new_score: int)
signal lives_changed(new_lives: int)
signal coins_changed(new_coins: int)
signal level_changed(new_level: int)
signal coins_target_changed(target: int)
signal game_over
signal victory

const START_LIVES := 4

var max_level := 3

var score := 0
var coins := 0
var coins_target := 0
var current_level := 1
var lives := START_LIVES


func start_new_game() -> void:
	score = 0
	coins = 0
	current_level = 1
	lives = START_LIVES
	score_changed.emit(score)
	lives_changed.emit(lives)
	coins_changed.emit(coins)
	level_changed.emit(current_level)


func add_score(amount: int) -> void:
	score += amount
	score_changed.emit(score)


## Llamado por cada nivel al arrancar, para que el HUD sepa cuántas
## monedas hay que recolectar para que se abra la salida.
func register_level_coins(target: int) -> void:
	coins = 0
	coins_target = target
	coins_changed.emit(coins)
	coins_target_changed.emit(target)


func collect_coin(value: int = 1) -> void:
	coins += 1
	add_score(value * 10)
	coins_changed.emit(coins)
	AudioManager.play_sfx("coin")


func player_died() -> void:
	AudioManager.stop_music()
	AudioManager.play_sfx("gameover")
	game_over.emit()


func player_hit() -> void:
	if lives <= 0:
		return
	lives -= 1
	lives_changed.emit(lives)
	if lives == 0:
		player_died()
	else:
		AudioManager.play_sfx("hit")


func level_complete() -> void:
	if current_level >= max_level:
		AudioManager.stop_music()
		AudioManager.play_sfx("victory")
		victory.emit()
	else:
		current_level += 1
		level_changed.emit(current_level)
