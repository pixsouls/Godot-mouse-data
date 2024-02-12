extends Node2D

@onready var mouse_positions_queue : Array = Array()
@onready var frame_count : int = 0

func _process(_delta) -> void:
	var mouse_pos = get_global_mouse_position()
	# frame count is a helpful variable to make sure it doesn't crash wehn first
	# running due to mouse_positions_queue being empty.
	# TODO: just init the array to Vector2.ZERO
	frame_count += 1
	
	# sussy queue.
	mouse_positions_queue.append(mouse_pos)
	if mouse_positions_queue.size() >= 100:
		# sussy pop()
		mouse_positions_queue.remove_at(0)
	
	var packed_array : PackedVector2Array = PackedVector2Array()
	for i in mouse_positions_queue.size():
		packed_array.append(mouse_positions_queue[i])
	$line.points = packed_array
	
	$vector.position = mouse_pos
	
	var angle_average : Vector2
	var distance_average : float
	if frame_count > 2:
		# added this variable to shorten the lines
		var mpq : Array = mouse_positions_queue
		for i in  mouse_positions_queue.size() - 2:
			angle_average += mpq[mpq.size() - i - 1] - mpq[mpq.size() - i - 2]
		angle_average /=  mouse_positions_queue.size() - 2
		
		# takes the average of distance using 1/10th of the Queue's recorded points.
		for i in (int(mouse_positions_queue.size() / 10)) - 2:
			distance_average += mpq[mpq.size() - i - 1].distance_to(mpq[mpq.size() - i - 2])
		distance_average /=  mouse_positions_queue.size() - 2
		
		$vector.target_position = angle_average
		$vector.target_position = $vector.target_position.normalized() * (distance_average * 20)
	
	$"ui vector".target_position = $vector.target_position
	
	# take pythagorean's of vector components to get 
	# its velocity in units (by default pixels) per frame.
	var current_vel = pow($vector.target_position.x, 2) + pow($vector.target_position.y,2 )
	current_vel = sqrt(current_vel)
	$"ui/bar".value = current_vel
	
	# \u00B0 is the unicode the the degree symbol
	var current_degree = rad_to_deg($vector.target_position.angle())
	$ui/Label.text = str(snapped(current_degree, .1)) + "\u00B0"
