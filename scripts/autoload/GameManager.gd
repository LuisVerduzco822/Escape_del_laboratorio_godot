extends Node
## Autoload (Singleton) con el estado global de la partida: monedas,
## puntos y nivel actual. El jugador tiene una sola vida: cualquier
## golpe lateral de una bola de fuego termina la partida.

signal score_changed(new_score: int)
signal coins_changed(new_coins: int)
signal level_changed(new_level: int)
signal coins_target_changed(target: int)
signal game_over
signal victory

var max_level := 3

var score := 0
var coins := 0
var coins_target := 0
var current_level := 1


func start_new_game() -> void:
	score = 0
	coins = 0
	current_level = 1
	score_changed.emit(score)
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


func level_complete() -> void:
	if current_level >= max_level:
		AudioManager.stop_music()
		AudioManager.play_sfx("victory")
		victory.emit()
	else:
		current_level += 1
		level_changed.emit(current_level)
