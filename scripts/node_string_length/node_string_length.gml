function Node_String_Length(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Text Length";
	previewable   = false;
	
	w = 96;
	
	inputs[| 0] = nodeValue("Text", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "")
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, ["Character", "Word"]);
	
	outputs[| 0] = nodeValue("Text", self, JUNCTION_CONNECT.output, VALUE_TYPE.text, "");
	
	function process_data(_output, _data, _index = 0) { 
		if(_data[1] == 0)
			return string_length(_data[0]);
		else 
			return array_length(string_splice(_data[0], " "));
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		draw_set_text(f_h5, fa_center, fa_center, COLORS._main_text);
		var str = outputs[| 0].getValue();
		var bbox = drawGetBbox(xx, yy, _s);
		var ss	= string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	}
}