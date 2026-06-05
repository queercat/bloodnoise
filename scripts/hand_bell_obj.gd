extends Node3D


var counter = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# I want it to be gently floating up and down but i couldnt figure it out tn oops, also TODO hook up interaction for intro
	#counter += delta
	#counter = fmod((counter + delta), (2 * PI))
	#global_position.y = global_position.y + sin(counter)
	#print(global_position.y)
	pass
