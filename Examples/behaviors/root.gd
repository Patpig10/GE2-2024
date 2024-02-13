extends Node3D

var xr_interface: XRInterface

func _input(event):
	if event is InputEventKey and event.keycode == KEY_Q:
		get_tree().quit()
		
func _ready():
	xr_interface = XRServer.find_interface("OpenXR")
	if xr_interface and xr_interface.is_initialized():
		print("OpenXR initialised successfully")

		# Turn off v-sync!
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

		# Change our main viewport to output to the HMD
		get_viewport().use_xr = false
	else:
		# print("OpenXR not initialized, please check if your headset is connected")
		pass
