function Node_Pixel_Sort(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Pixel Sort";
	
	shader = sh_pixel_sort;
	uniform_dim = shader_get_uniform(shader, "dimension");
	uniform_itr = shader_get_uniform(shader, "iteration");
	uniform_tre = shader_get_uniform(shader, "threshold");
	uniform_dir = shader_get_uniform(shader, "direction");
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue("Iteration", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 2);
	
	inputs[| 2] = nodeValue("Threshold", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.1)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01]);
	
	inputs[| 3] = nodeValue("Direction", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.rotation, 90);
	
	inputs[| 4] = nodeValue("Mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 5] = nodeValue("Mix", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01]);
	
	inputs[| 6] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 6;
	
	input_display_list = [ 6, 
		["Surface",		 true], 0, 4, 5, 
		["Pixel sort",	false], 1, 2, 3, 
	]
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var _in = _data[0];
		
		var _it = _data[1];
		var _tr = _data[2];
		var _dr = floor(_data[3] / 90) % 4;
		if(_dr < 0) _dr = 4 + _dr;
		if(_it <= 0) return _outSurf;
		
		var sw = surface_get_width(_outSurf);
		var sh = surface_get_height(_outSurf);
		
		var pp = [ surface_create_valid(sw, sh), surface_create_valid(sw, sh) ];
		var sBase, sDraw;
		
		surface_set_target(pp[1]);
			draw_clear_alpha(0, 0);
			BLEND_OVERRIDE;
			draw_surface_safe(_in, 0, 0);
			BLEND_NORMAL;
		surface_reset_target();
		
		shader_set(shader);
		shader_set_uniform_f(uniform_dim, surface_get_width(_in), surface_get_height(_in));
		shader_set_uniform_f(uniform_tre, _tr);
		shader_set_uniform_i(uniform_dir, _dr);
		
		for( var i = 0; i < _it; i++ ) {
			var it = i % 2;
			sBase = pp[it];
			sDraw = pp[!it];
			
			surface_set_target(sBase);
			draw_clear_alpha(0, 0);
			BLEND_OVERRIDE;
				shader_set_uniform_f(uniform_itr, i);
				draw_surface_safe(sDraw, 0, 0);
			BLEND_NORMAL;
			surface_reset_target();
		}
		
		shader_reset();
		
		surface_set_target(_outSurf);
			BLEND_OVERRIDE;
			draw_surface_safe(sBase, 0, 0);
			BLEND_NORMAL;
		surface_reset_target();
		
		surface_free(pp[0]);
		surface_free(pp[1]); 
		
		_outSurf = mask_apply(_data[0], _outSurf, _data[4], _data[5]);
		
		return _outSurf;
	}
}