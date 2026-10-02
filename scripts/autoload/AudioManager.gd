extends Node
## Autoload (Singleton) centralizado para audio. Todos los sonidos
## fueron generados/sintetizados para este proyecto (sin depender de
## archivos externos con licencias dudosas) y viven en
## res://assets/audio/. Si más adelante quieres reemplazar alguno
## por tu propia grabación, solo cambia el archivo .wav en esa
## carpeta (mismo nombre) o reasigna el preload correspondiente
## abajo.

const AUDIO_DIR := "res://assets/audio/"

var music_player: AudioStreamPlayer
var sfx_dash: AudioStreamPlayer
var sfx_coin: AudioStreamPlayer
var sfx_hit: AudioStreamPlayer
var sfx_shoot: AudioStreamPlayer
var sfx_victory: AudioStreamPlayer
var sfx_gameover: AudioStreamPlayer


func _ready() -> void:
	music_player = _make_player("MusicPlayer")
	sfx_dash = _make_player("SFXDash")
	sfx_coin = _make_player("SFXCoin")
	sfx_hit = _make_player("SFXHit")
	sfx_shoot = _make_player("SFXShoot")
	sfx_victory = _make_player("SFXVictory")
	sfx_gameover = _make_player("SFXGameOver")

	# Se cargan con load() (no preload) para que el proyecto abra sin
	# errores la primera vez, cuando Godot aún está importando los .wav.
	music_player.stream = _load_audio("music_background.wav")
	if music_player.stream is AudioStreamWAV:
		(music_player.stream as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD
	music_player.volume_db = -10.0

	sfx_coin.stream = _load_audio("sfx_coin.wav")
	sfx_hit.stream = _load_audio("sfx_hit.wav")
	sfx_dash.stream = _load_audio("sfx_dash.wav")
	sfx_shoot.stream = _load_audio("sfx_shoot.wav")
	sfx_victory.stream = _load_audio("sfx_victory.wav")
	sfx_gameover.stream = _load_audio("sfx_gameover.wav")

	# TODO: Si quieres usar tus propios archivos de audio, reemplaza
	# los .wav dentro de res://assets/audio/ (mismo nombre de
	# archivo) o cambia los nombres en _ready().


func _load_audio(file_name: String) -> AudioStream:
	var path := AUDIO_DIR + file_name
	if ResourceLoader.exists(path):
		return load(path) as AudioStream
	push_warning("Audio no encontrado: " + path)
	return null


func _make_player(node_name: String) -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	p.name = node_name
	add_child(p)
	return p


func play_music() -> void:
	if music_player.stream and not music_player.playing:
		music_player.play()


func stop_music() -> void:
	music_player.stop()


func play_sfx(sfx_name: String) -> void:
	match sfx_name:
		"dash":
			_play(sfx_dash)
		"coin", "item":
			_play(sfx_coin)
		"hit", "damage":
			_play(sfx_hit)
		"shoot":
			_play(sfx_shoot)
		"victory":
			_play(sfx_victory)
		"gameover", "game_over":
			_play(sfx_gameover)


func _play(player: AudioStreamPlayer) -> void:
	if player.stream:
		player.play()
