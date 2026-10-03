extends CanvasLayer
## Portada / Menú principal. Emite señales que Main.gd escucha para
## arrancar la partida o salir del juego.

signal play_pressed
signal quit_pressed

@onready var play_button: Button = $CenterContainer/VBoxContainer/PlayButton
@onready var credits_button: Button = $CenterContainer/VBoxContainer/CreditsButton
@onready var quit_button: Button = $CenterContainer/VBoxContainer/QuitButton
@onready var credits_label: Label = $CreditsLabel
@onready var title_label: Label = $CenterContainer/VBoxContainer/TitleStack/TitleLabel


func _ready() -> void:
	credits_label.visible = false
	var buttons := [play_button, credits_button, quit_button]
	for i in buttons.size():
		var button: Button = buttons[i]
		button.focus_neighbor_top = button.get_path_to(buttons[(i - 1 + buttons.size()) % buttons.size()])
		button.focus_neighbor_bottom = button.get_path_to(buttons[(i + 1) % buttons.size()])
		button.focus_neighbor_left = button.focus_neighbor_top
		button.focus_neighbor_right = button.focus_neighbor_bottom
	_pulse_title()
	select_play_button.call_deferred()


func select_play_button() -> void:
	play_button.grab_focus()


func _pulse_title() -> void:
	var t := create_tween()
	t.set_loops()
	t.tween_property(title_label, "modulate", Color(1, 1, 0.55), 0.8).set_trans(Tween.TRANS_SINE)
	t.tween_property(title_label, "modulate", Color(0.42, 0.92, 1), 0.8).set_trans(Tween.TRANS_SINE)


func _on_play_button_pressed() -> void:
	play_pressed.emit()


func _on_quit_button_pressed() -> void:
	quit_pressed.emit()


func _on_credits_button_pressed() -> void:
	credits_label.visible = not credits_label.visible
