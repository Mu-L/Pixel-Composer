/// @description init
if !ready exit;

#region destroy
	selector.interactable = interactable;
	if(selector.dropper_active) exit;
	
	if(sHOVER && !point_in_rectangle(mouse_mx, mouse_my, dialog_x, dialog_y, dialog_x + dialog_w, dialog_y + dialog_h)) {
		if(destroy_on_click_out && mouse_press(mb_left))
			instance_destroy(self);
	}
	doDrag();
	
	if(sFOCUS && WIDGET_CURRENT == undefined) {
		if(keyboard_check_pressed(vk_enter))  { onApply(selector.current_color); instance_destroy(); }
		if(keyboard_check_pressed(vk_escape)) { onApply(previous_color); instance_destroy(); }
	}
#endregion