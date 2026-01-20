@tool
extends Tool

@export var image : Texture2D
@export var clarity : int
@export var perfect_visibility : float
@export var image_rating : int
@export var visible_animals : Array[String]

var enabled := false
var closing := false

func _primary():
	if !enabled:
		$PictureUI.visible = true
		$Anim.play("slide")
		enabled = true
	else:
		if closing: return
		closing = true
		$Anim.play_backwards("slide")
		await $Anim.animation_finished
		$PictureUI.visible = false
		enabled = false
		closing = false

func _ready() -> void:
	$PictureUI.visible = false
	enabled = false
	data_setup()
	_setup()

func data_setup():
	if item_data.keys().size() == 0: return
	var keys = item_data.keys()
	
	if item_data["image_bytes"]:
		var img_texture : Texture2D
		var img_2 = Image.new()
		if img_2.load_png_from_buffer(item_data["image_bytes"]) == OK:
			img_texture = ImageTexture.create_from_image(img_2)
		else:
			img_texture = ImageTexture.create_from_image(Image.create_empty(380, 285,false,Image.FORMAT_ETC2_R11))
		%PictureDisplay.texture = img_texture
	
	if keys.has("clarity"): 
		clarity = item_data["clarity"]
		%ClarityLabel.text = str("Clarity:  ", clarity, "%")
	
	if keys.has("image_rating"): 
		image_rating = int(item_data["image_rating"])
		%ScoreLabel.text = str("Picture Score:  ", image_rating)
	
	if keys.has("visible_animals"):
		var animal_names : Array[String]
		var animal_list : String
		for path in item_data["visible_animals"]:
			var resource = load(path)
			if resource is AnimalData:
				animal_names.append(resource.name)
		animal_list = ", ".join(animal_names)
		%AnimalLabel.text = str("Animals:  ", animal_list)
	
