extends Area2D
## Enemigo que patrulla en línea recta (horizontal o vertical) y quita
## una vida al tocar al jugador. Usa personajes reales del pack de
## assets; cada instancia puede cambiar idle_tex/run_tex, la vida
## (health), la velocidad y el eje de patrulla desde el inspector.

@export var patrol_distance := 60.0
@export var speed := 40.0
@export var health := 1
@export var score_value := 15
@export var vertical := false
@export var idle_tex: Texture2D
@export var run_tex: Texture2D

const SpriteBuilder := preload("res://scripts/util/SpriteBuilder.gd")
const DEFAULT_IDLE := preload("res://assets/characters/Bob_idle_anim_16x16.png")
const DEFAULT_RUN := preload("res://assets/characters/Bob_run_16x16.png")

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var _start := 0.0
var _dir := 1.0


func _ready() -> void:
	add_to_group("enemy")
	_start = position.y if vertical else position.x

	var idle: Texture2D = idle_tex if idle_tex else DEFAULT_IDLE
	var run: Texture2D = run_tex if run_tex else DEFAULT_RUN
	sprite.sprite_frames = SpriteBuilder.build_four_dir_frames(idle, run)
	sprite.play("run_down" if vertical else "run_right")


func _physics_process(delta: float) -> void:
	if vertical:
		position.y += _dir * speed * delta
		var y := position.y
		if y > _start + patrol_distance:
			_dir = -1.0
		elif y < _start - patrol_distance:
			_dir = 1.0
	else:
		position.x += _dir * speed * delta
		var x := position.x
		if x > _start + patrol_distance:
			_dir = -1.0
		elif x < _start - patrol_distance:
			_dir = 1.0

	# Daño por contacto continuo: si el jugador sigue tocando al
	# enemigo cuando termina su invulnerabilidad, vuelve a recibir daño.
	for body in get_overlapping_bodies():
		if body.is_in_group("player") and body.has_method("take_damage"):
			body.take_damage(1)

	var anim := ""
	if vertical:
		anim = "run_up" if _dir < 0.0 else "run_down"
	else:
		anim = "run_left" if _dir < 0.0 else "run_right"
	if sprite.animation != anim:
		sprite.play(anim)


func take_damage(amount: int = 1) -> void:
	health -= amount
	if health <= 0:
		GameManager.add_score(score_value)
		queue_free()
	else:
		sprite.modulate = Color(1.0, 0.5, 0.5)
		var t := create_tween()
		t.tween_property(sprite, "modulate", Color(1, 1, 1), 0.25)
