globalvar LOCALE, TEST_LOCALE, LOCALE_DEF;

TEST_LOCALE = 0;
LOCALE_DEF  = 1;
LOCALE      = {
	fontDir: "",
	config: { per_character_line_break: false },
}

global.missing_locale = {}
global.missing_file   = "D:/Project/MakhamDev/LTS-PixelComposer/PixelComposer/datafiles/data/Locale/missing.txt";

function __initLocale() {
	var lfile = $"data/Locale/en.zip";
	var root  = $"{DIRECTORY}Locale";
	
	directory_verify(root);
	if(check_version($"{root}/version")) {
		zip_unzip(lfile, root);
		file_copy($"data/Locale/LOCALIZATION GUIDES.txt", $"{DIRECTORY}Locale/LOCALIZATION GUIDES.txt");
	}
	
	if(LOCALE_DEF && !TEST_LOCALE) return;
	loadLocale();
}

function __locale_file(file) {
	var dirr = $"{DIRECTORY}Locale/{PREFERENCES.local}";
	if(!directory_exists(dirr) || !file_exists_empty(dirr + file)) 
		dirr = $"{DIRECTORY}Locale/en";
	return dirr + file;
}

function loadLocale() {
	var _word     = json_load_struct(__locale_file("/words.json"));
	var _ui       = json_load_struct(__locale_file("/UI.json"));
	LOCALE.texts  = struct_append(_word, _ui);
	
	LOCALE.node   = json_load_struct(__locale_file("/nodes.json"));
	LOCALE.config = json_load_struct(__locale_file("/config.json"));
	
	var fontDir = $"{DIRECTORY}Locale/{PREFERENCES.local}/fonts/";
	LOCALE.fontDir = directory_exists(fontDir)? fontDir : noone;
}

function __txtx(key, def = "") {
	INLINE
	
	if(LOCALE_DEF && !TEST_LOCALE) return def;
	
	if(TEST_LOCALE) {
		if(key != "" && !struct_has(LOCALE.texts, key) && !struct_has(global.missing_locale, key)) {
			global.missing_locale[$ key] = def;
			file_text_write_all(global.missing_file, json_stringify(global.missing_locale));
		}
		
		return def;
	}
	
	return LOCALE.texts[$ key] ?? def;
}

function __txts(keys) { array_map_ext(keys, function(k) /*=>*/ {return __txt(k, k)}); return keys; } 
function __txt(txt, prefix = "") {
	INLINE
	
	if(!is_string(txt)) return txt;
	if(LOCALE_DEF && !TEST_LOCALE) return txt;
	
	var key = string_replace_all(string_lower(txt), " ", "_");
		
	if(TEST_LOCALE) {
		if(key != "" && !struct_has(LOCALE.texts, key) && !struct_has(global.missing_locale, key)) {
			global.missing_locale[$ key] = txt;
			file_text_write_all(global.missing_file, json_stringify(global.missing_locale));
		}
		
		return txt;
	}
	
	return __txtx(prefix + key, txt);
}

function __txta(txt) {
	var _txt = __txt(txt);
	for(var i = 1; i < argument_count; i++)
		_txt = string_replace_all(_txt, $"\{{i}\}", string(argument[i]));
	
	return _txt;
}

function __txt_node_name(node, def = "") {
	INLINE
	
	if(LOCALE_DEF && !TEST_LOCALE) return def;
	
	if(TEST_LOCALE) {
		if(node != "Node_Custom" && !struct_has(LOCALE.node, node)) {
			show_debug_message($"LOCALE [NODE]: \"{node}\": \"{def}\",");
			return def;
		}
		return "";
	}
	
	if(!struct_has(LOCALE.node, node)) 
		return def;
	
	return LOCALE.node[$ node].name;
}

function __txt_node_tooltip(node, def = "") {
	INLINE
	
	if(LOCALE_DEF && !TEST_LOCALE) return def;
		
	if(TEST_LOCALE) {
		if(node != "Node_Custom" && !struct_has(LOCALE.node, node)) {
			show_debug_message($"LOCALE [TIP]: \"{node}\": \"{def}\",");
			return def;
		}
		return "";
	}
	
	if(!struct_has(LOCALE.node, node)) 
		return def;
	
	return LOCALE.node[$ node].tooltip;
}

function __txt_junction_name(node, type, index, def = "") {
	INLINE
	
	if(LOCALE_DEF && !TEST_LOCALE) return def;
	
	if(TEST_LOCALE) {
		if(!struct_has(LOCALE.node, node)) {
			show_debug_message($"LOCALE [JNAME]: \"{node}\": \"{def}\",");
			return def;
		}
		return "";
	}
	
	if(!struct_has(LOCALE.node, node)) 
		return def;
	
	var nde = LOCALE.node[$ node];
	var lst = type == CONNECT_TYPE.input? nde.inputs : nde.outputs;
	if(index >= array_length(lst)) return def;
	
	return lst[index].name;
}

function __txt_junction_tooltip(node, type, index, def = "") {
	INLINE
	
	if(LOCALE_DEF && !TEST_LOCALE) return def;
	
	if(TEST_LOCALE) {
		if(!struct_has(LOCALE.node, node)) {
			show_debug_message($"LOCALE [JTIP]: \"{node}\": \"{def}\",");
			return def;
		}
		return "";
	}
	
	if(!struct_has(LOCALE.node, node)) 
		return def;
	
	var nde = LOCALE.node[$ node];
	var lst = type == CONNECT_TYPE.input? nde.inputs : nde.outputs;
	if(index >= array_length(lst)) return def;
	
	return lst[index].tooltip;
}

function __txt_junction_data(node, type, index, def = []) {
	INLINE
	
	if(LOCALE_DEF && !TEST_LOCALE) return def;
	
	if(TEST_LOCALE) {
		if(!struct_has(LOCALE.node, node)) {
			show_debug_message($"LOCALE [DDATA]: \"{node}\": \"{def}\",");
			return def;
		}
		return [ "" ];
	}
	
	if(!struct_has(LOCALE.node, node)) 
		return def;
		
	var nde = LOCALE.node[$ node];
	var lst = type == CONNECT_TYPE.input? nde.inputs : nde.outputs;
	if(index >= array_length(lst)) return def;
	
	if(!struct_has(lst[index], "display_data"))
		return def;
	
	return lst[index].display_data;
}
