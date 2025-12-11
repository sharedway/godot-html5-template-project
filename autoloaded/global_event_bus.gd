extends Node

var VERSION_NUMBER="0.0.1"
var _print_logs = false 

var _active_log_index = 0

var active_log_index: int:
	get:
		return _active_log_index

signal show_main_loader(pipeline_payload: Dictionary)
signal hide_main_loader(pipeline_payload: Dictionary)
signal run_signals_pipeline(pipeline_payload: Dictionary)
signal print_log(pipeline_payload: Dictionary)

var print_logs: bool:
	get:
		return _print_logs



	


	

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

			
func _on_print_logs(pipeline_payload: Dictionary) -> void:
	if print_logs:
		print(pipeline_payload)
	GlobalEventBus.emit_signal("run_signals_pipeline",pipeline_payload)
		
func _ready() -> void:
	connect("set_print_logs_state",_on_set_print_logs_state)
	connect("print_log",_on_print_logs)
	connect("run_signals_pipeline",_on_run_signals_pipeline)
