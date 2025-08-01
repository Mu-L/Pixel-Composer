function Node_Iterator_Each_Input(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Loop Input";
	color = COLORS.node_blend_loop;
	is_group_io = true;
	
	manual_deletable = false;
	
	newOutput(0, nodeValue_Output("Value in", VALUE_TYPE.any,     0 ));
	// newOutput(1, nodeValue_Output("Index",    VALUE_TYPE.integer, 0 ));
	
	outputs[0].getValueDefault = method(outputs[0], outputs[0].getValueRecursive); // Get value from outside loop
	outputs[0].getValueRecursive = function(arr) {
		if(!variable_struct_exists(group, "iterated"))
			return outputs[0].getValueDefault(arr);
			
		var ind = group.iterated;
		var val = group.getInputData(0);
		var ivl = array_safe_get_fast(val, ind);
		
		arr[@ 0] = ivl;
		arr[@ 1] = group.inputs[0];
	}
	
	static getPreviewValues = function() {
		if(group == noone) return noone;
		
		switch(group.inputs[0].type) {
			case VALUE_TYPE.surface :
			case VALUE_TYPE.dynaSurface :
				break;
			default :
				return noone;
		}
		
		return group.getInputData(0);
	}
	
	static getGraphPreviewSurface = function() {
		if(group == noone) return noone;
		
		switch(group.inputs[0].type) {
			case VALUE_TYPE.surface :
			case VALUE_TYPE.dynaSurface :
				break;
			default :
				return noone;
		}
		
		return group.getInputData(0);
	}
	
	static onLoadGroup = function() {
		if(group == noone) destroy();
	}
}