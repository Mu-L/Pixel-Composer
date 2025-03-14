function Node_Move_Point(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name  = "Transform Point";
	color = COLORS.node_blend_number;
	
	setDimension(96, 48);
	
	newInput(0, nodeValue_Vec2("Point", self, [ 0, 0 ]))
		.setVisible(true, true);
		
	newInput(1, nodeValue_2("Anchor Point", self, [ .5, .5 ]))
		.setUnitRef(function() /*=>*/ {return DEF_SURF}, VALUE_UNIT.reference);
	
	newInput(2, nodeValue_2("Position",     self, [ 0, 0 ]));
	newInput(3, nodeValue_r("Rotation",     self, 0));
	newInput(4, nodeValue_2("Scale",        self, [ 1, 1 ]));
	
	newOutput(0, nodeValue_Output("Result", self, VALUE_TYPE.float, [ 0, 0 ]))
		.setDisplay(VALUE_DISPLAY.vector);
	
	input_display_list = [ 
		["Points",   false], 0, 1, 
		["Position", false], 2, 
		["Rotation", false], 3, 
		["Scale",    false], 4, 
	];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _anc = getSingleValue(1);
		var _px  = _x + _anc[0] * _s;
		var _py  = _y + _anc[1] * _s;
		
		var hv = inputs[2].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny); hover &= !hv;
		var hv = inputs[1].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny); hover &= !hv;
		
		var hv = inputs[3].drawOverlay(hover, active, _px, _py, _s, _mx, _my, _snx, _sny); hover &= !hv;
	}
	
	static processData = function(_output, _data, _output_index, _array_index = 0) {  
		var _pnt = [ _data[0][0], _data[0][1] ];
		var _anc = _data[1];
		
		var _pos = _data[2];
		var _rot = _data[3];
		var _sca = _data[4];
		
		point_rotate_array(_pnt, _anc, _rot);
		_pnt[0]  = _anc[0] + (_pnt[0] - _anc[0]) * _sca[0];
		_pnt[1]  = _anc[1] + (_pnt[1] - _anc[1]) * _sca[1];
		
		_pnt[0] += _pos[0];
		_pnt[1] += _pos[1];
		
		return _pnt;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_move_point, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}