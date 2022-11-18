/// @description init
event_inherited();

#region data
	dialog_w = ui(640);
	dialog_h = ui(480);
	
	destroy_on_click_out = true;
	destroy_on_escape    = false;
#endregion

#region resize
	dialog_resizable = true;
	dialog_w_min = ui(640);
	dialog_h_min = ui(480);
	
	onResize = function() {
		sp_pref.resize(dialog_w - ui(192), dialog_h - ui(80));
		sp_hotkey.resize(dialog_w - ui(192), dialog_h - ui(80));
	}
#endregion

#region pages
	page_current = 0;
	page[0] = "General";
	page[1] = "Node settings";
	page[2] = "Hotkeys";
	
	pref_global = ds_list_create();
	pref_node = ds_list_create();
	
	ds_list_add(pref_global, [
		"Show welcome screen",
		"show_splash",
		new checkBox(function() { 
			PREF_MAP[? "show_splash"] = !PREF_MAP[? "show_splash"];
			PREF_SAVE();
		})
	]);
	
	
	PREF_MAP[? "_display_scaling"] = PREF_MAP[? "display_scaling"];
	ds_list_add(pref_global, [
		"GUI scaling",
		"_display_scaling",
		new slider(0.5, 2, 0.01, function(val) { 
			PREF_MAP[? "_display_scaling"] = val;
			PREF_SAVE();
		}, function() { 
			PREF_MAP[? "_display_scaling"] = clamp(PREF_MAP[? "_display_scaling"], 0.5, 2);
			if(PREF_MAP[? "display_scaling"] == PREF_MAP[? "_display_scaling"])
				return;
				
			PREF_MAP[? "display_scaling"] = PREF_MAP[? "_display_scaling"];
			setPanel();
			
			time_source_start(time_source_create(time_source_global, 1, time_source_units_frames, onResize));
		})
	]);
	
	ds_list_add(pref_global, [
		"Double click delay",
		"double_click_delay",
		new slider(0, 100, 1, function(val) { 
			PREF_MAP[? "double_click_delay"] = val; 
			PREF_SAVE();
		})
	]);
	
	ds_list_add(pref_global, [
		"Default surface size",
		"default_surface_side",
		new textBox(TEXTBOX_INPUT.number, function(str) { 
			PREF_MAP[? "default_surface_side"] = max(1, round(real(str)));
			PREF_SAVE();
		})
	]);
	
	ds_list_add(pref_global, [
		"Show node render time",
		"node_show_time",
		new checkBox(function() { 
			PREF_MAP[? "node_show_time"] = !PREF_MAP[? "node_show_time"]; 
			PREF_SAVE();
		})
	]);
	
	ds_list_add(pref_global, [
		"Collection preview speed",
		"collection_preview_speed",
		new textBox(TEXTBOX_INPUT.number, function(str) { 
			PREF_MAP[? "collection_preview_speed"] = max(1, round(real(str)));
			PREF_SAVE();
		})
	]);
	
	
	ds_list_add(pref_global, [
		"Inspector line break width",
		"inspector_line_break_width",
		new textBox(TEXTBOX_INPUT.number, function(str) { 
			PREF_MAP[? "inspector_line_break_width"] = max(1, round(real(str)));
			PREF_SAVE();
		})
	]);
	
	//NODE
	
	ds_list_add(pref_node, "Particle");
	ds_list_add(pref_node, [
		"Max particles",
		"part_max_amount",
		new textBox(TEXTBOX_INPUT.number, function(str) { 
			PREF_MAP[? "part_max_amount"] = real(str); 
			PREF_SAVE();
		})
	]);
	
	ds_list_add(pref_node, "Separate shape");
	ds_list_add(pref_node, [
		"Max shapes",
		"shape_separation_max",
		new textBox(TEXTBOX_INPUT.number, function(str) { 
			PREF_MAP[? "shape_separation_max"] = real(str); 
			PREF_SAVE();
		})
	]);
	
	ds_list_add(pref_node, "Levels");
	ds_list_add(pref_node, [
		"Histogram resolution",
		"level_resolution",
		new textBox(TEXTBOX_INPUT.number, function(str) { 
			PREF_MAP[? "level_resolution"] = real(str); 
			PREF_SAVE();
		})
	]);
	
	ds_list_add(pref_node, [
		"Maximum sampling",
		"level_max_sampling",
		new textBox(TEXTBOX_INPUT.number, function(str) { 
			PREF_MAP[? "level_max_sampling"] = real(str); 
			PREF_SAVE();
		})
	]);
	
	ds_list_add(pref_node, "Physic");
	ds_list_add(pref_node, [
		"Verlet iteration",
		"verlet_iteration",
		new textBox(TEXTBOX_INPUT.number, function(str) { 
			PREF_MAP[? "verlet_iteration"] = real(str); 
			PREF_SAVE();
		})
	]);
	
	current_list = pref_global;
	
	sp_pref = new scrollPane(dialog_w - ui(192), dialog_h - ui(88), function(_y, _m) {
		draw_clear_alpha(c_ui_blue_black, 0);
		var hh		= 0;
		var th		= TEXTBOX_HEIGHT;
		var x1		= dialog_w - ui(200);
		var yy		= _y + ui(8);
		var padd	= ui(6);
		var ind		= 0;
		
		for(var i = 0; i < ds_list_size(current_list); i++) {
			var _pref = current_list[| i];
			
			if(is_string(_pref)) {
				draw_set_text(f_p0b, fa_left, fa_top, c_ui_blue_grey);
				draw_text(ui(16), yy, _pref);
				yy += string_height(_pref) + ui(8);
				hh += string_height(_pref) + ui(8);
				ind = 0;
				continue;
			}
			
			var name = _pref[0];
			
			if(search_text == "" || string_pos(string_lower(search_text), string_lower(name)) > 0) {
				if(ind % 2 == 0)
					draw_sprite_stretched_ext(s_ui_panel_bg, 0, 0, yy - padd, sp_pref.w, th + padd * 2, c_ui_blue_white, 1);
				
				draw_set_text(f_p1, fa_left, fa_center, c_white);
				draw_text(ui(8), yy + th / 2, _pref[0]);
				_pref[2].active = sFOCUS; 
				_pref[2].hover  = sHOVER;
				
				switch(instanceof(_pref[2])) {
					case "textBox" :
						_pref[2].draw(x1 - ui(4), yy + th / 2, ui(88), th, PREF_MAP[? _pref[1]], _m,, fa_right, fa_center);
						break;
					case "checkBox" :
						_pref[2].draw(x1 - ui(48), yy + th / 2, PREF_MAP[? _pref[1]], _m,, fa_center, fa_center);
						break;
					case "slider" :
						_pref[2].draw(x1 - ui(4), yy + th / 2, ui(200), th, PREF_MAP[? _pref[1]], _m, ui(88), fa_right, fa_center);
						break;
				}
				
				yy += th + padd + ui(8);
				hh += th + padd + ui(8);
				ind++;
			}
		}
		
		return hh;
	});
#endregion

#region search
	tb_search = new textBox(TEXTBOX_INPUT.text, function(str) {
		search_text = str;
	});
	
	search_text = "";
#endregion

#region hotkey
	vk_list = [ 
		vk_left, vk_right, vk_up, vk_down, vk_space, vk_backspace, vk_tab, vk_home, vk_end, vk_delete, vk_insert, 
		vk_pageup, vk_pagedown, vk_pause, vk_printscreen, 
		vk_f1, vk_f2, vk_f3, vk_f4, vk_f5, vk_f6, vk_f7, vk_f8, vk_f9, vk_f10, vk_f11, vk_f12,
	];
	hk_editing = noone;
	
	sp_hotkey = new scrollPane(dialog_w - ui(192), dialog_h - ui(88), function(_y, _m) {
		draw_clear_alpha(c_ui_blue_black, 0);
		var padd		= ui(8);
		var hh			= 0;
		var currGroup	= -1;
		var x1			= dialog_w - ui(192);
		
		for(var j = 0; j < ds_list_size(HOTKEY_CONTEXT); j++) {
			var ll = HOTKEYS[? HOTKEY_CONTEXT[| j]];
			
			for(var i = 0; i < ds_list_size(ll); i++) {
				var key = ll[| i];
				var group = key.context;
				var name  = key.name;
				var pkey  = key.key;
				//var modi  = key.modi;
				
				if(search_text != "" && string_pos(string_lower(search_text), string_lower(name)) == 0)
					continue;
				
				if(group != currGroup) {
					if(group != "") hh += ui(12);
					draw_set_text(f_p0b, fa_left, fa_top, c_ui_blue_grey);
					draw_text(ui(16), _y + hh, group == ""? "Global" : group);
					
					hh += string_height("l") + ui(16);
					currGroup = group;
				}
				draw_set_text(f_p0, fa_left, fa_top, c_white);
				var th = string_height("l");
			
				if(i % 2 == 0) {
					draw_sprite_stretched_ext(s_ui_panel_bg, 0, 0, _y + hh - padd, 
						sp_hotkey.w, th + padd * 2, c_ui_blue_white, 1);
				}
			
				draw_set_text(f_p0, fa_left, fa_top, c_white);
				draw_text(ui(16), _y + hh, name);
			
				var dk = key_get_name(key.key, key.modi);
				var kw = string_width(dk);
			
				if(hk_editing == key) {
					var _mod_prs = 0;
					
					if(keyboard_check(vk_control))	_mod_prs |= MOD_KEY.ctrl;
					if(keyboard_check(vk_shift))	_mod_prs |= MOD_KEY.shift;
					if(keyboard_check(vk_alt))		_mod_prs |= MOD_KEY.alt;
	
					if(keyboard_check_pressed(vk_escape)) {
						key.key	 = "";
						key.modi = 0;
						
						PREF_SAVE();
					} else if(keyboard_check_pressed(vk_anykey)) {
						var press = false;
						for(var a = 32; a <= 126; a++) {
							if(keyboard_check_pressed(a)) {
								key.key	 = ord(string_upper(ansi_char(a)));
								press = true;
								break;
							}
						}
						if(!press) {
							for(var a = 0; a < array_length(vk_list); a++) {
								if(keyboard_check_pressed(vk_list[a])) {	
									key.key = vk_list[a];
									press = true; 
									break;
								}
							}
						}
						
						if(press) key.modi = _mod_prs;
						PREF_SAVE();
					}
					
					draw_sprite_stretched(s_button_hide, 2, x1 - ui(40) - kw, _y + hh - ui(6), kw + ui(32), th + ui(12));
				} else {
					if(buttonInstant(s_button_hide, x1 - ui(40) - kw, _y + hh - ui(6), kw + ui(32), th + ui(12), _m, sFOCUS, sHOVER) == 2) {
						hk_editing = key;
						keyboard_lastchar = pkey;
					}
				}
				draw_set_text(f_p0, fa_right, fa_top, hk_editing == key? c_ui_orange : c_white);
				draw_text(x1 - ui(24), _y + hh, dk);
				
				hh += th + padd * 2;
			}
		}
		
		return hh;
	})
#endregion