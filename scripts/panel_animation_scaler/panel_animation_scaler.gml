function Panel_Animation_Scaler() : Panel_Linear_Setting() constructor {
	title = __txtx("anim_scale_title", "Animation Scaler");
	
	w = ui(380);
	scale_to = TOTAL_FRAMES;
	
	#region data
		properties = [
			new __Panel_Linear_Setting_Item(
				__txtx("anim_scale_target_frame_length", "Target frame length"),
				new textBox(TEXTBOX_INPUT.number, function(to) { scale_to = toNumber(to); }), 
				function() { return scale_to; },
			)
		];
		
		setHeight();
		h += ui(36);
		
		b_apply = button(function() { scale(); })
					.setIcon(THEME.accept_16, 0, COLORS._main_icon_dark);
	#endregion
	
	static scale = function() {
		var fac = scale_to / TOTAL_FRAMES;
		
		for (var k = 0, n = array_length(PROJECT.allNodes); k < n; k++) {
			var _node = PROJECT.allNodes[k];
			
			if(!_node || !_node.active) continue;
			
			for(var i = 0; i < array_length(_node.inputs); i++) {
				var in = _node.inputs[i];
				if(!in.is_anim) continue;
				for(var j = 0; j < array_length(in.animator.values); j++) {
					var t = in.animator.values[j];
					t.time = t.ratio * scale_to;
				}
			}
		}
		
		TOTAL_FRAMES = scale_to;
		close();
	}
	
	function drawContent(panel) { 
		drawSettings(panel); 
		
		var bs = ui(28);
		var bx = w - ui(8) - bs;
		var by = h - ui(8) - bs;
		
		b_apply.setFocusHover(pFOCUS, pHOVER);
		b_apply.register();
		b_apply.draw(bx, by, bs, bs, [ mx, my ], THEME.button_lime);
	}
}