extends Area2D
## Proyectil simple: viaja en línea recta, destruye enemigos al
## tocarlos y desaparece al chocar contra una pared o tras su tiempo
## de vida.

@export var speed := 240.0
var direction := Vector2.DOWN
var lifetime := 1.2


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)
	rotation = direction.angle()


func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy") and area.has_method("take_damage"):
		area.take_damage(1)
		queue_free()


func _on_body_entered(_body: Node) -> void:
	# Cualquier cuerpo físico (paredes) detiene el proyectil.
	queue_free()
