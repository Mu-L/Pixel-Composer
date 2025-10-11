globalvar FONT_MAP;
globalvar FONT_INTERNAL;
globalvar FONT_SPRITES;

FONT_SPRITES = ds_map_create();

function readFontFolder(dirPath, _log = false) {
	if(_log) print($"Reading font folder {dirPath}")
	
	var filter = [ ".ttf", ".otf" ];
	var _files = directory_get_files_ext(dirPath, filter);
	
	for( var i = 0, n = array_length(_files); i < n; i++ ) {
		var fil = _files[i];
		var ful = dirPath + fil;
		var nam = filename_name_only(fil);
		if(_log) print($" > Found font {nam}")
		
		FONT_MAP[$ nam] = ful;
		array_push(FONT_INTERNAL, ful);
	}
	
}

function __initFontFolder(_log = false) {
	var root = $"{DIRECTORY}Fonts";
	FONT_MAP      = {};
	FONT_INTERNAL = [];
	
	directory_verify(root);
	readFontFolder($"{root}/", _log);
	for (var i = 0, n = array_length(PREFERENCES.path_fonts); i < n; i++)
		readFontFolder(string_trim_end(PREFERENCES.path_fonts[i], ["/"]) + "/", _log);
}

function loadFontSprite(path) {
	var f = _font_add(path, 32);
	if(!font_exists(f)) { FONT_SPRITES[? path] = noone; return; }
	
	draw_set_text(f, fa_left, fa_top, c_white);
	var name = "ABCabc123";
	var ww   = max(1, string_width(name));
	var hh   = max(1, string_height(name));
	
	var s = surface_create(ww, hh);
	surface_set_target(s);
	DRAW_CLEAR
	draw_text(0, 0, name);
	surface_reset_target();
	
	var spr = sprite_create_from_surface(s, 0, 0, ww, hh, false, false, 0, 0);
	surface_free(s);
	font_delete(f);
	
	FONT_SPRITES[? path] = spr;
}
