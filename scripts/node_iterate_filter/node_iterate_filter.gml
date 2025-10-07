function Node_Iterate_Filter(_x, _y, _group = noone) : Node_Iterator(_x, _y, _group) constructor {
	name  = "Filter Array";
	
	newInput(0, nodeValue("Array", self, CONNECT_TYPE.input, VALUE_TYPE.any, [] ))
		.setVisible(true, true);
	
	newOutput(0, nodeValue_Output("Array", VALUE_TYPE.any, noone ));
	
	custom_input_index  = array_length(inputs);
	custom_output_index = array_length(inputs);
	
	if(NODE_NEW_MANUAL) {
		var input  = nodeBuild("Node_Iterator_Filter_Input", -256, -32, self);
		var output = nodeBuild("Node_Iterator_Filter_Output", 256, -32, self);
		
		output.inputs[0].setFrom(input.outputs[0]);
	}
	
	static step = function() {
		var type = inputs[0].value_from == noone? VALUE_TYPE.any : inputs[0].value_from.type;
		inputs[0].setType(type);
	}
	
	static doInitLoop = function() {
		var arrIn  = getInputData(0);
		var arrOut = outputs[0].getValue();
		
		var _int = noone;
		var _oup = noone;
		
		for( var i = 0, n = array_length(nodes); i < n; i++ ) {
			var _n = nodes[i];
			
			if(is(_n, Node_Iterator_Filter_Input))  _int = _n;
			if(is(_n, Node_Iterator_Filter_Output)) _oup = _n;
		}
		
		if(_int == noone) {
			noti_warning("Filter Array: Input node not found.", noone, self);
			return;
		}
		
		if(_oup == noone) {
			noti_warning("Filter Array: Output node not found.", noone, self);
			return;
		}
		
		var _ofr = _oup.inputs[0].value_from;
		var _imm = _ofr && is(_ofr.node, Node_Iterator_Filter_Input);
		
		if(!_imm) surface_array_free(arrOut);
		outputs[0].setValue([])
	}
	
	static getIterationCount = function() {
		var arrIn = getInputData(0);
		var maxIter = is_array(arrIn)? array_length(arrIn) : 0;
		if(!is_real(maxIter)) maxIter = 1;
		
		return maxIter;
	}
}