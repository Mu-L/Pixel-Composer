function Node_Frame(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name   = "Frame";
	w      = 240;
	h      = 160;
	bg_spr = THEME.node_frame_bg;
	
	size_dragging    = false;
	size_dragging_w  = w;
	size_dragging_h  = h;
	size_dragging_mx = w;
	size_dragging_my = h;
	
	auto_height      = false;
	name_hover       = false;
	hover_progress   = 0;
	
	color  = c_white;
	lAlpha = 1;
	tColor = c_white;
	
	reframe = true;
	repadd  = 32;
	
	tb_name     = textBox_Text(function(txt) /*=>*/ { setDisplayName(txt); }).setFont(f_p2).setHide(true).setAlign(fa_center);
	name_height = 18;
	__nodes     = [];
	
	draw_x0 = 0;
	draw_y0 = 0;
	draw_x1 = 0;
	draw_y1 = 0;
	
	////- =Relable
	newInput(0, nodeValue_Vec2(   "Size",     [240,160] ));
	newInput(4, nodeValue_Bool(   "Reframe",   true     ));
	newInput(5, nodeValue_Float(  "Padding",   32       ));
	
	////- =Label
	newInput(1, nodeValue_Color(  "Color",        ca_white ));
	newInput(2, nodeValue_Slider( "Label Alpha", .75       ));
	
	////- =Text
	newInput(3, nodeValue_Color(  "Text Color",   ca_white ));
	
	input_display_list = [ 
		[ "Reframe", false, 4 ], 5, 
		[ "Label",   false ], 1, 2,  
		[ "Text",    false ], 3, 
	];
	
	array_foreach(inputs, function(i) /*=>*/ {return i.rejectArray()});
	
	static move = function(_x, _y) {
		if(moved) return;
		if(x == _x && y == _y) return;
		
		var _dx = _x - x;
		var _dy = _y - y;
		
		x = _x; 
		y = _y; 
		moved = true;
		
		for( var i = 0, n = array_length(__nodes); i < n; i++ ) {
			var _n  = __nodes[i];
			var _nx = _n.x + _dx;
			var _ny = _n.y + _dy;
			
			_n.move(_nx, _ny);
		}
		
		if(!LOADING) project.modified = true;
	}
	
	static getCoveringNodes = function(node_list) {
		var fx0 = x;
        var fy0 = y;
        var fx1 = x + w;
        var fy1 = y + h;
        
    	__nodes = [];
    	
        for( var i = 0, n = array_length(node_list); i < n; i++ ) { // Select content
            var _node = node_list[i];
            
            if(_node == self || !_node.selectable) continue;
            if(!project.graphDisplay.show_control && _node.is_controller) continue;
            
            var nx0 = _node.x;
            var ny0 = _node.y;
            var nx1 = _node.x + _node.w;
            var ny1 = _node.y + _node.h;
            
            if(rectangle_in_rectangle(nx0, ny0, nx1, ny1, fx0, fy0, fx1, fy1) == 1)
                array_push(__nodes, _node);
        }
        
	}
	
	static reFrame = function() {
		if(!reframe || array_empty(__nodes)) return;
		
		var _minx =  infinity;
		var _miny =  infinity;
		var _maxx = -infinity;
		var _maxy = -infinity;
		var  padd = repadd;
		
		for( var i = 0, n = array_length(__nodes); i < n; i++ ) {
			var _n = __nodes[i];
			var x0 = _n.x - padd;
			var y0 = _n.y - padd;
			var x1 = _n.x + _n.w + padd;
			var y1 = _n.y + _n.h + padd;
			
			_minx = min(_minx, x0);
			_miny = min(_miny, y0);
			_maxx = max(_maxx, x1);
			_maxy = max(_maxy, y1);
		}
		
		
		x = _minx;
		y = _miny;
		w = _maxx - _minx;
		h = _maxy - _miny;
	}
	
	////- Update
	
	static onValueUpdate = function(index = 3) { 
		previewable = true;
		
		var sz = inputs[0].getValue();
		w = sz[0];
		h = sz[1];
		
		color  = inputs[1].getValue();
		lAlpha = inputs[2].getValue();
		tColor = inputs[3].getValue();
		
		reframe = inputs[4].getValue();
		repadd  = inputs[5].getValue();
		
		reFrame();
	}
	
	static setHeight = function() {}
	
	static isRenderable = function() /*=>*/ {return false};
	static doUpdate = function() {}
	static update   = function() {}
	
	////- Draw
	
	static preDraw = function(_x, _y, _mx, _my, _s) {}
	
	static drawNode  = function() { return noone; }
	static drawBadge = function() { return noone; }
	
	static drawNodeBase = function(xx, yy, _s, _panel = noone) {
		var _nh = ui(name_height);
		var _yy = yy - _nh;
		
		var x0 =  xx;
		var y0 = _yy;
		var x1 =  xx + w * _s;
		var y1 = _yy + _nh + h * _s;
		
		draw_x0 = x0;
		draw_y0 = y0;
		draw_x1 = x1;
		draw_y1 = y1;
		
		if(_panel != noone) {
			px0 =  3;
			py0 =  0 + _panel.topbar_height * project.graphDisplay.show_topbar;
			px1 = -3 + _panel.w;
			py1 = -0 + _panel.h - _panel.toolbar_height;
			
			draw_x0 = max(x0, px0);
			draw_y0 = max(y0, py0);
			draw_x1 = min(x1, px1);
			draw_y1 = min(y1, py1);
		}
		
		var _h  = max(draw_y1 - draw_y0, _nh);
		
		if(y0 > 0)	draw_y1 = draw_y0 + _h;
		else		draw_y0 = draw_y1 - _h;
		
		if(draw_x1 - draw_x0 < 4) return;
		
		var _dw = x1 - x0;
		var _dh = y1 - y0;
		var alp = _color_get_alpha(color);
		
		draw_sprite_stretched_ext(bg_spr, 0, x0, y0, _dw, _dh, color, alp);
	}
	
	static drawNodeFG = function(_x, _y, _mx, _my, _s, _dparam, _panel = noone) {
		if(draw_x1 - draw_x0 < 4) return;
		
		var _w  = draw_x1 - draw_x0;
		var _h  = draw_y1 - draw_y0;
		var txt = renamed? display_name : name;
		var alp = _color_get_alpha(color);
		
		draw_sprite_stretched_ext(bg_spr, 1, draw_x0, draw_y0, _w, _h, color, alp * .3);
		
		if(WIDGET_CURRENT == tb_name) {
			var nh = 24;
			draw_sprite_stretched_ext(bg_spr, 2, draw_x0, draw_y0, _w, nh, color, alp * .75 * lAlpha);
			
			tb_name.setFocusHover(PANEL_GRAPH.pFOCUS, PANEL_GRAPH.pHOVER);
			tb_name.draw(draw_x0, draw_y0, _w, nh, txt, [ _mx, _my ]);
			
		} else {
			var nh = ui(name_height);
			draw_sprite_stretched_ext(bg_spr, 2, draw_x0, draw_y0, _w, nh, color, alp * .75 * lAlpha);
			
			draw_set_text(f_p2, fa_center, fa_bottom, tColor, _color_get_alpha(tColor));
			draw_text_cut((draw_x0 + draw_x1) / 2, draw_y0 + nh + 1, txt, _w - 4);
			draw_set_alpha(1);
			
			if(point_in_rectangle(_mx, _my, draw_x0, draw_y0, draw_x0 + _w, draw_y0 + nh)) {
				if(PANEL_GRAPH.pFOCUS && DOUBLE_CLICK)
					tb_name.activate(txt);
			}
		}
		
		draw_sprite_stretched_add(bg_spr, 1, draw_x0, draw_y0, _w, _h, c_white, .1);
		
		if(active_draw_index > -1) {
			draw_sprite_stretched_ext(bg_spr, 1, draw_x0, draw_y0, _w, _h, COLORS._main_accent, 1);
			active_draw_index = -1;
		}
		
		drawBadge(_x, _y, _s);
	}
	
	static drawNodeBG = function(_x, _y, _mx, _my, _s, _dparam, _panel = noone) {
		
		if(size_dragging) {
			w = size_dragging_w + (mouse_mx - size_dragging_mx) / _s;
			h = size_dragging_h + (mouse_my - size_dragging_my) / _s;
			
			if(!key_mod_press(CTRL)) {
				w = value_snap(w, 16);
				h = value_snap(h, 16);
			}
			
			if(mouse_release(mb_left)) {
				size_dragging = false;
				inputs[0].setValue([ w, h ]);
			}
		}
		
		var xx = x * _s + _x;
		var yy = y * _s + _y;
		drawNodeBase(xx, yy, _s, _panel);
		
		var x1  = xx + w * _s;
		var y1  = yy + h * _s;
		var x0  = x1 - 10 * THEME_SCALE;
		var y0  = y1 - 10 * THEME_SCALE;
		var ics = 0.5;
		var shf = 8 * ics;
		
		var hov = point_in_rectangle(_mx, _my, xx, yy, x1, y1);
		
		if(w * _s < 32 || h * _s < 32) return point_in_rectangle(_mx, _my, xx, yy, x1, y1);
		
		if(hov || size_dragging) {
			var _aa = size_dragging? .3 : .15;
			if(_panel != noone && !name_hover && point_in_rectangle(_mx, _my, x0, y0, x1, y1)) {
				_aa = .3;
				PANEL_GRAPH.drag_locking = true;
				
				if(mouse_press(mb_left)) {
					size_dragging	 = true;
					size_dragging_w  = w;
					size_dragging_h  = h;
					size_dragging_mx = mouse_mx;
					size_dragging_my = mouse_my;
				}
			}
			
			draw_sprite_ext_add(THEME.node_resize, 0, x1 - shf, y1 - shf, ics, ics, 0, c_white, _aa);
		}
		
		return hov;
	}
	
	static pointIn = function(_x, _y, _mx, _my, _s) {
		var xx = x * _s + _x;
		var yy = y * _s + _y;
		var y0 = yy - ui(name_height);
		
		var hover  = point_in_rectangle(_mx, _my, xx, y0, xx + w * _s, yy);
		name_hover = hover;
		
		return hover;
	}

	////- Serialize
	
	static postApplyDeserialize  = function() { onValueUpdate(); }
	
	static postDeserialize = function() {
		if(CLONING) return;
		
		if(LOADING_VERSION < 1_19_05_1)
			load_map.inputs[3] = { raw_value : { d : ca_white } };
	}
	
}