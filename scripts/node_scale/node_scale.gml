function Node_Scale(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Scale";
	dimension_index = -1;
	
	manage_atlas = false;
	
	newInput(0, nodeValue_Surface("Surface in", self));
	
	newInput(1, nodeValue_Float("Scale", self, 1));
	
	newInput(2, nodeValue_Enum_Button("Mode", self,  0, [ "Upscale", "Scale to fit" ]));
	
	newInput(3, nodeValue_Vec2("Target dimension", self, DEF_SURF));
	
	newInput(4, nodeValue_Bool("Active", self, true));
		active_index = 4;
		
	newInput(5, nodeValue_Bool("Scale atlas position", self, true));
		
	newOutput(0, nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone));
	
	input_display_list = [ 4, 
		["Surfaces", true], 0,
		["Scale",	false], 2, 1, 3, 5, 
	];
	
	attribute_surface_depth();
	attribute_interpolation();
	
	static step = function() {
		var _surf = getSingleValue(0);
		
		var _atlas = is_instanceof(_surf, SurfaceAtlas);
		inputs[5].setVisible(_atlas);
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var surf  = _data[0];
		var scale = _data[1];
		var mode  = _data[2];
		var targ  = _data[3];
		var _atlS = _data[5];
		var cDep  = attrDepth();
		
		inputs[1].setVisible(mode == 0);
		inputs[3].setVisible(mode == 1);
		
		var isAtlas = is_instanceof(surf, SurfaceAtlas);
		if(isAtlas && !is_instanceof(_outSurf, SurfaceAtlas))
			_outSurf = _data[0].clone(true);
		var _surf = isAtlas? _outSurf.getSurface() : _outSurf;
		
		var ww, hh, scx = 1, scy = 1;
		switch(mode) {
			case 0 :
				scx = scale;
				scy = scale;
				ww	= scale * surface_get_width_safe(surf);
				hh	= scale * surface_get_height_safe(surf);
				break;
			case 1 : 
				scx = targ[0] / surface_get_width_safe(surf);
				scy = targ[1] / surface_get_height_safe(surf);
				ww	= targ[0];
				hh	= targ[1];
				break;
		}
		
		_surf = surface_verify(_surf, ww, hh, cDep);
		
		surface_set_shader(_surf);
		shader_set_interpolation(_data[0]);
		draw_surface_stretched_safe(_data[0], 0, 0, ww, hh);
		surface_reset_shader();
		
		if(isAtlas) {
			if(_atlS) {
				_outSurf.x = surf.x * scx;
				_outSurf.y = surf.y * scy;
			} else {
				_outSurf.x = surf.x;
				_outSurf.y = surf.y;
			}
			
			_outSurf.setSurface(_surf);
		} else 
			_outSurf = _surf;
		
		return _outSurf;
	}
}