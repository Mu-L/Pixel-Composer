function Node_Tunnel_In(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Tunnel Sender";
	color = COLORS.node_blend_tunnel;
	preview_draw = false;
	set_default  = false;
	
	setDimension(32, 32);
	
	newInput(0, nodeValue_Text( "Name", LOADING || APPENDING? "" : $"tunnel{ds_map_size(project.tunnels_in_map)}" )).rejectArray();
	newInput(1, nodeValue(      "Value in", self, CONNECT_TYPE.input, VALUE_TYPE.any, noone )).setVisible(true, true);
	
	////- =Display
	newInput(2, nodeValue_EButton( "Label Position", 0, [ "T", "B", "L", "R" ] ));
	newInput(3, nodeValue_Float(   "Label Scale",    1        ));
	newInput(4, nodeValue_Color(   "Label Color",    ca_white ));
	newInput(5, nodeValue_Slider(  "Label Alpha",    1        ));
	// input 6
	
	input_display_list = [ 0, 1, 
		["Display", false], 2, 3, 4, 5, 
	];
	
	inputs[0].editWidget.autocomplete_server = tunnel_autocomplete_server;
	inputs[0].editWidget.autocomplete_subt   = "Ctrl: Change connected";
	inputs[0].is_modified = true;
	inputs[0].onSetValue  = function(newKey) /*=>*/ {
		if(!key_mod_press(CTRL)) return;
		
		for( var i = 0, n = array_length(receivers); i < n; i++ ) {
			var node = PROJECT.nodeMap[? receivers[i]];
			if(!node) continue;
			
			node.inputs[0].setValueDirect(newKey);
		}
	};
	
	static getDisplayName = function() /*=>*/ {return string(inputs[0].getValue())};
	
	isHovering     = false;
	hover_scale    = 0;
	hover_scale_to = 0;
	hover_alpha    = 0;
	
	preview_connecting = false;
	preview_scale      = 1;
	junction_hover     = false;
	error_notification = noone;
	
	receivers = [];
	open      = true;
	
	label_ori   = 0;
	label_scale = 1;
	label_color = ca_white;
	label_alpha = 1;
	
	__jfrom = noone;
	__key   = noone;
	
	////- Update
	
	setTrigger(1, "Tunnel Panel", [ THEME.tunnel_panel, 0, c_white ]);
	static onInspector1Update = function() /*=>*/ { dialogPanelCall(new Panel_Tunnels()); }
	
	setTrigger(2, "Create Receiver", [ THEME.tunnel, 0, COLORS.node_blend_tunnel ]);
	static onInspector2Update = function() {
		var _nx = x + 160;
		var _ny = PANEL_GRAPH.getFreeY(_nx, y);
		    
		var _node = nodeBuild("Node_Tunnel_Out", _nx, _ny).skipDefault();
		if(!is(_node, Node)) return;
		
		var _key = inputs[0].getValue();
		_node.inputs[0].setValue(_key);
	}
	
	static update = function(frame = CURRENT_FRAME) {
		
		var _key = inputs[0].getValue();
		var _frm = inputs[1].value_from;
		
		label_ori   = getInputData(2);
		label_scale = getInputData(3);
		label_color = getInputData(4);
		label_alpha = getInputData(5);
		
		if(_key != __key) checkKey(); 
		
		if(_frm != __jfrom) {
			inputs[1].setType(   _frm? _frm.type         : VALUE_TYPE.any);
			inputs[1].setDisplay(_frm? _frm.display_type : VALUE_DISPLAY._default);
			inputs[1].updateColor();
		}
		
		__key   = _key;
		__jfrom = _frm;
		
		value_validation[VALIDATION.error] = error_notification != noone;
		
		receivers = [];
		var _keys = ds_map_keys_to_array(project.tunnels_out);
		
		for (var i = 0, n = array_length(_keys); i < n; i++) {
			var _k = _keys[i];
			
			if(project.tunnels_out[? _k] != _key)   continue;
			if(!ds_map_exists(PROJECT.nodeMap, _k)) continue;
			
			var node = PROJECT.nodeMap[? _k];
			if(!node.active || node.group != group) continue;
			
			array_push(receivers, _k);
		}
		
	}
	
	static resetMap = function() {
		if(__key != noone) ds_map_delete(project.tunnels_in, __key);
		
		var _key = inputs[0].getValue();
		project.tunnels_in_map[? node_id] = _key;
		project.tunnels_in[? _key] = inputs[1];
	}
	
	static checkDuplicate = function() {
		var _key = inputs[0].getValue();
		if(_key == "") return;
		
		var amo  = ds_map_size(project.tunnels_in_map);
		var k    = ds_map_find_first(project.tunnels_in_map);
		var dup  = false;
		
		repeat(amo) {
			if(k != node_id && project.tunnels_in_map[? k] == _key)
				dup = true;
			
			k = ds_map_find_next(project.tunnels_in_map, k);
		}
		
		if(dup && error_notification == noone) {
			error_notification = noti_error($"Duplicated key: {_key}");
			error_notification.onClick = function() /*=>*/ {return PANEL_GRAPH.focusNode(self)};
			
		} else if(!dup && error_notification) {
			noti_remove(error_notification);
			error_notification = noone;
		}
	}
	
	static checkKey = function() {
		var _key = inputs[0].getValue();
		resetMap();
		
		var amo = ds_map_size(project.tunnels_in_map);
		var k   = ds_map_find_first(project.tunnels_in_map), _n;
		repeat(amo) {
			_n = project.nodeMap[? k];
			k = ds_map_find_next(project.tunnels_in_map, k);
			
			if(!is(_n, Node_Tunnel_In)) continue;
			if(!_n.active) continue;
			
			_n.resetMap();
		}
		
		var k   = ds_map_find_first(project.tunnels_in_map);
		repeat(amo) {
			_n = project.nodeMap[? k];
			k = ds_map_find_next(project.tunnels_in_map, k);
			
			if(!is(_n, Node_Tunnel_In)) continue;
			if(!_n.active) continue;
			
			_n.checkDuplicate();
		}
	}
	
	static onValueUpdate = function(index = -1) {
		checkKey();
		if(index == 0) { RENDER_ALL_REORDER }
	}
	
	static getNextNodes = function(checkLoop = false) {
		var nodes = [];
		var _key  = inputs[0].getValue();
		var amo   = ds_map_size(project.tunnels_out);
		var k     = ds_map_find_first(project.tunnels_out);
		
		LOG_BLOCK_START();
		LOG_IF(global.FLAG.render == 1, $"→→→→→ Call get next node from: {getInternalName()}");
		
		repeat(amo) {
			if(project.tunnels_out[? k] == _key)
				array_push(nodes, project.nodeMap[? k]);
			
			k = ds_map_find_next(project.tunnels_out, k);
		}
		
		LOG_BLOCK_END();
		return nodes;
	}
	
	////- Draw
	
	static pointIn = function(_x, _y, _mx, _my, _s) {
		var xx =  x      * _s + _x;
		var yy = (y + 8) * _s + _y;
		
		return point_in_circle(_mx, _my, xx, yy, _s * 24);
	}
	
	static preDraw = function(_x, _y, _mx, _my, _s) {
		var xx =  x      * _s + _x;
		var yy = (y + 8) * _s + _y;
		
		inputs[0].x = xx;
		inputs[0].y = yy;
		
		inputs[1].x = xx;
		inputs[1].y = yy;
	}
	
	static drawBadge = function(_x, _y, _s) {}
	static drawJunctionNames = function(_x, _y, _mx, _my, _s, _panel = noone) {}
	
	static onDrawNodeBehind = function(_x, _y, _mx, _my, _s) {
		var xx =  x      * _s + _x;
		var yy = (y + 8) * _s + _y;
		
		var hover = isHovering || hover_alpha == 1;
		var tun   = findPanel("Panel_Tunnels");
		hover = hover || (tun && tun.tunnel_hover == self);
		if(!hover) return;
		
		var _key  = inputs[0].getValue();
		var _keys = ds_map_keys_to_array(project.tunnels_out);
		insp2UpdateIcon[2] = inputs[1].color_display;
		
		draw_set_color(inputs[1].color_display);
		draw_set_alpha(0.5);
		
		for (var i = 0, n = array_length(_keys); i < n; i++) {
			var _k = _keys[i];
			
			if(project.tunnels_out[? _k] != _key)   continue;
			if(!ds_map_exists(PROJECT.nodeMap, _k)) continue;
			
			var node = PROJECT.nodeMap[? _k];
			if(!node.active || node.group != group) continue;
			
			preview_connecting      = true;
			node.preview_connecting = true;
			
			var tox = _x +  node.x      * _s;
			var toy = _y + (node.y + 8) * _s;
			draw_line_dotted(xx, yy, tox, toy, 2 * _s, current_time / 10, 3);
		}
		
		draw_set_alpha(1);
	}
	
	static drawJunctions = function(_draw, _x, _y, _mx, _my, _s) {
		var xx =  x      * _s + _x;
		var yy = (y + 8) * _s + _y;
		isHovering = point_in_circle(_mx, _my, xx, yy, _s * 24);
		
		gpu_set_tex_filter(true);
		junction_hover = inputs[1].drawJunction(_draw, _s, _mx, _my);
		gpu_set_tex_filter(false);
		
		if(!isHovering) return noone;
		if(!junction_hover) CURSOR_SPRITE = THEME.view_pan;
		
		hover_scale_to = 1;
		
		return junction_hover? inputs[1] : noone;
	}
	
	static drawNode = function(_draw, _x, _y, _mx, _my, _s) {
		if(!_draw) return drawJunctions(_draw, _x, _y, _mx, _my, _s);
		
		var xx =  x      * _s + _x;
		var yy = (y + 8) * _s + _y;
		
		hover_alpha = 0.5;
		if(active_draw_index > -1) {
			hover_alpha		  =  1;
			hover_scale_to	  =  1;
			active_draw_index = -1;
		}
		
		#region draw arc
			var prev_s = preview_connecting? 1 + sin(current_time / 100) * 0.1 : 1;
			preview_scale      = lerp_float(preview_scale, prev_s, 5);
			preview_connecting = false;
			
			shader_set(sh_node_arc);
				shader_set_color("color", inputs[1].color_display, hover_alpha);
				shader_set_f("angle", degtorad(90));
				
				var _r = preview_scale * _s * 20;
				shader_set_f("amount", 0.4, 0.5);
				draw_sprite_stretched(s_fx_pixel, 0, xx - _r, yy - _r, _r * 2, _r * 2);
				
				var _r = preview_scale * _s * 30;
				shader_set_f("amount", 0.45, 0.525);
				draw_sprite_stretched(s_fx_pixel, 0, xx - _r, yy - _r, _r * 2, _r * 2);
				
				var _r = preview_scale * _s * 40;
				shader_set_f("amount", 0.475, 0.55);
				draw_sprite_stretched(s_fx_pixel, 0, xx - _r, yy - _r, _r * 2, _r * 2);
				
			shader_reset();
		#endregion
			
		if(hover_scale > 0) {
			var _r = hover_scale * _s * 16;
			shader_set(sh_node_circle);
				shader_set_color("color", COLORS._main_accent, hover_alpha);
				draw_sprite_stretched(s_fx_pixel, 0, xx - _r, yy - _r, _r * 2, _r * 2);
			shader_reset();
		}
		
		hover_scale    = lerp_float(hover_scale, hover_scale_to && !junction_hover, 3);
		hover_scale_to = 0;
		
		var aa = label_alpha * _color_get_alpha(label_color);
		var ss = _s * .3 * label_scale;
		var tt = string(inputs[0].getValue());
		
		switch(label_ori) {
			case 0 : 
				draw_set_text(f_sdf, fa_center, fa_bottom, label_color, aa);
				draw_text_transformed(xx, yy - 12 * _s, tt, ss, ss, 0);
				break;
				
			case 1 : 
				draw_set_text(f_sdf, fa_center, fa_top, label_color, aa);
				draw_text_transformed(xx, yy + 12 * _s, tt, ss, ss, 0);
				break;
				
			case 2 : 
				draw_set_text(f_sdf, fa_right, fa_center, label_color, aa);
				draw_text_transformed(xx - 12 * _s, yy, tt, ss, ss, 0);
				break;
				
			case 3 : 
				draw_set_text(f_sdf, fa_left, fa_center, label_color, aa);
				draw_text_transformed(xx + 12 * _s, yy, tt, ss, ss, 0);
				break;
		}
		
		draw_set_alpha(1);
		
		return drawJunctions(_draw, _x, _y, _mx, _my, _s);
	}
	
	////- Actions
	
	static onClone = function() { onValueUpdate(0); }
	
	static postConnect = function() { 
		onValueUpdate(0); 
		onValueFromUpdate(0);
	}
	
	static onDestroy = function() {
		if(error_notification != noone)
			noti_remove(error_notification);
	
		var _key = inputs[0].getValue();
		
		ds_map_delete(project.tunnels_in_map,  node_id);
		ds_map_delete(project.tunnels_in,     _key);
	}
	
	static onRestore = function() {
		resetMap();
	}
	
	////- Init
	
	resetMap();
	
}