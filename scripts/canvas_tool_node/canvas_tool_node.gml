function canvas_tool_node(canvas, node) : canvas_tool() constructor {
	
	self.canvas = canvas;
	self.node   = node;
	override = true;
	
	applySelection = canvas.tool_selection.is_selected;
	
	destiSurface  = applySelection? canvas.tool_selection.selection_surface : canvas._canvas_surface;
	if(!is_surface(destiSurface)) {
		canvas.nodeTool = noone;
		return;
	}
	
	sw = surface_get_width(destiSurface);
	sh = surface_get_height(destiSurface);
	targetSurface = surface_create(sw, sh);
	maskedSurface = surface_create(sw, sh);
	
	surface_set_shader(targetSurface, noone);
		draw_surface_safe(destiSurface);
	surface_reset_shader();
	
	static destroy = function() {
		canvas.nodeTool = noone;
		if(nodeObject != noone)
			nodeObject.cleanUp();
		
		surface_free(targetSurface);
		surface_free(maskedSurface);
	}
	
	nodeObject = node.build(0, 0);
	
	if(nodeObject == noone) {
		destroy();
		return;
	}
	
	inputJunction  = noone;
	outputJunction = noone;
	
	for( var i = 0, n = ds_list_size(nodeObject.inputs); i < n; i++ ) {
		var _in = nodeObject.inputs[| i];
		if(_in.type == VALUE_TYPE.surface || _in.name == "Dimension") {
			inputJunction = _in;
			break;
		}
	}
	
	for( var i = 0, n = ds_list_size(nodeObject.outputs); i < n; i++ ) {
		var _in = nodeObject.outputs[| i];
		if(_in.type == VALUE_TYPE.surface) {
			outputJunction = _in;
			break;
		}
	}
	
	if(outputJunction == noone) {
		destroy();
		return;
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	function apply() {
		
		if(applySelection) {
			surface_free(canvas.tool_selection.selection_surface);
			canvas.tool_selection.selection_surface = maskedSurface;
			canvas.tool_selection.apply();
			
		} else {
			canvas.storeAction();
			canvas.setCanvasSurface(maskedSurface);
			canvas.surface_store_buffer();
		}
		
		PANEL_PREVIEW.tool_current = noone;
		canvas.nodeTool = noone;
		surface_free_safe(targetSurface);
	}
	
	function step(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		
		var _px, _py, _pw, _ph;
		
		if(applySelection) {
			_px = canvas.tool_selection.selection_position[0];
			_py = canvas.tool_selection.selection_position[1];
			_pw = canvas.tool_selection.selection_size[0];
			_ph = canvas.tool_selection.selection_size[1];
			
		} else {
			_px = 0;
			_py = 0;
			_pw = canvas.attributes.dimension[0];
			_ph = canvas.attributes.dimension[1];
			
		}
		
		var _dx = _x + _px * _s;
		var _dy = _y + _py * _s;
		
		if(inputJunction) {
			if(inputJunction.type == VALUE_TYPE.surface)
				inputJunction.setValue(targetSurface);
			else if(inputJunction.name == "Dimension")
				inputJunction.setValue([ sw, sh ]);
		}
		nodeObject.update();
		
		var _surf = outputJunction.getValue();
			
		if(applySelection) {
			maskedSurface = surface_verify(maskedSurface, sw, sh);
			surface_set_shader(maskedSurface);
				draw_surface(_surf, 0, 0);
				BLEND_MULTIPLY
					draw_surface(canvas.tool_selection.selection_mask, 0, 0);
				BLEND_NORMAL
			surface_reset_shader();
			
		} else
			maskedSurface = _surf;
			
		draw_surface_ext_safe(maskedSurface, _dx, _dy, _s, _s);
		
		     if(mouse_press(mb_left, active))  { apply();	MOUSE_BLOCK = true; }
		else if(mouse_press(mb_right, active)) { destroy(); MOUSE_BLOCK = true; }
	}
	
}