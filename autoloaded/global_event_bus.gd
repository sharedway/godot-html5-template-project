extends Node

var VERSION_NUMBER="0.0.1"
var _print_logs = false 

var _active_log_index = 0

var active_log_index: int:
	get:
		return _active_log_index

signal recalculate_camera_coords
signal current_camera_distance(distance: float)
signal current_lat(lat: float)
signal current_lon(lon: float)
signal current_camera_lon(lon: float)
signal current_camera_lat(lat: float)
signal current_globe_radius(globe_radius: float)
signal current_rotate_sensitivity(rotate_sensitivity: float)
signal update_drag_position(drag_position: Vector2)
signal set_camera_distance(distance:float)
signal zoom_up(state:bool)
signal zoom_down(state:bool)
signal sum_total_points(new_points: int)
signal set_rotate_globe_state(state:bool)
signal last_point_added(payload:Dictionary)
signal setup_pivot_controller(pipeline_payload: Dictionary)
signal render_points(pipeline_payload: Dictionary)
signal render_point(pipeline_payload: Dictionary)
signal calculate_coords_from_mouse_click(pipeline_payload: Dictionary)
signal render_meridian_lines(pipeline_payload: Dictionary)
signal render_parallel_lines(pipeline_payload: Dictionary)
signal render_world_environment(pipeline_payload: Dictionary)
signal renderiza_crosta_terrestre(pipeline_payload: Dictionary)
signal render_globe_crost(pipeline_payload: Dictionary)
signal rotate_camera_pivot_by_deg(pipeline_payload: Dictionary)
signal load_features_from_files(pipeline_payload: Dictionary)
signal load_feature_file_from_path(pipeline_payload: Dictionary)
signal render_geometric_feature(pipeline_payload: Dictionary)
signal setup_init_payload(pipeline_payload: Dictionary)
signal setup_render_point_controller_payload(pipeline_payload: Dictionary)
signal set_print_logs_state(pipeline_payload: Dictionary)
signal show_main_loader(pipeline_payload: Dictionary)
signal hide_main_loader(pipeline_payload: Dictionary)

signal run_signals_pipeline(pipeline_payload: Dictionary)
signal print_log(pipeline_payload: Dictionary)

var print_logs: bool:
	get:
		return _print_logs


func _latlon_to_vec3(lat_deg: float, lon_deg: float, globe_radius: float) -> Vector3:
	# lat, lon in degrees (WGS84)
	var lat := deg_to_rad(lat_deg)
	var lon := deg_to_rad(lon_deg)
	
	var x := -globe_radius * cos(lat) * sin(lon)
	var y :=  globe_radius * sin(lat)
	var z := -globe_radius * cos(lat) * cos(lon)

	return Vector3(x, y, z)
	

func vec3_to_latlon(pos: Vector3) -> Vector2:
	# Returns (lat_deg, lon_deg) consistent with _latlon_to_vec3 above
	var r := pos.length()
	if r == 0.0:
		return Vector2.ZERO
	var lat := asin(pos.y / r)
	var lon_prime := atan2(pos.x, -pos.z)  # corresponds to -lon
	var lon := -lon_prime

	return Vector2(rad_to_deg(lat), rad_to_deg(lon))
	

func _on_set_print_logs_state(pipeline_payload) -> void:	
	var print_log_state: bool = pipeline_payload.get('print_log_state', false)
	_print_logs = print_log_state
	GlobalEventBus.emit_signal("run_signals_pipeline",pipeline_payload)
	
# 
func _on_run_signals_pipeline(pipeline_payload: Dictionary) -> void:
	var active_pipeline = pipeline_payload.get('pipeline',[])
	
	if not active_pipeline.is_empty():
		var global_payload = pipeline_payload.get('global_payload',{})
		var event_to_emit = active_pipeline.pop_front()
		var event_payload:Dictionary = event_to_emit.get('event_payload', {})
		var event_name = event_to_emit.get('event_to_emit',"devnull")	
		var next_global_payload:Dictionary = event_payload
		next_global_payload.merge(global_payload)
		var next_pipeline_payload = {}
		next_pipeline_payload['pipeline'] = active_pipeline
		next_pipeline_payload['global_payload'] = next_global_payload
		if has_signal(event_name):
			emit_signal(event_name, next_pipeline_payload)
		else:			
			print("Sem sinal conectado")
			
func _on_print_logs(pipeline_payload: Dictionary) -> void:
	if print_logs:
		print(pipeline_payload)
	GlobalEventBus.emit_signal("run_signals_pipeline",pipeline_payload)
		
func _ready() -> void:
	connect("set_print_logs_state",_on_set_print_logs_state)
	connect("print_log",_on_print_logs)
	connect("run_signals_pipeline",_on_run_signals_pipeline)
