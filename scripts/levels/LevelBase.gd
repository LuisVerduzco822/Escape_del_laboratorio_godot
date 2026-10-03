extends Node2D
## Script compartido por Level1/Level2/Level3 (plataformas estilo
## Mario). Cada nivel trae su propio fondo y un nodo "Coins" con las
## monedas a recolectar; este script arranca el spawner de bolas de
## fuego, cuenta las monedas y muestra el cartel con el nombre del
## nivel al empezar.

@export var level_title := "NIVEL 1 - FACIL"
@export var spawn_interval := 3.0
@export var fireball_speed := 120.0
@export var burst_chance := 0.0
@export var burst_count := 1
@export var burst_spacing := 40.0
@export var fireball_scene: PackedScene

@onready var spawn_timer: Timer = $SpawnTimer
@onready var spawn_point: Marker2D = $FireballSpawn
@onready var coins_node: Node2D = $Coins
@onready var title_layer: CanvasLayer = $TitleLayer
@onready var title_label: Label = $TitleLayer/TitleLabel


func _ready() -> void:
	var total := coins_node.get_child_count()
	GameManager.register_level_coins(total)
	GameManager.coins_changed.connect(_on_coins_changed)

	spawn_timer.wait_time = spawn_interval
	spawn_timer.one_shot = false
	spawn_timer.timeout.connect(_on_spawn_timeout)
	spawn_timer.start()

	AudioManager.play_music()
	title_label.text = level_title
	_show_title()


func _on_coins_changed(current: int) -> void:
	if current >= GameManager.coins_target:
		GameManager.level_complete()


func _on_spawn_timeout() -> void:
	_spawn_fireball()
	if randf() < burst_chance:
		for i in burst_count:
			_spawn_fireball(Vector2(burst_spacing * (i + 1), 0.0))


func _spawn_fireball(offset := Vector2.ZERO) -> void:
	if fireball_scene == null:
		push_error("Falta fireball_scene en %s." % name)
		return
	var fb := fireball_scene.instantiate()
	fb.speed = fireball_speed
	fb.position = spawn_point.position + offset
	add_child(fb)


func _show_title() -> void:
	var t := create_tween()
	t.tween_interval(1.6)
	t.tween_property(title_label, "modulate:a", 0.0, 0.6)
	t.tween_callback(title_layer.queue_free)
