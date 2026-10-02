extends CanvasLayer
## HUD durante la partida: vidas, puntos, nivel actual e items
## restantes. Se actualiza únicamente escuchando señales de
## GameManager (nunca lee/escribe estado directamente).

@onready var lives_label: Label = $MarginContainer/HBoxContainer/LivesLabel
@onready var score_label: Label = $MarginContainer/HBoxContainer/ScoreLabel
@onready var level_label: Label = $MarginContainer/HBoxContainer/LevelLabel
@onready var items_label: Label = $MarginContainer/HBoxContainer/ItemsLabel


func _ready() -> void:
	GameManager.lives_changed.connect(_on_lives_changed)
	GameManager.score_changed.connect(_on_score_changed)
	GameManager.level_changed.connect(_on_level_changed)
	GameManager.item_collected.connect(_on_items_changed)
	_on_lives_changed(GameManager.lives)
	_on_score_changed(GameManager.score)
	_on_level_changed(GameManager.current_level)
	_on_items_changed(GameManager.items_remaining)


func _on_lives_changed(v: int) -> void:
	lives_label.text = "Vidas: %d" % v


func _on_score_changed(v: int) -> void:
	score_label.text = "Puntos: %d" % v


func _on_level_changed(v: int) -> void:
	level_label.text = "Nivel: %d/3" % v


func _on_items_changed(v: int) -> void:
	items_label.text = "Estrellas: %d" % v
