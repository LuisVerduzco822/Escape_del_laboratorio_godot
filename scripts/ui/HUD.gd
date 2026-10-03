extends CanvasLayer
## HUD durante la partida: vidas, monedas, nivel y puntos. Se actualiza únicamente
## escuchando señales de GameManager.

@onready var lives_sprite: AnimatedSprite2D = $MarginContainer/HBoxContainer/LivesRow/LivesSprite
@onready var lives_label: Label = $MarginContainer/HBoxContainer/LivesRow/LivesLabel
@onready var coins_label: Label = $MarginContainer/HBoxContainer/CoinsLabel
@onready var level_label: Label = $MarginContainer/HBoxContainer/LevelLabel
@onready var score_label: Label = $MarginContainer/HBoxContainer/ScoreLabel


func _ready() -> void:
	GameManager.lives_changed.connect(_on_lives_changed)
	GameManager.coins_changed.connect(_on_coins_changed)
	GameManager.level_changed.connect(_on_level_changed)
	GameManager.score_changed.connect(_on_score_changed)
	_on_coins_changed(GameManager.coins)
	_on_lives_changed(GameManager.lives)
	_on_level_changed(GameManager.current_level)
	_on_score_changed(GameManager.score)


func _on_coins_changed(v: int) -> void:
	coins_label.text = "MONEDAS: %02d" % v


func _on_lives_changed(v: int) -> void:
	lives_label.text = "%d/%d" % [v, GameManager.START_LIVES]
	match v:
		4: lives_sprite.play("green")
		3: lives_sprite.play("blue")
		2: lives_sprite.play("yellow")
		1: lives_sprite.play("red")
		_: lives_sprite.play("empty")


func _on_level_changed(v: int) -> void:
	level_label.text = "NIVEL %d/%d" % [v, GameManager.max_level]


func _on_score_changed(v: int) -> void:
	score_label.text = "PUNTOS: %d" % v
