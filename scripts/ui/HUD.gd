extends CanvasLayer
## HUD durante la partida: contador de monedas (esquina superior,
## formato "MONEDAS: 00") y nivel actual. Se actualiza únicamente
## escuchando señales de GameManager.

@onready var coins_label: Label = $MarginContainer/HBoxContainer/CoinsLabel
@onready var level_label: Label = $MarginContainer/HBoxContainer/LevelLabel
@onready var score_label: Label = $MarginContainer/HBoxContainer/ScoreLabel


func _ready() -> void:
	GameManager.coins_changed.connect(_on_coins_changed)
	GameManager.level_changed.connect(_on_level_changed)
	GameManager.score_changed.connect(_on_score_changed)
	_on_coins_changed(GameManager.coins)
	_on_level_changed(GameManager.current_level)
	_on_score_changed(GameManager.score)


func _on_coins_changed(v: int) -> void:
	coins_label.text = "MONEDAS: %02d" % v


func _on_level_changed(v: int) -> void:
	level_label.text = "NIVEL %d/%d" % [v, GameManager.max_level]


func _on_score_changed(v: int) -> void:
	score_label.text = "PUNTOS: %d" % v
