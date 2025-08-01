function __initCollection() {
	printDebug("COLLECTION: init");
	
	globalvar COLLECTIONS;
	COLLECTIONS = -1;
	
	var root = DIRECTORY + "Collections"; directory_verify(root);
	
	if(check_version($"{root}/version")) zip_unzip($"{working_directory}data/collections.zip", root);
	
	COLLECTIONS = new DirectoryObject(DIRECTORY + "Collections");
	refreshCollections();
}

function refreshCollections() {
	printDebug("COLLECTION: refreshing collection base folder.");
	
	COLLECTIONS = new DirectoryObject(DIRECTORY + "Collections");
	COLLECTIONS.scan([".json", ".pxcc"]);
	COLLECTIONS.open = true;
}

function searchCollection(_list, _search_str, _toList = true) {
	if(_search_str == "") return;
	var search_lower = string_lower(_search_str);
	
	var st = ds_stack_create();
	var ll = _toList? ds_priority_create() : _list;
	
	ds_stack_push(st, COLLECTIONS);
		
	while(!ds_stack_empty(st)) {
		var _st = ds_stack_pop(st);
		for( var i = 0; i < array_length(_st.content); i++ ) {
			var _nd   = _st.content[i];
			var match = string_partial_match(string_lower(_nd.name), search_lower);
			if(match == -9999) continue;
			
			ds_priority_add(ll, _nd, match);
		}
			
		for( var i = 0; i < array_length(_st.subDir); i++ )
			ds_stack_push(st, _st.subDir[i]);
	}
	
	if(_toList) {
		repeat(ds_priority_size(ll))
			ds_list_add(_list, ds_priority_delete_max(ll));
		
		ds_priority_destroy(ll);
	}
	
	ds_stack_destroy(st);
}

function saveCollection(_node, _path, _name, save_surface = true, metadata = noone) {
	if(_node == noone) return;
		
	var _pxz  = false;
	var _file = _path + "/" + filename_name_only(_name);
	
	if(_pxz) {
		_path = _file + ".pxz";
		SAVE_PXZ_COLLECTION(_node, _path, PANEL_PREVIEW.getNodePreviewSurface(), metadata, _node.group);
		
	} else {
		_path = _file + ".pxcc";
		SAVE_COLLECTION(_node, _path, save_surface, metadata, _node.group);
		
	}
	
	PANEL_COLLECTION.updated_path = _path;
	PANEL_COLLECTION.updated_prog = 1;
	PANEL_COLLECTION.refreshContext();
}

function clearDefaultCollection() {
	var st = ds_stack_create();
	ds_stack_push(st, COLLECTIONS);
		
	while(!ds_stack_empty(st)) {
		var _st = ds_stack_pop(st);
		for( var i = 0; i < array_length(_st.content); i++ ) {
			var _file = _st.content[i];
			if(_file.type != FILE_TYPE.collection) continue;
			
			var _meta = _file.getMetadata();
			if(!_meta.isDefault) continue;
			
			var _path = _file.path;
			var _spth = array_safe_get(_file.spr_path, 0);
			var _mpth = _file.meta_path;
			
			file_delete_safe(_path);
			file_delete_safe(_spth);
			file_delete_safe(_mpth);
		}
		
		for( var i = 0; i < array_length(_st.subDir); i++ )
			ds_stack_push(st, _st.subDir[i]);
	}
	
	ds_stack_destroy(st);
	file_delete_safe(DIRECTORY + "Collections/version");
}