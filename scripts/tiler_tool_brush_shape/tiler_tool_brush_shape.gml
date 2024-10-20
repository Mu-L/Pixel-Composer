function tiler_tool_shape(node, _brush, _shape) : tiler_tool(node) constructor {
    self.brush = _brush;
    self.shape = _shape;
    
	brush_resizable = true;
	mouse_holding   = false;
	
	mouse_cur_x = 0;
	mouse_cur_y = 0;
	mouse_pre_x = 0;
	mouse_pre_y = 0;
	
	function step(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		
		mouse_cur_x = floor(round((_mx - _x) / _s - 0.5) / tile_size[0]);
		mouse_cur_y = floor(round((_my - _y) / _s - 0.5) / tile_size[1]);
		
		if(mouse_holding && key_mod_press(SHIFT)) {
			var ww = mouse_cur_x - mouse_pre_x;
			var hh = mouse_cur_y - mouse_pre_y;
			var ss = max(abs(ww), abs(hh));
				
			mouse_cur_x = mouse_pre_x + ss * sign(ww);
			mouse_cur_y = mouse_pre_y + ss * sign(hh);
		}
			
		if(mouse_holding) {
			
			surface_set_shader(drawing_surface, noone);
				switch(shape) {
					case CANVAS_TOOL_SHAPE.rectangle : tiler_draw_rect_brush(brush, mouse_pre_x, mouse_pre_y, mouse_cur_x, mouse_cur_y, subtool); break;
					case CANVAS_TOOL_SHAPE.ellipse   : tiler_draw_ellp_brush(brush, mouse_pre_x, mouse_pre_y, mouse_cur_x, mouse_cur_y, subtool); break;
				}
			surface_reset_shader();
				
			if(mouse_release(mb_left)) {
				apply_draw_surface();
				mouse_holding = false;
			}
			
		} else if(mouse_press(mb_left, active)) {
			mouse_pre_x = mouse_cur_x;
			mouse_pre_y = mouse_cur_y;
				
			mouse_holding = true;
			
			node.tool_pick_color(mouse_cur_x, mouse_cur_y);
		}
			
	}
	
	function drawPreview(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		
		if(!mouse_holding) {
			tiler_draw_point_brush(brush, mouse_cur_x, mouse_cur_y);
			return;
		}
		
		switch(shape) {
			case CANVAS_TOOL_SHAPE.rectangle : tiler_draw_rect_brush(brush, mouse_pre_x, mouse_pre_y, mouse_cur_x, mouse_cur_y, subtool); break;
			case CANVAS_TOOL_SHAPE.ellipse   : tiler_draw_ellp_brush(brush, mouse_pre_x, mouse_pre_y, mouse_cur_x, mouse_cur_y, subtool); break;
		}   
	}
	
	static drawMask = function() {
	    draw_set_color(c_white);
	    tiler_draw_point_brush(brush, mouse_cur_x, mouse_cur_y);
	}
}