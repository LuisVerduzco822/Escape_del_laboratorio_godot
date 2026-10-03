extends Area2D
## Moneda flotante recolectable. Al tocar al jugador (body_entered)
## suma al contador de monedas y se elimina de la escena.

@export var value := 1

var _animation_step := 0


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	var animation_timer := Timer.new()
	animation_timer.wait_time = 0.4
	animation_timer.timeout.connect(_advance_animation)
	add_child(animation_timer)
	animation_timer.start()


func _advance_animation() -> void:
	_animation_step = (_animation_step + 1) % 4
	var offsets := [0.0, -4.0, 0.0, 4.0]
	$Icon.position.y = offsets[_animation_step]


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		GameManager.collect_coin(value)
		queue_free()
