function Node_Noise_Bubble(_x, _y, _group = noone) : Node_Shader_Generator(_x, _y, _group) constructor {
	name   = "Bubble Noise";
	shader = sh_noise_bubble;
	
	newInput(1, nodeValue_Float("Density", self, 0.5 ))
		.setDisplay(VALUE_DISPLAY.slider);
		addShaderProp(SHADER_UNIFORM.float, "density");
		
	newInput(2, nodeValueSeed(self));
		addShaderProp(SHADER_UNIFORM.float, "seed");
				
	newInput(3, nodeValue_Slider_Range("Scale", self, [ 0.5, 0.8 ] ));
		addShaderProp(SHADER_UNIFORM.float, "scale");
				
	newInput(4, nodeValue_Float("Thickness", self, 0 ))
		.setDisplay(VALUE_DISPLAY.slider);
		addShaderProp(SHADER_UNIFORM.float, "thickness");
		
	newInput(5, nodeValue_Enum_Button("Mode", self,  0 , [ "Line", "Fill" ] ));
		addShaderProp(SHADER_UNIFORM.integer, "mode");
		
	newInput(6, nodeValue_Slider_Range("Opacity", self, [ 0., 1. ] ));
		addShaderProp(SHADER_UNIFORM.float, "alpha");
		
	newInput(7, nodeValue_Enum_Scroll("Blending", self,  0 , [ "Max", "Add" ] ));
		addShaderProp(SHADER_UNIFORM.integer, "render");
		
	input_display_list = [ 2, 
		["Output", 	 true],	0, 
		["Noise",	false],	1, 3, 
		["Render",	false], 5, 4, 6, 7, 
	];
}