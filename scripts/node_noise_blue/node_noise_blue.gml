function Node_Noise_Blue(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Blue Noise";
	
	newInput(0, nodeValue_Dimension());
	
	newInput(1, nodeValueSeed());
	
	newInput(2, nodeValue_Surface("Mask"));
	
	input_display_list = [
		["Output",	false], 0, 2, 
		["Noise",	false], 1, 
	];
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	attribute_surface_depth();
	
	temp_surface = [ noone, noone ];
	
	static processData = function(_outSurf, _data, _array_index) {
		var _dim = _data[0];
		var _sed = _data[1];
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		
		surface_set_shader(_outSurf, sh_noise_blue_interpret);
			shader_set_f("seed", _sed);
			draw_empty();
		surface_reset_shader();
		
		_outSurf = mask_apply_empty(_outSurf, _data[input_mask_index]);
		return _outSurf;
	}
}