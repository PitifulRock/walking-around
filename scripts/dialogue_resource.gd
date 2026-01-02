class_name Dialogue
extends Resource

@export_multiline var dialogue_lines := ".n":
	set(value):
		dialogue_lines = value
		spliced_lines.clear()
		var cut_lines = Array(dialogue_lines.split(".n"))
		for i in cut_lines: 
			spliced_lines.append(i.replace(".n", "").remove_chars("\n"))

var spliced_lines : Array
