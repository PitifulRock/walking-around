class_name DialogueNode
extends Interactable

const VOICE_EXCLUDE = " ,.;:!?-)(<>"
const MAX_LINE_SIZE = 34

@export var dialogue : Dialogue
@export var voice_player : AudioStreamPlayer3D

var in_dialogue := false
var current_line := 0
var writing_line := false

func _input(_event: InputEvent) -> void:
	super._input(_event)
	
	if Input.is_action_just_pressed("interact") and in_dialogue and off_cooldown:
		advance_dialogue()
		_cooldown()

func advance_dialogue():
	if current_line == dialogue.spliced_lines.size()-1 and !writing_line:
		end_dialogue()
		return
	else:
		if !writing_line: current_line += 1
		type_line(dialogue.spliced_lines[current_line])

func _interact():
	interacted.emit()
	if indicator: indicator.visible = false
	
	if !in_dialogue and off_cooldown:
		writing_line = false
		Manager.player.dialogue_box.visible = true
		type_line(dialogue.spliced_lines[0])
		in_dialogue = true
		_cooldown()

func end_dialogue():
	writing_line = false
	in_dialogue = false
	current_line = 0
	Manager.player.dialogue_box.visible = false
	Manager.player.dialogue_text.text = ""

func type_line(line : String):
	if writing_line:
		display_full(line)
		writing_line = false
		return
	
	var current_char = 0
	var displayed_text = ""
	var line_length = 0
	
	writing_line = true
	
	for i in line.length():
		if writing_line:
			if Manager.player.dialogue_text.text == line:
				break
			
			if line_length > MAX_LINE_SIZE:
				if line[current_char] == " " or line[current_char-1] == ".":
					displayed_text +="\n"
					line_length = 0
			line_length+=1
			
			displayed_text += line[current_char]
			Manager.player.dialogue_text.text = displayed_text
			
			if voice_player: 
				if !VOICE_EXCLUDE.contains(line[current_char]):
					voice_player.play()
			
			current_char +=1
			if i!=0: await get_tree().create_timer(0.05).timeout
			
			if i == line.length()-1:
				writing_line = false
		else: break

func display_full(line : String):
	var current_char = 0
	var displayed_text = ""
	var line_length = 0
	
	for i in line.length():
		if line_length > MAX_LINE_SIZE:
			if line[current_char] == " " or line[current_char-1] == ".":
				displayed_text +="\n"
				line_length = 0
		line_length+=1
		
		displayed_text += line[current_char]
		Manager.player.dialogue_text.text = displayed_text
		
		current_char +=1
