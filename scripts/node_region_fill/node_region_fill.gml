#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Region_Fill", "Fill > Toggle",       "F", MOD_KEY.ctrl, function() /*=>*/ { GRAPH_FOCUS _n.inputs[3].setValue((_n.inputs[3].getValue() + 1) % 2); });
		addHotkey("Node_Region_Fill", "Fill Type > Toggle",  "F", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[8].setValue((_n.inputs[8].getValue() + 1) % 5); });
		addHotkey("Node_Region_Fill", "Inner Only > Toggle", "N", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[6].setValue((_n.inputs[6].getValue() + 1) % 2); });
	});
#endregion

function Node_Region_Fill(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Region Fill";
	
	newInput(4, nodeValueSeed());
	
	////- =Surfaces
	newInput(0, nodeValue_Surface( "Surface In" ));
	newInput(1, nodeValue_Surface( "Mask"       ));
	
	////- =Filter
	newInput(11, nodeValue_Bool(  "Color Filter", false    ));
	newInput( 5, nodeValue_Color( "Target Color", ca_white ));
	newInput( 6, nodeValue_Bool(  "Inner Only",   false    )).setTooltip("Only fill regions with surrounding pixels.");
	newInput(14, nodeValue_Bool(  "Expands",      true     )).setTooltip("Expands filled area to filtered pixels.");
	
	////- =Fill
	newInput(13, nodeValue_Slider(         "Threshold",      .1 ));
	newInput( 8, nodeValue_Enum_Scroll(    "Fill Type",       0, [ "Random", "Color map", "Texture map", "Texture Coord", "Texture Index" ]));
	newInput(15, nodeValue_Enum_Button(    "Source",          0, [ "Palette", "Gradient" ]));
	newInput( 2, nodeValue_Palette(        "Fill Palette" ));
	newInput(16, nodeValue_Gradient(       "Fill Gradient",  new gradientObject([ ca_black, ca_white ]) ));
	
	newInput( 9, nodeValue_Surface(        "Color Map"              ));
	newInput( 3, nodeValue_Bool(           "Fill",            true  ));
	newInput(10, nodeValue_Surface(        "Texture Map"            ));
	newInput(12, nodeValue_Rotation_Range( "Random Rotation", [0,0] ));
	
	////- =Render
	newInput(7, nodeValue_Enum_Scroll("Draw Original",  0, [ "None", "Above", "Behind" ]));
	
	// Inputs 17
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 4, 
		["Surfaces", false], 0, 1, 
		["Filter",   false, 11], 5, 6, 14, 
		["Fill",	 false], 13, 8, 15, 2, 16, 9, 10, 12, 
		["Render",	 false], 7, 
	];
	
	temp_surface = array_create(3);
		
	static processData = function(_outSurf, _data, _array_index) {
		#region data
			var _seed = _data[4];
			var _surf = _data[0];
			var _mask = _data[1];
			
			var _fclr = _data[11];
			var _targ = _data[ 5];
			var _innr = _data[ 6];
			var _expn = _data[14];
			
			var _thr  = _data[13];
			var _filt = _data[ 8];
			var _fsrc = _data[15];
			var _palt = _data[ 2];
			var _grad = _data[16];
			
			var _cmap = _data[ 9];
			var _tmap = _data[10];
			var _trot = _data[12]; 
			
			var _rnbg = _data[7];
			
			inputs[15].setVisible(_filt == 0);
			inputs[ 2].setVisible(_filt == 0 && _fsrc == 0);
			inputs[16].setVisible(_filt == 0 && _fsrc == 1);
			inputs[ 9].setVisible(_filt == 1,   _filt == 1);
			inputs[10].setVisible(_filt == 2,   _filt == 2);
			inputs[12].setVisible(_filt == 2 || _filt == 3);
			
			inputs[ 5].setVisible(true);
			inputs[ 6].setVisible(true);
		#endregion
		
		var _sw = surface_get_width_safe(_surf);
		var _sh = surface_get_height_safe(_surf)
		
		for( var i = 0, n = array_length(temp_surface); i < n; i++ ) {
			temp_surface[i] = surface_verify(temp_surface[i], _sw, _sh); 
			surface_clear(temp_surface[i]);
		}
		
		var base = 0;
		var cmap = temp_surface[0];
		
		if(_fclr) { // filter color
			
			surface_set_shader(temp_surface[1], sh_region_fill_init);
				shader_set_color("targetColor", _targ);
				shader_set_f("threshold",   _thr);
				
				draw_surface_safe(_surf);
			surface_reset_shader();
			
			#region inner region
				var amo  = _sw;
			
				if(_innr) {
					repeat( amo ) {
						surface_set_shader(temp_surface[base], sh_region_fill_inner);
							shader_set_f("dimension", _sw, _sh);
					
							draw_surface_safe(temp_surface[!base]);
						surface_reset_shader();
					
						base = !base;
					}
				
					surface_set_shader(temp_surface[2], sh_region_fill_inner_remove);
						draw_surface_safe(temp_surface[!base]);
					surface_reset_shader();
				
				} else {
					surface_set_shader(temp_surface[2], sh_region_fill_inner_remove);
						draw_surface_safe(temp_surface[1]);
					surface_reset_shader();
				}
			#endregion
			
			#region coordinate
				surface_set_shader(temp_surface[base], sh_region_fill_coordinate_init);
					draw_surface_safe(temp_surface[2]);
				surface_reset_shader();
				
				base = !base;
				var amo = _sw + _sh;
			
				repeat(amo) {
					surface_set_shader(temp_surface[base], sh_region_fill_coordinate);
						shader_set_f("dimension",   _sw, _sh);
						shader_set_surface("base",	temp_surface[2]);
						
						draw_surface_safe(temp_surface[!base]);
					surface_reset_shader();
				
					base = !base;
				}
				
				if(_expn) {
					surface_set_shader(temp_surface[base], sh_region_fill_border);
						shader_set_f("dimension",       _sw, _sh);
						shader_set_surface("original",	_surf);
					
						draw_surface_safe(temp_surface[!base]);
					surface_reset_shader();
					
					base = !base;
				}
				
				cmap = temp_surface[!base];
			#endregion
			
		} else {
			surface_set_shader(temp_surface[base], sh_region_fill_coordinate_all_init);
				draw_surface_safe(_surf);
			surface_reset_shader();
			
			base = !base;
			var amo = _sw + _sh;
			
			repeat( amo ) {
				surface_set_shader(temp_surface[base], sh_region_fill_coordinate_all);
					shader_set_f("dimension",   _sw, _sh);
					shader_set_f("threshold",   _thr);
					shader_set_surface("base",	_surf);
					
					draw_surface_safe(temp_surface[!base]);
				surface_reset_shader();
				
				base = !base;
			}
			
			cmap = temp_surface[!base];
		}
		
		surface_set_target(_outSurf);
			DRAW_CLEAR
			
			if(_rnbg == 2) draw_surface_safe(_surf); // render original
			
			switch(_filt) {
				case 0 :  // Random colors
					
					shader_set(sh_region_fill_color);
						shader_set_i("useMask", is_surface(_mask));
						shader_set_surface("mask", _mask);
						shader_set_palette(_palt, "colors", "colorAmount");
						_grad.shader_submit();
						
						shader_set_i("type", _fsrc);
						shader_set_f("seed", _seed);
						
						draw_surface_safe(cmap);
					shader_reset();
					break;
						
				case 1 : // Color Map
					shader_set(sh_region_fill_map);
						shader_set_i("useMask", is_surface(_mask));
						shader_set_surface("mask", _mask);
						shader_set_surface("colorMap",	_cmap);
						
						draw_surface_safe(cmap);
					shader_reset();
					break;
						
				case 2 : // Texture Map
					shader_set(sh_region_fill_rg_map);
						shader_set_i("useMask", is_surface(_mask));
						shader_set_surface("mask", _mask);
						shader_set_surface("textureMap", _tmap);
						shader_set_2("rotationRandom", [degtorad(_trot[0]), degtorad(_trot[1])]);
						shader_set_f("seed", _seed)
						
						draw_surface_safe(cmap);
					shader_reset();
					break;
				
				case 3 : // Texture Map
					shader_set(sh_region_fill_rg_coord);
						shader_set_i("useMask", is_surface(_mask));
						shader_set_surface("mask", _mask);
						shader_set_2("rotationRandom", [degtorad(_trot[0]), degtorad(_trot[1])]);
						shader_set_f("seed", _seed)
						
						draw_surface_safe(cmap);
					shader_reset();
					break;
					
				case 4 : // Texture Index
					shader_set(sh_region_fill_rg_index);
						shader_set_i("useMask", is_surface(_mask));
						shader_set_surface("mask", _mask);
						
						draw_surface_safe(cmap);
					shader_reset();
					break;
			}
				
			if(_rnbg == 1) draw_surface_safe(_surf); // render original
				
		surface_reset_target();
		
		return _outSurf;
	}
}