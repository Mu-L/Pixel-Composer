function __Panel_Linear_Setting_Item(name, editWidget, data, onEdit = noone, getDefault = noone, action = noone) constructor {
	self.name       = name;
	self.editWidget = editWidget;
	self.data       = data;
	
	self.onEdit     = onEdit;
	self.getDefault = getDefault;
	self.action     = action == noone? noone : struct_try_get(FUNCTIONS, string_to_var2(action[0], action[1]), noone);
	key = "";
	
	self.is_patreon = false;
	
	static setKey  = function(_key) { self.key = _key; return self; }
	static patreon = function() { is_patreon = true; return self; }
}

function __Panel_Linear_Setting_Item_Preference(name, key, editWidget, _data = noone) : __Panel_Linear_Setting_Item(name, editWidget, _data) constructor {
	self.key = key;
	
	data       = function()    { return PREFERENCES[$ key];             }
	onEdit     = function(val) { PREFERENCES[$ key] = val; PREF_SAVE(); }
	getDefault = function()    { return PREFERENCES_DEF[$ key];         }
}

function __Panel_Linear_Setting_Label(name, sprite, _index = 0, _color = c_white) constructor {
	self.name    = name;
	self.sprite  = sprite;
	self.index   = _index;
	self.color   = _color;
}

function Panel_Linear_Setting() : PanelContent() constructor {
	title   = __txt("Settings");
	w       = ui(400);
	wdgw    = ui(180);
	
	bg_y    = -1;
	bg_y_to = -1;
	bg_a    =  0;
	
	hk_editing     = noone;
	selecting_menu = noone;
	properties     = [];
	
	static setHeight = function() { h = ui(12 + 36 * array_length(properties)); }
	
	static drawSettings = function(panel) {
		var yy = ui(24);
		var th = ui(36);
		var ww = max(wdgw, w * 0.5); 
		var wh = TEXTBOX_HEIGHT;
		
		var _hov = false;
		if(bg_y) draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, ui(4), bg_y, w - ui(8), th, COLORS.panel_prop_bg, 0.5 * bg_a);
		
		for( var i = 0, n = array_length(properties); i < n; i++ ) {
			var _prop = properties[i];
			
			if(is_instanceof(_prop, __Panel_Linear_Setting_Label)) {
				var _text = _prop.name;
				var _spr  = _prop.sprite;
				var _ind  = _prop.index;
				var _colr = _prop.color;
				
				draw_sprite_stretched_ext(THEME.s_box_r5_clr, 0, ui(4), yy - th / 2 + ui(2), w - ui(8), th - ui(4), _colr, 1);
				draw_sprite_ui(_spr, _ind, ui(4) + th / 2, yy);
				
				draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text);
				draw_text_add(ui(4) + th, yy, _text);
				
				yy += th;
				continue;
			}
			
			if(is_instanceof(_prop, __Panel_Linear_Setting_Item)) {
				var _text = _prop.name;
				var _data = _prop.data;
				var _widg = _prop.editWidget;
				if(is_callable(_data)) _data = _data();
				
				_widg.setFocusHover(pFOCUS, pHOVER);
				_widg.register();
				
				var _whover = false;
				if(pHOVER && point_in_rectangle(mx, my, 0, yy - th / 2, w, yy + th / 2)) {
					bg_y_to = yy - th / 2;
					_hov    = true;
					_whover = true;
				}
				
				draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text);
				draw_text_add(ui(16), yy, _text);
			
				var _x1  = w - ui(8);
				var _wdw = ww;
			
				if(_prop.getDefault != noone)
					_wdw -= ui(32 + 8);
				
				var params = new widgetParam(_x1 - ww, yy - wh / 2, _wdw, wh, _data, {}, [ mx, my ], x, y);
				if(is_instanceof(_widg, checkBox)) {
					params.halign = fa_center;
					params.valign = fa_center;
				}
				
				_widg.drawParam(params); 
				
				if(_prop.action != noone) {
					var _key = _prop.action.hotkey;
					
					if(_whover && !_widg.inBBOX([ mx, my ]) && mouse_press(mb_right)) {
						selecting_menu = _key;
						
						var context_menu_settings = [
							_key.full_name(),
							menuItem(__txt("Edit hotkey"), function() /*=>*/ { hk_editing = selecting_menu; keyboard_lastchar = hk_editing.key; }),
						];
						
						menuCall("", context_menu_settings);
					}
					
								
					if(_key) {
						draw_set_font(f_p1);
						
						var _ktxt = key_get_name(_key.key, _key.modi);
						var _tw = string_width(_ktxt);
						var _th = line_get_height();
						
						var _hx = _x1 - ww - ui(16);
						var _hy = yy + ui(2);
							
						var _bx = _hx - _tw - ui(4);
						var _by = _hy - _th / 2 - ui(3);
						var _bw = _tw + ui(8);
						var _bh = _th + ui(3);
						
						if(hk_editing == _key) {
							draw_set_text(f_p1, fa_right, fa_center, COLORS._main_accent);
							draw_sprite_stretched_ext(THEME.ui_panel, 1, _bx, _by, _bw, _bh, COLORS._main_text_accent);
							
						} else if(_ktxt != "") {
							draw_set_text(f_p1, fa_right, fa_center, COLORS._main_text_sub);
							draw_sprite_stretched_ext(THEME.ui_panel, 1, _bx, _by, _bw, _bh, CDEF.main_dkgrey);
						}
						
						draw_text(_hx, _hy, _ktxt);
					}
		
				}
				
				if(_prop.getDefault != noone) {
					var _defVal = is_method(_prop.getDefault)? _prop.getDefault() : _prop.getDefault;
					var _bs = ui(32);
					var _bx = _x1 - _bs;
					var _by = yy - _bs / 2;
					
					if(isEqual(_data, _defVal))
						draw_sprite_ext(THEME.refresh_16, 0, _bx + _bs / 2, _by + _bs / 2, 1, 1, 0, COLORS._main_icon_dark);
					else {
						if(buttonInstant(THEME.button_hide, _bx, _by, _bs, _bs, [ mx, my ], pFOCUS, pHOVER, __txt("Reset"), THEME.refresh_16) == 2)
							_prop.onEdit(_defVal);
					}
				}
				
				yy += th;
				continue;
			}
		}
		
		bg_a = lerp_float(bg_a, _hov, 2);
		
		if(bg_y == -1) bg_y = bg_y_to;
		else           bg_y = lerp_float(bg_y, bg_y_to, 2);
		
		if(hk_editing != noone) {
			if(keyboard_check_pressed(vk_enter))  hk_editing = noone;
			else                                  hotkey_editing(hk_editing);
			
			if(keyboard_check_pressed(vk_escape)) hk_editing = noone;
		} 
	}
	
	function drawContent(panel) { drawSettings(panel); }
}