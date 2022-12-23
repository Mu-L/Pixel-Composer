function LOAD() {
	var path = get_open_filename("*.pxc;*.json", "");
	if(path == "") return;
	if(filename_ext(path) != ".json" && filename_ext(path) != ".pxc") return;
		
	gc_collect();
	LOAD_PATH(path);
	
	ds_list_clear(STATUSES);
	ds_list_clear(WARNING);
	ds_list_clear(ERRORS);
}

function LOAD_PATH(path, readonly = false) {
	if(!file_exists(path)) {
		log_warning("LOAD", "File not found");
		return false;
	}
	
	if(filename_ext(path) != ".json" && filename_ext(path) != ".pxc") {
		log_warning("LOAD", "File not a valid project");
		return false;
	}
	
	nodeCleanUp();
	clearPanel();
	setPanel();
	room_restart();
	
	var temp_path = DIRECTORY + "\_temp";
	if(file_exists(temp_path)) file_delete(temp_path);
	file_copy(path, temp_path);
	
	LOADING		= true;
	READONLY	= readonly;
	SET_PATH(path);
	
	var file = file_text_open_read(temp_path);
	var load_str = "";
	
	while(!file_text_eof(file)) {
		load_str += file_text_readln(file);
	}
	file_text_close(file);
	
	var _map = json_decode(load_str);
	if(ds_map_exists(_map, "version")) {
		var _v = _map[? "version"];
		if(_v != SAVEFILE_VERSION) {
			var warn = "File version mismatch : loading file verion " + string(_v) + " to Pixel Composer " + string(SAVEFILE_VERSION);
			log_warning("LOAD", warn);
		}
	} else {
		var warn = "File version mismatch : loading old format to Pixel Composer " + string(SAVEFILE_VERSION);
		log_warning("LOAD", warn);
	}
	
	nodeCleanUp();
	
	var create_list = ds_list_create();
	if(ds_map_exists(_map, "nodes")) {
		try {
			var _node_list = _map[? "nodes"];
			for(var i = 0; i < ds_list_size(_node_list); i++) {
				var _node = nodeLoad(_node_list[| i]);
				if(_node) ds_list_add(create_list, _node);
			}
		} catch(e) {
			log_warning("LOAD", e.longMessage);
		}
	}
	
	try {
		if(ds_map_exists(_map, "animator")) {
			var _anim_map			= _map[? "animator"];
			ANIMATOR.frames_total	= ds_map_try_get(_anim_map, "frames_total");
			ANIMATOR.framerate		= ds_map_try_get(_anim_map, "framerate");
		}
	} catch(e) {
		log_warning("LOAD, animator", e.longMessage);
	}
	
	ds_queue_clear(CONNECTION_CONFLICT);
	
	try {
		for(var i = 0; i < ds_list_size(create_list); i++)
			create_list[| i].loadGroup();
	} catch(e) {
		log_warning("LOAD, group", e.longMessage);
	}
	
	try {
		for(var i = 0; i < ds_list_size(create_list); i++)
			create_list[| i].postDeserialize();
	} catch(e) {
		log_warning("LOAD, deserialize", e.longMessage);
	}
	
	try {
		for(var i = 0; i < ds_list_size(create_list); i++)
			create_list[| i].preConnect();
		for(var i = 0; i < ds_list_size(create_list); i++)
			create_list[| i].connect();
		for(var i = 0; i < ds_list_size(create_list); i++)
		create_list[| i].postConnect();
	} catch(e) {
		log_warning("LOAD, connect", e.longMessage);
	}
	
	try {
		for(var i = 0; i < ds_list_size(create_list); i++)
			create_list[| i].doUpdate();
	} catch(e) {
		log_warning("LOAD, update", e.longMessage);
	}
	
	renderAll();
	
	if(!ds_queue_empty(CONNECTION_CONFLICT)) {
		var pass = 0;
		
		try {
			while(++pass < 4 && !ds_queue_empty(CONNECTION_CONFLICT)) {
				var size = ds_queue_size(CONNECTION_CONFLICT);
				log_message("LOAD", "[Connect] " + string(size) + " Connection conflict(s) detected ( pass: " + string(pass) + " )");
				repeat(size) {
					ds_queue_dequeue(CONNECTION_CONFLICT).connect();	
				}
				renderAll();
			}
		
			if(!ds_queue_empty(CONNECTION_CONFLICT))
				log_warning("LOAD", "Some connection(s) is unsolved. This may caused by render node not being update properly, or image path is broken.");
		} catch(e) {
			log_warning("LOAD, connect solver", e.longMessage);
		}
	}
	
	LOADING = false;
	MODIFIED = false;
	
	PANEL_ANIMATION.updatePropertyList();
	
	log_message("FILE", "load " + path, s_noti_icon_file_load);
	
	ds_map_destroy(_map);
	return true;
}
