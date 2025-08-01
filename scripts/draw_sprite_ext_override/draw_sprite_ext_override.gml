#macro draw_sprite_ext draw_sprite_ext_override
#macro __draw_sprite_ext draw_sprite_ext

function draw_sprite_ext_override(spr, ind, _x, _y, xscale = 1, yscale = 1, rot = 0, color = c_white, alpha = 1) {
	__draw_sprite_ext(spr, ind, round(_x), round(_y), xscale, yscale, rot, color, alpha);
}

function draw_sprite_ext_filter(spr, ind, _x, _y, xscale = 1, yscale = 1, rot = 0, color = c_white, alpha = 1) {
	gpu_set_tex_filter(1);
	draw_sprite_ext(spr, ind, _x, _y, xscale, yscale, rot, color, alpha);
	gpu_set_tex_filter(0);
}

#macro draw_sprite_stretched_ext draw_sprite_stretched_ext_override
#macro __draw_sprite_stretched_ext draw_sprite_stretched_ext

function draw_sprite_stretched_ext_override(spr, ind, _x, _y, w = 1, h = 1, color = c_white, alpha = 1) {
	__draw_sprite_stretched_ext(spr, ind, round(_x), round(_y), round(w), round(h), color, alpha);
}

function draw_sprite_stretched_add(spr, ind, _x, _y, w = 1, h = 1, color = c_white, alpha = 1) { 
	BLEND_ADD __draw_sprite_stretched_ext(spr, ind, round(_x), round(_y), round(w), round(h), color, alpha); BLEND_NORMAL
}

#macro draw_sprite_stretched draw_sprite_stretched_override
#macro __draw_sprite_stretched draw_sprite_stretched

function draw_sprite_stretched_override(spr, ind, _x, _y, w = 1, h = 1) {
	__draw_sprite_stretched(spr, ind, round(_x), round(_y), round(w), round(h));
}

function draw_sprite_ext_add(spr, ind, _x, _y, xscale = 1, yscale = 1, rot = 0, color = c_white, alpha = 1) {
	BLEND_ADD __draw_sprite_ext(spr, ind, round(_x), round(_y), xscale, yscale, rot, color, alpha); BLEND_NORMAL
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function draw_sprite_stretched_points(spr, ind, _x0, _y0, _x1, _y1, color = c_white, alpha = 1) {
	var _xs = min(_x0, _x1);
	var _ys = min(_y0, _y1);
	var _w  = max(_x0, _x1) - _xs;
	var _h  = max(_y0, _y1) - _ys;
	
	__draw_sprite_stretched_ext(spr, ind, _xs, _ys, _w, _h, color, alpha);
}

function draw_sprite_stretched_points_clamp(spr, ind, _x0, _y0, _x1, _y1, color = c_white, alpha = 1, _min = 12) {
	var _xs = min(_x0, _x1);
	var _ys = min(_y0, _y1);
	var _w  = max(_min, max(_x0, _x1) - _xs);
	var _h  = max(_min, max(_y0, _y1) - _ys);
	
	__draw_sprite_stretched_ext(spr, ind, _xs, _ys, _w, _h, color, alpha);
}

function draw_sprite_bbox(spr, ind, _bbox) {
	if(_bbox == noone) return;
	__draw_sprite_stretched(spr, ind, _bbox.x0, _bbox.y0, _bbox.w, _bbox.h);
}

function draw_sprite_bbox_uniform(spr, ind, _bbox, _col = c_white, _alp = 1, filter = false) {
	if(_bbox == noone) return;
	var _sw = sprite_get_width(spr);
    var _sh = sprite_get_height(spr);
    var _ox = sprite_get_xoffset(spr);
    var _oy = sprite_get_yoffset(spr);
    
	var _minS = min(_bbox.w / _sw, _bbox.h / _sh);
	
	gpu_set_tex_filter(filter);
	__draw_sprite_ext(spr, ind, _bbox.xc - _sw * _minS / 2 + _ox * _minS, _bbox.yc - _sh * _minS / 2 + _oy * _minS, _minS, _minS, 0, _col, _alp);
	gpu_set_tex_filter(0);
}

function draw_sprite_uniform(spr, ind, _x, _y, scale, color = c_white, alpha = 1) {
	draw_sprite_ext(spr, ind, _x, _y, scale, scale, 0, color, alpha);
}

function draw_sprite_ui(spr, ind, _x, _y, xscale = 1, yscale = 1, rot = 0, color = c_white, alpha = 1) {
	gpu_set_tex_filter(true);
		draw_sprite_ext(spr, ind, _x, _y, xscale * UI_SCALE / THEME_SCALE, yscale * UI_SCALE / THEME_SCALE, rot, color, alpha);
	gpu_set_tex_filter(false);
}

function draw_sprite_ui_uniform(spr, ind, _x, _y, scale = 1, color = c_white, alpha = 1, rot = 0) {
	draw_sprite_ui(spr, ind, _x, _y, scale, scale, rot, color, alpha);
}

function draw_sprite_colored(spr, ind, _x, _y, scale = 1, rot = 0, color = COLORS._main_accent) {
	var num = sprite_get_number(spr);
	
	draw_sprite_ui(spr, ind, _x, _y, scale, scale, rot, c_white);
	if(num % 2 == 0) draw_sprite_ui(spr, num / 2 + ind, _x, _y, scale, scale, rot, color);
}
	
function draw_anchor(_index, _x, _y, _r = ui(10), _type = 0) {
	shader_set(sh_node_widget_scalar);
		shader_set_color("color", COLORS._main_accent);
		shader_set_f("index",     _index);
		shader_set_i("type",      _type);
		
		draw_sprite_stretched(s_fx_pixel, 0, _x - _r, _y - _r, _r * 2, _r * 2);
	shader_reset();
}
	
function draw_anchor_cross(_index, _x, _y, _r, _type = 0, _a = 0) {
	shader_set(sh_node_widget_scalar_cross);
		shader_set_color("color", COLORS._main_accent);
		shader_set_f("index",     _index);
		shader_set_f("angle",     degtorad(_a));
		shader_set_i("type",      _type);
		
		draw_sprite_stretched(s_fx_pixel, 0, _x - _r, _y - _r, _r * 2, _r * 2);
	shader_reset();
}
	
function draw_anchor_line(_index, _x, _y, _r, _a, _type = 0) {
	shader_set(sh_node_widget_scalar_line);
		shader_set_color("color", COLORS._main_accent);
		shader_set_f("index",     _index);
		shader_set_f("angle",     degtorad(_a));
		shader_set_i("type",      _type);
		
		draw_sprite_stretched(s_fx_pixel, 0, _x - _r, _y - _r, _r * 2, _r * 2);
	shader_reset();
}

function draw_empty(_w = 0, _h = 0) {
	var _s = surface_get_target();
	if(_s == -1) return;
	
	_w = _w? _w : surface_get_width(_s);
	_h = _h? _h : surface_get_height(_s);
	
	draw_sprite_stretched(s_fx_pixel, 0, 0, 0, _w, _h);
}