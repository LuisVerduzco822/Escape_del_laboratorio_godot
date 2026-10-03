extends CanvasLayer
## Portada: solo el título del juego y el botón "Empezar".

signal play_pressed

@onready var play_button: Button = $CenterContainer/VBoxContainer/PlayButton


func _ready() -> void:
	play_button.mouse_entered.connect(_on_button_hover.bind(play_button))
	play_button.mouse_exited.connect(_on_button_unhover.bind(play_button))


func focus_play_button() -> void:
	play_button.grab_focus()


func _on_button_hover(b: Button) -> void:
	var t := create_tween()
	t.tween_property(b, "modulate", Color(1.0, 0.85, 0.25), 0.15)


func _on_button_unhover(b: Button) -> void:
	var t := create_tween()
	t.tween_property(b, "modulate", Color(1, 1, 1), 0.15)


func _on_play_button_pressed() -> void:
	play_pressed.emit()
