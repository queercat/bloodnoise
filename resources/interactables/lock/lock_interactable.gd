extends Interactable

func show_interaction():
	GameManager.ui.show_interact_text(interaction_text)

func hide_interaction():
	GameManager.ui.hide_interact_text()

func do_interaction():
	get_parent().open()
	return true
