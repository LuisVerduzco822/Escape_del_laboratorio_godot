extends Node
## Las pistas y sus volúmenes se editan en scenes/autoload/AudioManager.tscn.

@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var sfx_dash: AudioStreamPlayer = $SFXDash
@onready var sfx_coin: AudioStreamPlayer = $SFXCoin
@onready var sfx_hit: AudioStreamPlayer = $SFXHit
@onready var sfx_shoot: AudioStreamPlayer = $SFXShoot
@onready var sfx_victory: AudioStreamPlayer = $SFXVictory
@onready var sfx_gameover: AudioStreamPlayer = $SFXGameOver


func _ready() -> void:
	if music_player.stream is AudioStreamWAV:
		var music_stream := music_player.stream as AudioStreamWAV
		music_stream.loop_begin = 0
		music_stream.loop_end = int(music_stream.get_length() * music_stream.mix_rate)
		music_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	elif music_player.stream is AudioStreamMP3:
		(music_player.stream as AudioStreamMP3).loop = true


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
