function Node_VFX_Variable(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "VFX Variable";
	color = COLORS.node_blend_vfx;
	icon  = THEME.vfx;
	previewable = false;
	node_draw_icon = s_node_vfx_variable;
	
	w = 96;
	h = 80;
	min_h = h;
	
	inputs[| 0] = nodeValue("Particles", self, JUNCTION_CONNECT.input, VALUE_TYPE.particle, -1 )
		.setVisible(true, true);
	
	input_display_list = [ 0 ];
	
	outputs[| 0] = nodeValue("Positions", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, [] )
		.setDisplay(VALUE_DISPLAY.vector)
		.setVisible(false);
	
	outputs[| 1] = nodeValue("Scales", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, [] )
		.setDisplay(VALUE_DISPLAY.vector)
		.setVisible(false);
	
	outputs[| 2] = nodeValue("Rotations", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0 )
		.setVisible(false);
	
	outputs[| 3] = nodeValue("Blending", self, JUNCTION_CONNECT.output, VALUE_TYPE.color, 0 )
		.setVisible(false);
	
	outputs[| 4] = nodeValue("Alpha", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0 )
		.setVisible(false);
	
	outputs[| 5] = nodeValue("Life", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0 )
		.setVisible(false);
	
	outputs[| 6] = nodeValue("Max life", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0 )
		.setVisible(false);
	
	outputs[| 7] = nodeValue("Surface", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone )
		.setVisible(false);
	
	outputs[| 8] = nodeValue("Velocity", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, [] )
		.setDisplay(VALUE_DISPLAY.vector)
		.setVisible(false);
	
	static update = function(frame = ANIMATOR.current_frame) {
		var parts = inputs[| 0].getValue();
		if(!is_array(parts)) return;
		
		var _val = [];
		
		for( var i = 0; i < ds_list_size(outputs); i++ )
			_val[i] = array_create(array_length(parts));
		
		for( var i = 0; i < array_length(parts); i++ ) {
			var part = parts[i];
			
			if(outputs[| 0].visible) _val[0][i] = [part.x,   part.y];
			if(outputs[| 1].visible) _val[1][i] = [part.scx, part.scy];
			if(outputs[| 2].visible) _val[2][i] = part.rot;
			if(outputs[| 3].visible) _val[3][i] = part.blend;
			if(outputs[| 4].visible) _val[4][i] = part.alp;
			if(outputs[| 5].visible) _val[5][i] = part.life;
			if(outputs[| 6].visible) _val[6][i] = part.life_total;
			if(outputs[| 7].visible) _val[7][i] = part.surf;
			if(outputs[| 8].visible) _val[8][i] = [part.sx, part.sy];
		}
		
		for( var i = 0; i < ds_list_size(outputs); i++ )
			if(outputs[| i].visible) outputs[| i].setValue(_val[i]);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(node_draw_icon, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}