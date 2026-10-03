extends CanvasLayer
## HUD durante la partida: vidas, puntos, nivel actual e items
## restantes. Se actualiza únicamente escuchando señales de
## GameManager (nunca lee/escribe estado directamente).

@onready var lives_sprite: AnimatedSprite2D = $MarginContainer/HBoxContainer/Bars/LivesRow/LivesSprite
@onready var lives_label: Label = $MarginContainer/HBoxContainer/Bars/LivesRow/LivesLabel
@onready var ammo_sprite: Sprite2D = $MarginContainer/HBoxContainer/Bars/AmmoRow/AmmoSprite
@onready var ammo_label: Label = $MarginContainer/HBoxContainer/Bars/AmmoRow/AmmoLabel
@onready var score_label: Label = $MarginContainer/HBoxContainer/Stats/ScoreLabel
@onready var level_label: Label = $MarginContainer/HBoxContainer/Stats/LevelLabel
@onready var items_label: Label = $MarginContainer/HBoxContainer/Stats/ItemsLabel


func _ready() -> void:
	ammo_sprite.texture = ammo_sprite.texture.duplicate()
	GameManager.lives_changed.connect(_on_lives_changed)
	GameManager.ammo_changed.connect(_on_ammo_changed)
	GameManager.score_changed.connect(_on_score_changed)
	GameManager.level_changed.connect(_on_level_changed)
	GameManager.item_collected.connect(_on_items_changed)
	_on_lives_changed(GameManager.lives)
	_on_ammo_changed(GameManager.ammo, GameManager.reload_timer > 0.0)
	_on_score_changed(GameManager.score)
	_on_level_changed(GameManager.current_level)
	_on_items_changed(GameManager.items_remaining)


func _on_lives_changed(v: int) -> void:
	lives_label.text = "%d/%d" % [maxi(v, 0), GameManager.START_LIVES]
	match v:
		4: lives_sprite.play("green")
		3: lives_sprite.play("blue")
		2: lives_sprite.play("yellow")
		1: lives_sprite.play("red")
		_: lives_sprite.play("empty")


func _on_ammo_changed(remaining: int, reloading: bool) -> void:
	var atlas := ammo_sprite.texture as AtlasTexture
	atlas.region = Rect2(remaining * 48, 0, 48, 16)
	ammo_label.text = "RECARGA" if reloading else "%d/%d" % [remaining, GameManager.MAX_AMMO]


func _on_score_changed(v: int) -> void:
	score_label.text = "Puntos: %d" % v


func _on_level_changed(v: int) -> void:
	level_label.text = "Nivel: %d/3" % v


func _on_items_changed(v: int) -> void:
	items_label.text = "Estrellas: %d" % v
