enum MATH_OPERATOR {
	add,
	subtract,
	multiply,
	divide,
	power,
	root,
		
	sin,
	cos,
	tan,
		
	modulo,
		
	floor,
	ceiling,
	round,
	
	lerp,
	abs,
	
	clamp,
	snap,
}

#region create
	global.node_math_keys = [ "add", "subtract", "multiply", "divide", "power", "root", "+", "-", "*", "/", "^", 
	                          "sin", "cos", "tan", 
	                          "modulo", 
	                          "round", "ceiling", "floor", 
	                          "lerp", "abs", 
	                          "clamp", "snap" ];
	
	function Node_create_Math(_x, _y, _group = noone, _param = {}) {
		var query = struct_try_get(_param, "query", "");
		var node  = new Node_Math(_x, _y, _group).skipDefault();
	
		switch(query) { #region
			case "add" :		
			case "+" :		
								node.inputs[0].setValue(MATH_OPERATOR.add);		break;
			case "subtract" :	
			case "-" :	
								node.inputs[0].setValue(MATH_OPERATOR.subtract);	break;
			case "multiply" :	
			case "*" :	
								node.inputs[0].setValue(MATH_OPERATOR.multiply);	break;
			case "divide" :		
			case "/" :		
								node.inputs[0].setValue(MATH_OPERATOR.divide);	break;
			case "power" :		
			case "^" :		
								node.inputs[0].setValue(MATH_OPERATOR.power); 	break;
			case "root" :		node.inputs[0].setValue(MATH_OPERATOR.root);		break;
		
			case "sin" :		node.inputs[0].setValue(MATH_OPERATOR.sin);		break;
			case "cos" :		node.inputs[0].setValue(MATH_OPERATOR.cos);		break;
			case "tan" :		node.inputs[0].setValue(MATH_OPERATOR.tan);		break;
		
			case "modulo" :		node.inputs[0].setValue(MATH_OPERATOR.modulo);	break;
		
			case "floor" :		node.inputs[0].setValue(MATH_OPERATOR.floor); 	break;
			case "ceiling" :	node.inputs[0].setValue(MATH_OPERATOR.ceiling);	break;
			case "round" :		node.inputs[0].setValue(MATH_OPERATOR.round); 	break;
		
			case "lerp" :		node.inputs[0].setValue(MATH_OPERATOR.lerp);		break;
			case "abs" :		node.inputs[0].setValue(MATH_OPERATOR.abs);		break;
			
			case "clamp" :		node.inputs[0].setValue(MATH_OPERATOR.clamp);		break;
			case "snap" :		node.inputs[0].setValue(MATH_OPERATOR.snap);		break;
		} #endregion
	
		return node;
	}
#endregion

function Node_Math(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name		= "Math";
	color		= COLORS.node_blend_number;
	setDimension(96, 48);
	
	newInput(0, nodeValue_Enum_Scroll("Type", self,  0, [ 
			/* 0 -  9*/ "Add", "Subtract", "Multiply", "Divide", "Power", "Root", "Sin", "Cos", "Tan", "Modulo", 
			/*10 - 20*/ "Floor", "Ceil", "Round", "Lerp", "Abs", "Clamp", "Snap" ]))
		.rejectArray();
	
	newInput(1, nodeValue_Float("a", self, 0))
		.setVisible(true, true);
		
	newInput(2, nodeValue_Float("b", self, 0))
		.setVisible(true, true);
		
	newInput(3, nodeValue_Bool("Degree angle", self, true));
	
	newInput(4, nodeValue_Bool("To integer", self, false));
	
	newInput(5, nodeValue_Float("Amount", self, 0));
	
	input_display_list = [
		0, 1, 2, 5, 3, 4,
	]
		
	newOutput(0, nodeValue_Output("Result", self, VALUE_TYPE.float, 0));
	
	use_mod = 0;
	use_deg = false;
	
	static onValueUpdate = function(index = 0) {
		if(index != 0) return;
		
		var _type = inputs[0].getValue();
		
		switch(_type) {
			case MATH_OPERATOR.add :		setDisplayName("Add")        break;
			case MATH_OPERATOR.subtract :	setDisplayName("Subtract");	 break;
			case MATH_OPERATOR.multiply :	setDisplayName("Multiply");	 break;
			case MATH_OPERATOR.divide :		setDisplayName("Divide");    break;
			
			case MATH_OPERATOR.power :		setDisplayName("Power");     break;
			case MATH_OPERATOR.root :		setDisplayName("Root");      break;
			
			case MATH_OPERATOR.sin :		setDisplayName("Sin");       break;
			case MATH_OPERATOR.cos :		setDisplayName("Cos");       break;
			case MATH_OPERATOR.tan :		setDisplayName("Tan");       break;
			case MATH_OPERATOR.modulo :		setDisplayName("Modulo");    break;
			
			case MATH_OPERATOR.floor :		setDisplayName("Floor");     break;
			case MATH_OPERATOR.ceiling :	setDisplayName("Ceiling");   break;
			case MATH_OPERATOR.round :		setDisplayName("Round");     break;
			
			case MATH_OPERATOR.lerp :		setDisplayName("Lerp");      break;
			case MATH_OPERATOR.abs :		setDisplayName("Abs");       break;
			
			case MATH_OPERATOR.clamp :		setDisplayName("Clamp");     break;
			case MATH_OPERATOR.snap :		setDisplayName("Snap");      break;
		}
	}
	
	static _eval = function(a, b, c = 0) {
		switch(use_mod) {
			case MATH_OPERATOR.add :		return a + b;    
			case MATH_OPERATOR.subtract :	return a - b;
			case MATH_OPERATOR.multiply :	return a * b;
			case MATH_OPERATOR.divide :		return b == 0? 0 : a / b;
				
			case MATH_OPERATOR.power :		return power(a, b);
			case MATH_OPERATOR.root :		return b == 0? 0 : power(a, 1 / b);
			
			case MATH_OPERATOR.sin :		return sin(use_deg? degtorad(a) : a) * b;
			case MATH_OPERATOR.cos :		return cos(use_deg? degtorad(a) : a) * b;
			case MATH_OPERATOR.tan :		return tan(use_deg? degtorad(a) : a) * b;
			case MATH_OPERATOR.modulo :		return safe_mod(a, b);
			
			case MATH_OPERATOR.floor :		return floor(a);
			case MATH_OPERATOR.ceiling :	return ceil(a);
			case MATH_OPERATOR.round :		return round(a);
			
			case MATH_OPERATOR.lerp :		return lerp(a, b, c);
			case MATH_OPERATOR.abs :		return abs(a);
			
			case MATH_OPERATOR.clamp :		return clamp(a, b, c);
			case MATH_OPERATOR.snap :		return value_snap(a, b);
		}
		return 0;
	}
	
	static step = function() {
		var mode = getInputData(0);
		
		switch(mode) {
			case MATH_OPERATOR.sin :
			case MATH_OPERATOR.cos :
			case MATH_OPERATOR.tan :
				inputs[3].setVisible(true);
				break;
			default:
				inputs[3].setVisible(false);
				break;
		}
		
		switch(mode) {
			case MATH_OPERATOR.round :
			case MATH_OPERATOR.floor :
			case MATH_OPERATOR.ceiling :
				inputs[4].setVisible(true);
				
				var int = getInputData(4);
				if(int) outputs[0].setType(VALUE_TYPE.integer);
				else	outputs[0].setType(VALUE_TYPE.float);
				break;
			default:
				inputs[4].setVisible(false);
				
				outputs[0].setType(VALUE_TYPE.float);
				break;
		}
		
		inputs[5].setVisible(false);
		
		switch(mode) {
			case MATH_OPERATOR.add :
			case MATH_OPERATOR.subtract :
			case MATH_OPERATOR.multiply :
			case MATH_OPERATOR.divide :
			case MATH_OPERATOR.power :
			case MATH_OPERATOR.root :	
			case MATH_OPERATOR.modulo :	
				inputs[2].name = "b";
				
				inputs[2].setVisible(true, true);
				break;
				
			case MATH_OPERATOR.sin :
			case MATH_OPERATOR.cos :
			case MATH_OPERATOR.tan :
				inputs[2].name = "Amplitude";
				
				inputs[2].setVisible(true, true);
				break;
				
			case MATH_OPERATOR.floor :
			case MATH_OPERATOR.ceiling :
			case MATH_OPERATOR.round :
			case MATH_OPERATOR.abs :
				inputs[2].setVisible(false);
				break;
				
			case MATH_OPERATOR.lerp :
				inputs[2].name = "To";
				inputs[5].name = "Amount";
				
				inputs[2].setVisible(true, true);
				inputs[5].setVisible(true, true);
				break;
				
			case MATH_OPERATOR.clamp :
				inputs[2].name = "Min";
				inputs[5].name = "Max";
				
				inputs[2].setVisible(true, true);
				inputs[5].setVisible(true, true);
				break;
				
			case MATH_OPERATOR.snap :
				inputs[2].name = "Snap";
				
				inputs[2].setVisible(true, true);
				break;
				
			default: return;
		}
	}
	
	function evalArray(a, b, c = 0) {
		var _as = is_array(a);
		var _bs = is_array(b);
		var _cs = is_array(c);
		
		if(!_as && !_bs && !_cs)
			return _eval(a, b, c);
		
		if(!_as) a = [ a ];
		if(!_bs) b = [ b ];
		if(!_cs) c = [ c ];
		
		var al = array_length(a);
		var bl = array_length(b);
		var cl = array_length(c);
		
		var amo = max(al, bl, cl);
		var val = array_create(amo);
		
		for( var i = 0; i < amo; i++ ) 
			val[i] = evalArray( 
				array_safe_get(a, i,, ARRAY_OVERFLOW.loop), 
				array_safe_get(b, i,, ARRAY_OVERFLOW.loop),
				array_safe_get(c, i,, ARRAY_OVERFLOW.loop),
			);
		
		return val;
	}
	
	static update = function(frame = CURRENT_FRAME) {
		use_mod = getInputData(0);
		use_deg = getInputData(3);
		
		var a	= getInputData(1);
		var b	= getInputData(2);
		var c	= getInputData(5);
		
		var val = evalArray(a, b, c);
		outputs[0].setValue(val);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		var str = "";
		switch(getInputData(0)) {
			case MATH_OPERATOR.add :		str = "+";     break;
			case MATH_OPERATOR.subtract :	str = "-";     break;
			case MATH_OPERATOR.multiply :	str = "*";     break;
			case MATH_OPERATOR.divide :		str = "/";     break;
			case MATH_OPERATOR.power :		str = "pow";   break;
			case MATH_OPERATOR.root :		str = "root";  break;
			
			case MATH_OPERATOR.sin :		str = "sin";   break;
			case MATH_OPERATOR.cos :		str = "cos";   break;
			case MATH_OPERATOR.tan :		str = "tan";   break;
			case MATH_OPERATOR.modulo :		str = "mod";   break;
			
			case MATH_OPERATOR.floor :		str = "floor"; break;
			case MATH_OPERATOR.ceiling :	str = "ceil";  break;
			case MATH_OPERATOR.round :		str = "round"; break;
			
			case MATH_OPERATOR.lerp :		str = "lerp";  break;
			case MATH_OPERATOR.abs :		str = "abs";   break;
			
			case MATH_OPERATOR.clamp :		str = "clamp"; break;
			case MATH_OPERATOR.snap :		str = "snap";  break;
			default: return;
		}
		
		var bbox = drawGetBbox(xx, yy, _s);
		var ss	= string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss * 0.8, ss * 0.8, 0);
	}
}