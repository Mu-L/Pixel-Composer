function Node_IsoSurf(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "IsoSurf";
	
	newInput(0, nodeValue_Int(      "Direction", 4 )).setValidator(VV_min(1));
	newInput(1, nodeValue_Surface(  "Surfaces" )).setVisible(true, true).setArrayDepth(1);
	newInput(2, nodeValue_Rotation( "Angle Shift", 0 ));
	newInput(3, nodeValue_Float(    "Angle Split", [ 0 * 90, 1 * 90, 2 * 90, 3 * 90 ])).setArrayDynamic().setArrayDepth(1);
	newInput(4, nodeValue_Vector(   "Offsets" )).setArrayDepth(1);
	
	newOutput(0, nodeValue_Output("IsoSurf", VALUE_TYPE.dynaSurface, noone));
	
	knob_select   = noone;
	knob_hover    = noone;
	knob_dragging = noone;
	drag_sv = 0;
	drag_sa = 0;
	
	angle_renderer = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) {
		var hh     = ui(240);
		var _surfs = getInputData(1);
		var _angle = getInputData(3);
		
		var _kx = _x + _w / 2;
		var _ky = _y + hh / 2;
		
		draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, _y, _w, hh, COLORS.node_composite_bg_blend, 1);
		draw_circle_ui(_kx, _ky, ui(24), .05, COLORS._main_icon, .5);
		
		var _khover = noone;
		
		for( var i = 0, n = array_length(_angle); i < n; i++ ) {
			var _ang = _angle[i];
			
			var _knx = _kx + lengthdir_x(ui(22), _ang);
			var _kny = _ky + lengthdir_y(ui(22), _ang);
			
			var _tx = _kx + lengthdir_x(ui(44), _ang);
			var _ty = _ky + lengthdir_y(ui(44), _ang);
			
			var _sx = _kx + lengthdir_x(ui(84), _ang);
			var _sy = _ky + lengthdir_y(ui(84), _ang);
			
			var _ind = (knob_dragging == noone && i == knob_hover) || knob_dragging == i;
			var _cc  = knob_dragging == i? COLORS._main_accent : COLORS._main_icon;
			
			draw_circle_ui(_knx, _kny, ui(6), 1, COLORS.panel_bg_clear_inner);
			
			draw_set_color(_cc);
			draw_set_alpha(.5);
			draw_line(_knx, _kny, _sx, _sy);
			draw_set_alpha(1);
			
			draw_circle_ui(_knx, _kny, ui(4), 1, _cc);
			
			if(point_in_circle(_m[0], _m[1], _knx, _kny, ui(10)))
				_khover = i;
			
			draw_set_text(f_p3, fa_center, fa_center, COLORS._main_text_sub);
			draw_text_add(_tx, _ty, _ang);
			
			ui_fill_rect_wh(_sx - 20, _sy - 20, 40, 40, COLORS.panel_bg_clear_inner);
			
			var _surf = array_safe_get_fast(_surfs, i, noone);
			if(is_surface(_surf)) {
				var _sw = surface_get_width(_surf);
				var _sh = surface_get_height(_surf);
				var _ss = min(32 / _sw, 32 / _sh);
				draw_surface_ext(_surf, _sx - _sw * _ss / 2, _sy - _sh * _ss / 2, _ss, _ss, 0, c_white, 1);
			}
			
			var cc = COLORS._main_icon;
			if(i == knob_hover)  cc = COLORS._main_icon_light;
			if(i == knob_select) cc = COLORS._main_accent;
			
			ui_rect_wh(_sx - 20, _sy - 20, 40, 40, cc);
			
			if(point_in_rectangle(_m[0], _m[1], _sx - 20, _sy - 20, _sx + 20, _sy + 20))
				_khover = i;
		}
		
		knob_hover = _khover;
		
		if(mouse_press(mb_left, _focus) && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + hh))
			knob_select = knob_hover;
		
		if(knob_dragging == noone) {
			if(knob_hover >= 0 && mouse_press(mb_left, _focus)) {
				knob_dragging = knob_hover;
				drag_sv = _angle[knob_hover];
				drag_sa = point_direction(_kx, _ky, _m[0], _m[1]);
			}
		} else {
			var delta    = angle_difference(point_direction(_kx, _ky, _m[0], _m[1]), drag_sa);
			var real_val = round(delta + drag_sv);
			var val      = key_mod_press(CTRL)? round(real_val / 15) * 15 : real_val;
			_angle[knob_dragging] = val;
			
			if(inputs[3].setValue(_angle)) UNDO_HOLDING = true;
			
			if(mouse_release(mb_left))
				knob_dragging = noone;
		}
		
		return hh;
	});
	
	offsetEditing = false;
	offsetRenderer = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) {
		var _surfs = getInputData(1);
		var _offs  = getInputData(4);
		
		if(!is_array(_surfs) || !is_array(_offs)) return 0;
		if(knob_select == noone) return 0;
		
		var surf = array_safe_get(_surfs, knob_select);
		if(!is_surface(surf)) return 0;
		
		var hh = ui(160);
		draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, _y, _w, hh, COLORS.node_composite_bg_blend, 1);
		
		var amo  = array_length(_surfs);
		var _off = array_safe_get(_offs, knob_select);
		
		var pd  = ui(8);
		var sw  = _w - pd * 2;
		var sh  = hh - pd * 2;
		var srw = surface_get_width(surf);
		var srh = surface_get_height(surf);
		var ss  = min((sw - pd) / srw, (sh - pd) / srh);
		
		var sx  = _x + _w / 2 - srw * ss / 2;
		var sy  = _y + hh / 2 - srh * ss / 2;
		
		var sx1 = sx + srw * ss;
		var sy1 = sy + srh * ss;
		
		ui_fill_rect_wh(sx, sy, srw * ss, srh * ss, CDEF.main_dkblack);
		draw_surface_ext(surf, sx, sy, ss, ss, 0, c_white, 1);
		
		var _mx = clamp(value_snap((_m[0] - sx) / ss, 0.5), 0, srw);
		var _my = clamp(value_snap((_m[1] - sy) / ss, 0.5), 0, srh);
		
		if(offsetEditing || point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + hh)) {
			draw_set_text(f_p3, fa_right, fa_bottom, COLORS._main_text_sub);
			draw_text(_x + _w - 4, _y + hh - 4, $"{_mx}, {_my}");
			
			var _ox = sx + _mx * ss - 1;
			var _oy = sy + _my * ss - 1;
			
			draw_set_color(CDEF.main_dkgrey);
			draw_line(sx, _oy, sx + srw * ss, _oy);
			draw_line(_ox, sy, _ox, sy + srh * ss);
			
			if(mouse_lpress(_focus))
				offsetEditing = true;
		}
		
		if(offsetEditing) {
			_offs[knob_select][0] = _mx;
			_offs[knob_select][1] = _my;
			
			inputs[4].setValue(_offs);
			triggerRender();
			
			if(mouse_lrelease())
				offsetEditing = false;
		}
		
		ui_rect_wh(sx, sy, srw * ss, srh * ss, COLORS._main_icon);
		
		if(!is_array(_off)) return hh;
		var _ox = sx + _off[0] * ss - 1;
		var _oy = sy + _off[1] * ss - 1;
		
		draw_set_color(c_black);
		draw_line_width(_ox - 5, _oy, _ox + 5, _oy, 4);
		draw_line_width(_ox, _oy - 5, _ox, _oy + 5, 4);
		
		draw_set_color(c_white);
		draw_line_width(_ox - 4, _oy, _ox + 4, _oy, 2);
		draw_line_width(_ox, _oy - 4, _ox, _oy + 4, 2);
		
		return hh;
	});
	
	input_display_list = [
		["Iso",  false], 0, 2, angle_renderer, offsetRenderer, 
		["Data", false], 1, 4, 
	];
	
	static resetOffset = function() {
		var _amo = getInputData(0);
		var _off = array_create(_amo);
		
		for( var i = 0, n = _amo; i < n; i++ )
			_off[i] = [ 0, 0 ];
		
		inputs[4].setValue(_off);
	}
	
	static onValueUpdate = function(index) {
		if(index != 0) return;
		
		var _amo = getInputData(0);
		var _off = getInputData(4);
		
		var _ang = array_create(_amo);
		array_resize(_off, _amo);
		
		for( var i = 0, n = _amo; i < n; i++ ) {
			_ang[i] = 360 * (i / _amo);
			_off[i] = array_verify(_off[i], 2);
		}
		
		inputs[3].setValue(_ang);
		inputs[4].setValue(_off);
	}
	
	static processData = function(_outData, _data, _array_index) {
		var _amo    = _data[0];
		var _surf   = _data[1];
		var _ashft  = _data[2];
		var _angle  = _data[3];
		var _offset = _data[4];
		var _iso    = is(_outData, dynaSurf_iso)? _outData : new dynaSurf_iso();
		
		_iso.offsetx = array_verify(_iso.offsetx, _amo);
		_iso.offsety = array_verify(_iso.offsety, _amo);
		
		for( var i = 0; i < _amo; i++ ) {
			var _s = array_safe_get_fast(_surf, i, noone);
			_iso.surfaces[i] = _s;
			
			var _off = array_safe_get_fast(_offset, i);
			_iso.offsetx[i] = array_safe_get_fast(_off, 0);
			_iso.offsety[i] = array_safe_get_fast(_off, 1);
		}
		
		_iso.angles      = _angle;
		_iso.angle_shift = _ashft;
		
		return _iso;
	}
}