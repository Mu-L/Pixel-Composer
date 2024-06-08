function Node_create_SVG_path(_x, _y, path) { #region
	if(!file_exists_empty(path)) return noone;
	
	var node = new Node_SVG(_x, _y, PANEL_GRAPH.getCurrentContext());
	node.inputs[| 0].setValue(path);
	node.doUpdate();
	return node;	
} #endregion

function Node_SVG(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "SVG";
	color = COLORS.node_blend_input;
	
	inputs[| 0]  = nodeValue("Path", self, JUNCTION_CONNECT.input, VALUE_TYPE.path, "")
		.setDisplay(VALUE_DISPLAY.path_load, { filter: "Scalable Vector Graphics|*.svg" });
		
	inputs[| 1]  = nodeValue("Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1);
		
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	outputs[| 1] = nodeValue("SVG Struct", self, JUNCTION_CONNECT.output, VALUE_TYPE.struct, {});
	
	outputs[| 2] = nodeValue("Path", self, JUNCTION_CONNECT.output, VALUE_TYPE.path, "")
		.setVisible(true, true);
	
	attribute_surface_depth();
	
	rawContent = noone;
	content    = {};
	edit_time  = 0;
	curr_path  = "";
	
	attributes.check_splice = true;
	attributes.file_checker = true;
	array_push(attributeEditors, [ "File Watcher", function() { return attributes.file_checker; }, 
		new checkBox(function() { attributes.file_checker = !attributes.file_checker; }) ]);
	
	on_drop_file = function(path) { #region
		inputs[| 0].setValue(path);
		
		if(readFile(path)) {
			doUpdate();
			return true;
		}
		
		return false;
	} #endregion
	
	function readFile(path) { #region
		curr_path = path;
		if(!file_exists_empty(path)) 
			return noone;
		
		edit_time = file_get_modify_s(path);
		var ext   = string_lower(filename_ext(path));
		var _name = filename_name_only(path);
		
		if(ext != ".svg") return;
		
		var _rawContent = file_text_read_all_lines(path);
		rawContent = SnapFromXML(_rawContent);
		content    = svg_parse(rawContent);
		
		return;
	} #endregion
	
	insp1UpdateTooltip  = __txt("Refresh");
	insp1UpdateIcon     = [ THEME.refresh_icon, 1, COLORS._main_value_positive ];
	
	static onInspector1Update = function() { #region
		readFile(path_get(getInputData(0)));
		triggerRender();
	} #endregion
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _scale   = getInputData(1);
		
		if(is_instanceof(content, SVG)) 
			content.drawOverlay(hover, active, _x, _y, _s * _scale, _mx, _my, _snx, _sny);
	}
	
	static step = function() { #region
		var path = path_get(getInputData(0));
		if(!file_exists_empty(path)) return;
		
		var _modi = file_get_modify_s(path);
		if(attributes.file_checker && _modi > edit_time) {
			readFile(path);
			triggerRender();
		}
	} #endregion
	
	static update = function(frame = CURRENT_FRAME) { #region
		var path = path_get(getInputData(0));
		if(path != curr_path)
			readFile(path);
		
		if(!is_instanceof(content, SVG)) return;
		outputs[| 1].setValue(path);
		
		var _scale   = getInputData(1);
		var _outsurf = outputs[| 0].getValue();
		
		var ww = content.width  * _scale;
		var hh = content.height * _scale;
		
	    _outsurf = surface_verify(_outsurf, ww, hh, attrDepth());
		
		surface_set_shader(_outsurf, noone);
			content.draw(_scale);
		surface_reset_shader();
		
		outputs[| 0].setValue(_outsurf);
		outputs[| 1].setValue(rawContent);
	} #endregion
}