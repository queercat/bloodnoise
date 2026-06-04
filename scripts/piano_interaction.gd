extends Interactable

func show_interaction():
	GameManager.ui.show_interact_text("Press E to crank dat shiiittt")

func hide_interaction():
	GameManager.ui.hide_interact_text()

func do_interaction() -> bool: 
	get_parent().crank_dat()
	return true
