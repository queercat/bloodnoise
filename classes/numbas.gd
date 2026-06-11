extends Node3D

@export var number: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	GameManager.SetWorldPasscode.connect(handle_set_passcode)

func handle_set_passcode(passcode):
	var index = -1
	
	match name:
		"Top":
			index = 0
		"Middle":
			index = 1
		"Bottom":
			index = 2
	
	var numbers = str("%03d" % passcode)
	var n = numbers[index]
	get_node("%s" % n).show()
	
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
