/// @description init
event_inherited();

#region 
	destroy_on_click_out = true;
	max_h     = 640;
	align     = fa_left;
	draggable = false;
	selecting = -1;
	
	font     = f_p1;
	arrayBox = noone;
	
	anchor = ANCHOR.top | ANCHOR.left;
	
	sc_content = new scrollPane(0, 0, function(_y, _m) {
		draw_clear(COLORS.panel_bg_clear);
		
		var hght  = line_get_height(font, 8);
		var _h    = array_length(arrayBox.data) * hght;
		var _dw   = sc_content.surface_w;
		var array = arrayBox.arraySet;
		
		for(var i = 0; i < array_length(arrayBox.data); i++) {
			var _ly = _y + i * hght;	
			var yc  = _ly + hght / 2;
			var exists = false;
			
			for( var j = 0; j < array_length(array); j++ ) {
				if(arrayBox.data[i] == array[j])
					exists = true;
			}
			
			var ind = 0;
			
			if(sHOVER && sc_content.hover && point_in_rectangle(_m[0], _m[1], 0, _ly + 1, _dw, _ly + hght - 1)) {
				selecting = i;
				sc_content.hover_content = true;
			}
			
			if(selecting == i) {
				draw_sprite_stretched_ext(THEME.textbox, 3, 0, _ly, _dw, hght, COLORS.dialog_menubox_highlight, 1);
				ind = 1;
				
				if(sFOCUS && (mouse_press(mb_left) || keyboard_check_pressed(vk_enter))) {
					if(exists)	array_remove(array, arrayBox.data[i]);
					else		array_push(array, arrayBox.data[i]);
					
					if(arrayBox.onModify) arrayBox.onModify();
				}
			}
			
			var bs = hght - ui(8);
			draw_sprite_stretched(THEME.checkbox_def, ind, ui(20) - bs / 2, yc - bs / 2, bs, bs);
			if(exists) draw_sprite_stretched_ext(THEME.checkbox_def, 2, ui(20) - bs / 2, yc - bs / 2, bs, bs, COLORS._main_accent, 1);
			
			draw_set_text(font, fa_left, fa_center, COLORS._main_text);
			draw_text(ui(40), yc, arrayBox.data[i]);
		}
		
		if(sFOCUS) {
			if(KEYBOARD_PRESSED == vk_up) {
				selecting--;
				if(selecting < 0) selecting = array_length(arrayBox.data) - 1;
			}
			
			if(KEYBOARD_PRESSED == vk_down)
				selecting = safe_mod(selecting + 1, array_length(arrayBox.data));
				
			if(keyboard_check_pressed(vk_escape))
				instance_destroy();
		}
		
		return _h;
	});
#endregion
