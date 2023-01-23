extends Control

const seconds_per_day: int = 86400

var diff_unix_times = []
var names = []
var time = Time
var _timer = null

signal countdown_finished(index)

func _ready():
	var list = get_node("VBoxContainer/ItemList")
	list.visible = true
	_timer = Timer.new()
	connect("countdown_finished", self, "_on_countdown_finished")
	add_child(_timer)
	
	_timer.connect("timeout", self, "_on_Timer_timeout")
	_timer.set_wait_time(1.0)
	_timer.set_one_shot(false) # Make sure it loops
	_timer.start()
	

func _on_AddEventButton_pressed():
	var list = get_node("VBoxContainer/ItemList")
	var name = get_node("VBoxContainer/GridContainer/NameTextEdit").text
	names.append(name)
	var year = get_node("VBoxContainer/GridContainer/YearTextEdit").text
	var month = get_node("VBoxContainer/GridContainer/MonthTextEdit").text
	var day = get_node("VBoxContainer/GridContainer/DayTextEdit").text
	var hour = get_node("VBoxContainer/GridContainer/HourTextEdit").text
	var minute = get_node("VBoxContainer/GridContainer/MinuteTextEdit").text
	
	var datetime_string = year + "-" + month + "-" + day + "T" + hour + ":" + minute + ":00"
	
	var datetime = time.get_datetime_dict_from_datetime_string(datetime_string, true)
	var unix_time = time.get_unix_time_from_datetime_dict(datetime)
	
	var currnt_datetime = OS.get_datetime()
	var current_unix_time = time.get_unix_time_from_datetime_dict(currnt_datetime)
	
	var diff_unix_time = unix_time - current_unix_time
	
	diff_unix_times.append(diff_unix_time)
	list.add_item(convert_seconds(diff_unix_time) + " left until " + name)

func _on_Timer_timeout():
	var list = get_node("VBoxContainer/ItemList")
	var index = 0
	for diff_unix_time in diff_unix_times:
		list.set_item_text(index, convert_seconds(diff_unix_time) + " left until " + names[index])
		diff_unix_times[index] -= 1
		if diff_unix_times[index] == -1:
			diff_unix_times.remove(index)
			emit_signal("countdown_finished", index)
		index += 1
		
func convert_seconds(seconds):
	var output = ""
	var days = int(seconds / seconds_per_day)
	var seconds_int_day = seconds % seconds_per_day
	var time_in_day = time.get_time_string_from_unix_time(seconds_int_day)
	if days == 0:
		output = time_in_day
	elif days == 1:
		output = String(days) + " day and " + time_in_day
	else:
		output = String(days) + " days and " + time_in_day
	return output
	
	
func _on_countdown_finished(index):
	var list = get_node("VBoxContainer/ItemList")
	list.set_item_text(index, names[index] + " finished!!!")
	list.set_item_custom_bg_color(index, Color.darkred)
	names.remove(index)
