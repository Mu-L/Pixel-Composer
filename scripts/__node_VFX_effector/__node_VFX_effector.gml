enum FORCE_TYPE {
	Wind,
	Accelerate,
	Attract,
	Repel,
	Vortex,
	Turbulence,
	Destroy
}

function Node_VFX_effector(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name   = "Effector";
	color  = COLORS.node_blend_vfx;
	icon   = THEME.vfx;
	reloop = true;
	
	manual_ungroupable	 = false;
	node_draw_icon       = s_node_vfx_accel;

	setDimension(96, 48);
	seed  = 1;
	
	newInput(0, nodeValue_Particle("Particles", self, -1 ))
		.setVisible(true, true);
	
	newInput(1, nodeValue_Area("Area", self, DEF_AREA))
		.rejectArray();
	
	newInput(2, nodeValue_Curve("Falloff", self, CURVE_DEF_01 ))
		.rejectArray();
	
	newInput(3, nodeValue_Float("Falloff distance", self, 4 ))
		.rejectArray();
	
	newInput(4, nodeValue_Vec2("Effect Vector", self, [ -1, 0 ] ))
		.rejectArray();
	
	newInput(5, nodeValue_Float("Strength", self, 1 ))
		.rejectArray();
	
	newInput(6, nodeValue_Rotation_Range("Rotate particle", self, [ 0, 0 ] ))
		.rejectArray();
	
	newInput(7, nodeValue_Vec2_Range("Scale particle", self, [ 0, 0, 0, 0 ] , { linked : true }))
		.rejectArray();
	
	newInput(8, nodeValueSeed(self))
		.rejectArray();
		
	effector_input_length = array_length(inputs);
		
	input_display_list = [ 0,
		["Area",	false], 1, 2, 3,
		["Effect",	false], 8, 4, 5, 6, 7,
	];
	
	newOutput(0, nodeValue_Output("Particles", self, VALUE_TYPE.particle, -1 ));
	
	UPDATE_PART_FORWARD
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		inputs[1].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
		
		var area = getInputData(1);
		var cx = _x + area[0] * _s;
		var cy = _y + area[1] * _s;
		var cw = area[2] * _s;
		var ch = area[3] * _s;
		var cs = area[4];
		
		var fall = getInputData(3) * _s;
		var x0 = cx - cw + fall;
		var x1 = cx + cw - fall;
		var y0 = cy - ch + fall;
		var y1 = cy + ch - fall;
		
		if(x1 > x0 && y1 > y0) {
			draw_set_color(COLORS._main_accent);
			draw_set_alpha(0.5);
			switch(cs) {
				case AREA_SHAPE.elipse :	draw_ellipse_dash(cx, cy, cw + fall * 2, ch + fall * 2); break;	
				case AREA_SHAPE.rectangle :	draw_rectangle_dashed(x0, y0, x1, y1); break;	
			}
			draw_set_alpha(1);
		}
		
		x0 = cx - cw - fall;
		x1 = cx + cw + fall;
		y0 = cy - ch - fall;
		y1 = cy + ch + fall;
		
		if(x1 > x0 && y1 > y0) {
			draw_set_color(COLORS._main_accent);
			draw_set_alpha(0.5);
			switch(cs) {
				case AREA_SHAPE.elipse :	draw_ellipse_dash(cx, cy, cw + fall * 2, ch + fall * 2); break;	
				case AREA_SHAPE.rectangle :	draw_rectangle_dashed(x0, y0, x1, y1); break;	
			}
			draw_set_alpha(1);
		}
	}
	
	function reset() {
		resetSeed();
	}
	
	static resetSeed = function() {
		seed = getInputData(8);
	}
	
	function onAffect(part, str) {}
	
	function affect(part) {
		if(!part.active) return;
		
		var _area = getInputData(1);
		var _fall = getInputData(2);
		var _fads = getInputData(3);
		
		var _area_x = _area[0];
		var _area_y = _area[1];
		var _area_w = _area[2];
		var _area_h = _area[3];
		var _area_t = _area[4];
		
		var _area_x0 = _area_x - _area_w;
		var _area_x1 = _area_x + _area_w;
		var _area_y0 = _area_y - _area_h;
		var _area_y1 = _area_y + _area_h;
		
		random_set_seed(part.seed + seed);
		
		var str = 0, in, _dst;
		var pv = part.getPivot();
		
		if(_area_t == AREA_SHAPE.rectangle) {
			in = point_in_rectangle(pv[0], pv[1], _area_x0, _area_y0, _area_x1, _area_y1)
			_dst = min(	distance_to_line(pv[0], pv[1], _area_x0, _area_y0, _area_x1, _area_y0), 
						distance_to_line(pv[0], pv[1], _area_x0, _area_y1, _area_x1, _area_y1), 
						distance_to_line(pv[0], pv[1], _area_x0, _area_y0, _area_x0, _area_y1), 
						distance_to_line(pv[0], pv[1], _area_x1, _area_y0, _area_x1, _area_y1));
		} else if(_area_t == AREA_SHAPE.elipse) {
			var _dirr = point_direction(_area_x, _area_y, pv[0], pv[1]);
			var _epx = _area_x + lengthdir_x(_area_w, _dirr);
			var _epy = _area_y + lengthdir_y(_area_h, _dirr);
			
			in   = point_distance(_area_x, _area_y, pv[0], pv[1]) < point_distance(_area_x, _area_y, _epx, _epy);
			_dst = point_distance(pv[0], pv[1], _epx, _epy);
		}
		
		if(_dst <= _fads) {
			var inf = in? 0.5 + _dst / _fads : 0.5 - _dst / _fads;
			str = eval_curve_x(_fall, clamp(inf, 0., 1.));
		} else if(in)
			str = 1;
		
		if(str == 0) return;
		
		onAffect(part, str);
	}
	
	static update = function(frame = CURRENT_FRAME) {
		var val = getInputData(0);
		outputs[0].setValue(val);
		if(val == -1) return;
		
		if(!is_array(val) || array_length(val) == 0) return;
		if(!is_array(val[0])) val = [ val ];
		for( var i = 0, n = array_length(val); i < n; i++ )
		for( var j = 0; j < array_length(val[i]); j++ ) {
			affect(val[i][j]);
		}
		
		var jun = outputs[0];
		for(var j = 0; j < array_length(jun.value_to); j++) {
			if(jun.value_to[j].value_from == jun)
				jun.value_to[j].node.doUpdate();
		}
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(node_draw_icon, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
	
	static getPreviewingNode = function() { return is(inline_context, Node_VFX_Group_Inline)? inline_context.getPreviewingNode() : self; }
	static getPreviewValues  = function() { return is(inline_context, Node_VFX_Group_Inline)? inline_context.getPreviewValues()  : self; }
}