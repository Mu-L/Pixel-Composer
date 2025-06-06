#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Blur", "Size > Set",  KEY_GROUP.numeric, MOD_KEY.none, function(val) /*=>*/ { GRAPH_FOCUS_NUMBER _n.inputs[1].setValue(KEYBOARD_NUMBER); });
	});
#endregion

function Node_Blur(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Blur";
	
	newActiveInput(7);
	newInput(8, nodeValue_Toggle("Channel", 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	////- =Surfaces
	
	newInput(0, nodeValue_Surface( "Surface In"));
	newInput(5, nodeValue_Surface( "Mask"));
	newInput(6, nodeValue_Slider(  "Mix", 1));
	__init_mask_modifier(5, 9); // inputs 9, 10
	
	////- =Blur
	
	newInput( 1, nodeValue_Int("Size", 3)).setUnitRef(function(i) /*=>*/ {return getDimension(i)}).setValidator(VV_min(0))
	newInput( 2, nodeValue_Enum_Scroll("Oversample mode",  0, [ "Empty", "Clamp", "Repeat" ]));
	newInput( 3, nodeValue_Bool(  "Override color",        false)).setTooltip("Replace all color while keeping the alpha. Used to\nfix grey outline when bluring transparent pixel.");
	newInput( 4, nodeValue_Color( "Color",                 ca_black));
	newInput(11, nodeValue_Bool(  "Gamma Correction",      false));
	
	////- =Directional
	
	newInput(12, nodeValue_Slider(   "Aspect Ratio", 1));
	newInput(13, nodeValue_Rotation( "Direction",    0));
	
	// inputs 14
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 7, 8, 
		["Surfaces",	 true],	0, 5, 6, 9, 10, 
		["Blur",		false],	1, 3, 4, 11, 
		["Directional",	 true],	12, 13, 
	];
	
	temp_surface = [ noone, noone ];
	
	attribute_surface_depth();
	attribute_oversample();
	surface_blur_init();
	
	static processData = function(_outSurf, _data, _array_index) {	
		var _surf  = _data[0];
		var _size  = min(128, _data[1]);
		var _clamp = getAttribute("oversample");
		var _isovr = _data[3];
		var _mask  = _data[5];
		var _mix   = _data[6];
		var _overc = _isovr? _data[4] : noone;
		var _gam   = _data[11];
		var _aspc  = _data[12];
		var _dirr  = _data[13];
		
		inputs[4].setVisible(_isovr);
		
		if(!is_surface(_surf)) return _outSurf;
		var format = surface_get_format(_surf);
		var _sw    = surface_get_width_safe(_surf);
		var _sh    = surface_get_height_safe(_surf);
		
		for(var i = 0; i < 2; i++) 
			temp_surface[i] = surface_verify(temp_surface[i], _sw, _sh, format);	
		
		BLEND_OVERRIDE
		gpu_set_tex_filter(true);
		
		surface_set_target(temp_surface[0]);
			draw_clear_alpha(c_white, false);
			
			shader_set(sh_blur_gaussian);
			shader_set_f("dimension", [ _sw, _sh ]);
			shader_set_f("weight",    __gaussian_get_kernel(_size));
			
			shader_set_i("sampleMode", _clamp);
			shader_set_i("size",       _size);
			shader_set_i("horizontal", 1);
			shader_set_i("gamma",      _gam);
			
			shader_set_i("overrideColor", _overc != noone);
			shader_set_f("overColor",     colToVec4(_overc));
			shader_set_f("angle",         degtorad(_dirr));
			
			draw_surface_safe(_surf);
			shader_reset();
		surface_reset_target();
		
		surface_set_target(temp_surface[1]);
			draw_clear_alpha(c_white, false);
			
			var _size_v = round(_size * _aspc);
			
			shader_set(sh_blur_gaussian);
			shader_set_f("weight",    __gaussian_get_kernel(_size_v));
			shader_set_i("size",       _size_v);
			shader_set_i("horizontal", 0);
			
			draw_surface_safe(temp_surface[0]);
			shader_reset();
		surface_reset_target();
		
		gpu_set_tex_filter(false);
		
		surface_set_target(_outSurf);
			draw_clear_alpha(_isovr? _overc : 0, 0);
			draw_surface_safe(temp_surface[1]);
		surface_reset_target();
		BLEND_NORMAL
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _mask, _mix);
		_outSurf = channel_apply(_data[0], _outSurf, _data[8]);
		
		return _outSurf;
	}
}