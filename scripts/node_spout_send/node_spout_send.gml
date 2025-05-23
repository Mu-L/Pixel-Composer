function Node_Spout_Send(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name	= "Spout Send";
	
	newInput(0, nodeValue_Text("Sender name", "PixelComposer"));
	
	newInput(1, nodeValue_Surface("Surface"));
	
	newOutput(0, nodeValue_Output("Surface", VALUE_TYPE.surface, noone))
		.setVisible(false);
	
	spoutIndex = spoutSenderInit();
	if(spoutIndex == noone) 
		noti_warning("Spout initialize error", noone, self);
	
	surf_buff = buffer_create(1, buffer_grow, 1);
	
	static update = function() {
		if(spoutIndex == noone) return;
		
		var _name = inputs[0].getValue();
		var _surf = inputs[1].getValue();
		
		if(!is_surface(_surf)) return;
		
		var _sw = surface_get_width_safe(_surf);
		var _sh = surface_get_height_safe(_surf);
		
		buffer_resize(surf_buff, _sw * _sh * 4);
		buffer_get_surface(surf_buff, _surf, 0);
		
		spoutSetSenderName(spoutIndex, _name);
		spoutSendPixels(spoutIndex, buffer_get_address(surf_buff), _sw, _sh);
		
		outputs[0].setValue(_surf);
	}
}