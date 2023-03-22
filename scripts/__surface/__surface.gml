function Surface(surface) constructor {
	static set = function(surface) {
		self.surface = surface;
		w = surface_get_width(surface);
		h = surface_get_height(surface);
		format = surface_get_format(surface);
	}
	set(surface);
	
	static get = function() { return surface; }
	
	static isValid = function() { return is_surface(surface); }
	
	static resize = function(w, h) { 
		surface_resize(surface, w, h);
		self.w = w;
		self.h = h;
		return self;
	}
	
	static draw = function(x, y, xs = 1, ys = 1, rot = 0, col = c_white, alpha = 1) { 
		draw_surface_ext_safe(surface, x, y, xs, ys, rot, col, alpha);
		return self; 
	}
	
	static drawStretch = function(x, y, w = 1, h = 1, rot = 0, col = c_white, alpha = 1) { 
		draw_surface_stretched_ext(surface, x, y, w, h, col, alpha);
		return self; 
	}
	
	static destroy = function() {
		if(!isValid()) return;
		surface_free(surface);
	}
}

function Surface_get(surface) {
	if(is_real(surface)) 
		return surface;
	if(is_struct(surface) && struct_has(surface, "surface")) 
		return surface.surface;
	return noone;
}