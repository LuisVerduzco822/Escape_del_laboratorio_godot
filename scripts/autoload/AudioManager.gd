extends Node
## Los reproductores y sus archivos se editan en AudioManager.tscn.

@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var sfx_jump: AudioStreamPlayer = $SFXJump
@onready var sfx_coin: AudioStreamPlayer = $SFXCoin
@onready var sfx_hit: AudioStreamPlayer = $SFXHit
@onready var sfx_victory: AudioStreamPlayer = $SFXVictory
@onready var sfx_gameover: AudioStreamPlayer = $SFXGameOver


func play_music() -> void:
	if music_player.stream and not music_player.playing:
		music_player.play()


func stop_music() -> void:
	music_player.stop()


func play_sfx(sfx_name: String) -> void:
	match sfx_name:
		"jump":
			_play(sfx_jump)
		"coin":
			_play(sfx_coin)
		"hit":
			_play(sfx_hit)
		"victory":
			_play(sfx_victory)
		"gameover":
			_play(sfx_gameover)


func _play(player: AudioStreamPlayer) -> void:
	if player.stream:
		player.play()
