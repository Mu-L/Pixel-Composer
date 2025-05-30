#region mouse global
	globalvar CURSOR, CURSOR_LOCK, CURSOR_IS_LOCK, CURSOR_LOCK_X, CURSOR_LOCK_Y;
	globalvar MOUSE_WRAP, MOUSE_WRAPPING, MOUSE_BLOCK, _MOUSE_BLOCK;
	globalvar MOUSE_POOL;
	
	globalvar MOUSE_WHEEL,  MOUSE_WHEEL_H, __MOUSE_WHEEL_HOOK;
	globalvar MOUSE_PAN_X,  MOUSE_PAN_Y;
	globalvar MOUSE_ZOOM_X, MOUSE_ZOOM_Y;
	globalvar MOUSE_PAN;
	
	MOUSE_WRAP     = false;
	MOUSE_WRAPPING = false;
	MOUSE_BLOCK    = false;
	_MOUSE_BLOCK   = false;
	PEN_RELEASED   = false;
	MOUSE_POOL = {
		lclick: false, lpress: false, lrelease: false,
		rclick: false, rpress: false, rrelease: false,
		mclick: false, mpress: false, mrelease: false,
	}
	
	MOUSE_WHEEL      = 0;
	MOUSE_WHEEL_H    = 0;
	__MOUSE_WHEEL_HOOK = false;
	
	MOUSE_PAN_X   = 0;
	MOUSE_PAN_Y   = 0;
	MOUSE_ZOOM_X  = 0;
	MOUSE_ZOOM_Y  = 0;
	MOUSE_PAN     = true;
	
	#macro MOUSE_MOVED (window_mouse_get_delta_x() != 0 || window_mouse_get_delta_y() != 0)
	
	function setMouseWrap() { INLINE MOUSE_WRAP = true; }
#endregion

function global_mouse_pool_init() {
	MOUSE_POOL.lclick = mouse_check_button(mb_left);
	MOUSE_POOL.rclick = mouse_check_button(mb_right);
	MOUSE_POOL.mclick = mouse_check_button(mb_middle);
	
	MOUSE_POOL.lpress = mouse_check_button_pressed(mb_left);
	MOUSE_POOL.rpress = mouse_check_button_pressed(mb_right);
	MOUSE_POOL.mpress = mouse_check_button_pressed(mb_middle);
	
	MOUSE_POOL.lrelease = mouse_check_button_released(mb_left);
	MOUSE_POOL.rrelease = mouse_check_button_released(mb_right);
	MOUSE_POOL.mrelease = mouse_check_button_released(mb_middle);
}

function mouse_step() {
	MOUSE_WHEEL      = 0;
	if(mouse_wheel_up())   MOUSE_WHEEL =  1;
	if(mouse_wheel_down()) MOUSE_WHEEL = -1;
	
	MOUSE_WHEEL_H    = 0;//mouse_wheel_get_h();
	
	// MOUSE_PAN_X   = mouse_pan_x();
	// MOUSE_PAN_Y   = mouse_pan_y();
	// MOUSE_ZOOM_X  = mouse_zoom_x();
	// MOUSE_ZOOM_Y  = mouse_zoom_y();
}

function mouse_click(mouse, focus = true) {
	INLINE
	if(MOUSE_BLOCK)		return false;
	if(!focus)			return false;
	
	if(PEN_RIGHT_CLICK) return mouse == mb_right;
	
	return mouse_check_button(mouse);
}

function mouse_press(mouse, focus = true, pass = false) {
	INLINE
	if(!pass && MOUSE_BLOCK) return false;
	if(!focus)				 return false;
	
	if(PEN_RIGHT_PRESS)      return mouse == mb_right;
	
	return mouse_check_button_pressed(mouse);
}

function mouse_release(mouse, focus = true) {
	INLINE
	if(!focus)			return false;
	
	if(PEN_RIGHT_RELEASE) return mouse == mb_right;
	
	var rl = mouse_check_button_released(mouse);
	return rl || ((mouse == mb_left || mouse == mb_any) && PEN_RELEASED);
}

function mouse_lclick(focus = true) {
	INLINE
	if(MOUSE_BLOCK)		return false;
	if(!focus)			return false;
	if(PEN_RIGHT_CLICK || PEN_RIGHT_RELEASE) return false;
	
	return mouse_check_button(mb_left);
}

function mouse_lpress(focus = true) {
	INLINE
	if(MOUSE_BLOCK)		return false;
	if(!focus)			return false;
	if(PEN_RIGHT_PRESS) return false;
	
	return mouse_check_button_pressed(mb_left);
}

function mouse_lrelease(focus = true) {
	INLINE
	if(!focus)			  return false;
	if(PEN_RIGHT_RELEASE) return false;
	if(PEN_RELEASED)	  return true;
	
	return mouse_check_button_released(mb_left);
}

function mouse_rclick(focus = true) {
	INLINE
	if(MOUSE_BLOCK)		return false;
	if(!focus)			return false;
	if(PEN_RIGHT_CLICK) return true;
	
	return mouse_check_button(mb_right);
}

function mouse_rpress(focus = true) {
	INLINE
	if(MOUSE_BLOCK)		return false;
	if(!focus)			return false;
	if(PEN_RIGHT_PRESS) return true;
	
	return mouse_check_button_pressed(mb_right);
}

function mouse_rrelease(focus = true) {
	INLINE
	if(!focus)			  return false;
	if(PEN_RIGHT_RELEASE) return true;
	
	return mouse_check_button_released(mb_right);
}
	
function mouse_lock(mx = CURSOR_LOCK_X, my = CURSOR_LOCK_Y) {
	INLINE 
	
	CURSOR_LOCK   = true;
	CURSOR_LOCK_X = mx;
	CURSOR_LOCK_Y = my;
	
	window_mouse_set(CURSOR_LOCK_X, CURSOR_LOCK_Y);
}
