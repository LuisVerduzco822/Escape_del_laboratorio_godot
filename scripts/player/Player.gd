extends CharacterBody2D
## Jugador estilo plataformas (Mario-like): movimiento horizontal,
## gravedad y salto. Si pisa una bola de fuego desde arriba la
## elimina y rebota; si la toca de lado, pierde una vida.

const INVULN_TIME := 1.0

@export var speed := 140.0
@export var gravity := 1200.0
@export var fall_gravity_multiplier := 2.0
@export var jump_velocity := -400.0
@export var bounce_velocity := -100.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var facing := "right"
var dead := false
var invuln_timer := 0.0


func _ready() -> void:
	add_to_group("player")
	sprite.play("idle_right")


func _physics_process(delta: float) -> void:
	if dead:
		return
	if invuln_timer > 0.0:
		invuln_timer = maxf(invuln_timer - delta, 0.0)
		# Parpadeo visual durante la protección tras recibir daño.
		sprite.visible = invuln_timer == 0.0 or int(invuln_timer * 12.0) % 2 == 0

	var current_gravity := gravity * (fall_gravity_multiplier if velocity.y > 0.0 else 1.0)
	velocity.y += current_gravity * delta

	var dir := Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	velocity.x = dir * speed

	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = jump_velocity
		AudioManager.play_sfx("jump")

	move_and_slide()

	if dir != 0.0:
		facing = "right" if dir > 0.0 else "left"

	_update_animation(dir != 0.0)


func _update_animation(moving: bool) -> void:
	var anim: String
	if not is_on_floor():
		anim = "idle_" + facing
	elif moving:
		anim = "run_" + facing
	else:
		anim = "idle_" + facing
	if sprite.animation != anim:
		sprite.play(anim)


## Llamado por el enemigo cuando el jugador lo pisa desde arriba.
func bounce() -> void:
	velocity.y = bounce_velocity


## Llamado por la bola de fuego al tocar al jugador de lado.
func take_damage() -> void:
	if dead or invuln_timer > 0.0:
		return
	GameManager.player_hit()
	if GameManager.lives == 0:
		dead = true
		velocity = Vector2.ZERO
		sprite.visible = true
	else:
		invuln_timer = INVULN_TIME
