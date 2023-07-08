function Node_Armature(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Armature Create";
	
	w = 96;
	h = 72;
	min_h = h;
	
	//inputs[| 0] = nodeValue("Axis", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0);
	
	bone_renderer = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) {
		var _b  = attributes.bones;
		if(_b == noone) return 0;
		var amo = _b.childCount();
		var _hh = ui(28);
		var bh  = ui(32 + 16) + amo * _hh;
		var ty  = _y;
			
		draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text);
		draw_text_add(_x + ui(16), ty + ui(4), "Bones");
			
		ty += ui(32);
		
		draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, ty, _w, bh - ui(32), COLORS.node_composite_bg_blend, 1);
		draw_set_color(COLORS.node_composite_separator);
		draw_line(_x + 16, ty + ui(8), _x + _w - 16, ty + ui(8));
		
		ty += ui(8);
		
		var hovering = noone;
		var _bst = ds_stack_create();
		ds_stack_push(_bst, [ _b, _x, _w ]);
			
		while(!ds_stack_empty(_bst)) {
			var _st  = ds_stack_pop(_bst);
			var bone = _st[0];
			var __x  = _st[1];
			var __w  = _st[2];
				
			if(!bone.is_main) {
				if(bone.parent_anchor) 
					draw_sprite_ui(THEME.bone, 1, __x + 12, ty + 14,,,, COLORS._main_icon);
				else if(bone.IKlength) 
					draw_sprite_ui(THEME.bone, 2, __x + 12, ty + 14,,,, COLORS._main_icon);
				else {
					if(_hover && point_in_circle(_m[0], _m[1], __x + 12, ty + 12, 12)) {
						draw_sprite_ui(THEME.bone, 0, __x + 12, ty + 14,,,, COLORS._main_icon_light);
						if(mouse_press(mb_left, _focus))
							bone_dragging = bone;
					} else 
						draw_sprite_ui(THEME.bone, 0, __x + 12, ty + 14,,,, COLORS._main_icon);
				}
				
				if(point_in_rectangle(_m[0], _m[1], __x + 24, ty + 3, __x + __w, ty + _hh - 3))
					anchor_selecting = [ bone, 2 ];
				
				bone.tb_name.setFocusHover(_focus, _hover);
				bone.tb_name.draw(__x + 24, ty + 3, __w - 24 - 32, _hh - 6, bone.name, _m);
				
				ty += _hh;
				
				draw_set_color(COLORS.node_composite_separator);
				draw_line(_x + 16, ty, _x + _w - 16, ty);
			}
				
			for( var i = 0; i < array_length(bone.childs); i++ )
				ds_stack_push(_bst, [ bone.childs[i], __x + 16, __w - 16 ]);
		}
		
		ds_stack_destroy(_bst);
		
		if(bone_dragging && mouse_release(mb_left))
			bone_dragging = noone;
		
		return bh;
	})
	
	input_display_list = [
		bone_renderer,
	];
	
	input_fix_len = ds_list_size(inputs);
	data_length = 1;
	
	static createBone = function(parent, distance, direction) {
		var bone  = new __Bone(parent, distance, direction,,, self);
		parent.addChild(bone);
		
		if(parent == attributes.bones) 
			bone.parent_anchor = false;
		return bone;
	}
	
	outputs[| 0] = nodeValue("Armature", self, JUNCTION_CONNECT.output, VALUE_TYPE.armature, noone);
	
	attributes.bones = new __Bone(,,,,, self);
	attributes.bones.name = "Main";
	attributes.bones.is_main = true;
	attributes.bones.node = self;
	
	attributes.display_name = true;
	attributes.display_bone = 0;
	
	array_push(attributeEditors, "Display");
	array_push(attributeEditors, ["Display name", "display_name", 
		new checkBox(function() { 
			attributes.display_name = !attributes.display_name;
		})]);
	array_push(attributeEditors, ["Display bone", "display_bone", 
		new scrollBox(["Octahedral", "Stick"], function(ind) { 
			attributes.display_bone = ind;
		})]);
	
	tools = [
		new NodeTool( "Add bones", THEME.bone_tool_add ),
		new NodeTool( "Remove bones", THEME.bone_tool_remove ),
		new NodeTool( "Detach bones", THEME.bone_tool_detach ),
		new NodeTool( "IK", THEME.bone_tool_IK ),
	];
	
	anchor_selecting = noone;
	builder_bone = noone;
	builder_type = 0;
	builder_sx = 0;
	builder_sy = 0;
	builder_mx = 0;
	builder_my = 0;
	
	bone_dragging = noone;
	ik_dragging = noone;
	
	moving = false;
	scaling = false;
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var mx = (_mx - _x) / _s;
		var my = (_my - _y) / _s;
		
		var _b = attributes.bones;
		
		if(builder_bone != noone) {
			anchor_selecting = _b.draw(attributes, false, _x, _y, _s, _mx, _my, anchor_selecting);
			
			var dir = point_direction(builder_sx, builder_sy, mx, my);
			var dis = point_distance(builder_sx, builder_sy, mx, my);
			
			if(builder_type == 2) {
				var bx = builder_sx + (mx - builder_mx);
				var by = builder_sy + (my - builder_my);
				
				if(!builder_bone.parent_anchor) {
					builder_bone.direction = point_direction(0, 0, bx, by);
					builder_bone.distance  = point_distance( 0, 0, bx, by);
				}
			} else if(key_mod_press(ALT)) {
				if(builder_type == 0) {
					var bo = builder_bone.getPoint(1);
					
					builder_bone.direction = dir;
					builder_bone.distance  = dis;
					
					var bn = builder_bone.getPoint(0);
					
					builder_bone.angle  = point_direction(bn.x, bn.y, bo.x, bo.y);
					builder_bone.length = point_distance( bn.x, bn.y, bo.x, bo.y);
				} else if(builder_type == 1) {
					var chs = [];
					for( var i = 0; i < array_length(builder_bone.childs); i++ ) {
						var ch = builder_bone.childs[i];
						chs[i] = ch.getPoint(1);
					}
				
					builder_bone.angle  = dir;
					builder_bone.length = dis;
					
					for( var i = 0; i < array_length(builder_bone.childs); i++ ) {
						var ch = builder_bone.childs[i];
						var c0 = ch.getPoint(0);
					
						ch.angle  = point_direction(c0.x, c0.y, chs[i].x, chs[i].y);
						ch.length = point_distance( c0.x, c0.y, chs[i].x, chs[i].y);
					}
				}
			} else {
				if(builder_type == 0) {
					builder_bone.direction = dir;
					builder_bone.distance  = dis;
					
					if(builder_bone.parent) {
						var par_anc = builder_bone.parent.getPoint(1);
						par_anc.x = _x + par_anc.x * _s;
						par_anc.y = _y + par_anc.y * _s;
						
						var inRange = point_in_circle(_mx, _my, par_anc.x, par_anc.y, 16) && mouse_release(mb_left);
						if(!builder_bone.parent.is_main && builder_bone.IKlength > 0 && inRange)
							builder_bone.parent_anchor = true;
					}
				} else if(builder_type == 1) {
					builder_bone.angle  = dir;
					builder_bone.length = dis;
				}
			}
			
			if(mouse_release(mb_left)) {
				builder_bone = noone;
				UNDO_HOLDING = false;
			}
			
			triggerRender();
		} else if(ik_dragging != noone) {
			anchor_selecting = _b.draw(attributes, active * 0b100, _x, _y, _s, _mx, _my, anchor_selecting, ik_dragging);
			
			if(anchor_selecting != noone && anchor_selecting[1] == 2) {
				var anc = anchor_selecting[0];
				
				var reachable = false;
				var _bone = ik_dragging.parent;
				var len = 1;
				
				while(_bone != noone) {
					if(_bone == anc.parent) {
						reachable = true;
						break;
					}
					
					len++;
					_bone = _bone.parent;
				}
				
				if(reachable && mouse_release(mb_left)) {
					var p1 = ik_dragging.getPoint(1);
					var p0 = anc.getPoint(0);
					
					var _len = point_distance(p0.x, p0.y, p1.x, p1.y);
					var _ang = point_direction(p0.x, p0.y, p1.x, p1.y);
					
					var IKbone = new __Bone(anc, _len, _ang, ik_dragging.angle + 90, 0, self);
					anc.addChild(IKbone);
					IKbone.IKlength = len;
					IKbone.IKTarget = ik_dragging;
					
					IKbone.name = "IK handle";
					IKbone.parent_anchor = false;
				}
			}
			
			if(mouse_release(mb_left)) {
				ik_dragging = noone;
				UNDO_HOLDING = false;
			}
			
			triggerRender();
		} else if(isUsingTool(0)) { // builder
			anchor_selecting = _b.draw(attributes, active * 0b111, _x, _y, _s, _mx, _my, anchor_selecting);
			
			if(mouse_press(mb_left, active)) {
				if(anchor_selecting == noone) {
					builder_bone = createBone(attributes.bones, point_distance(0, 0, mx, my), point_direction(0, 0, mx, my));
					builder_type = 1;
					builder_sx = mx;
					builder_sy = my;
					UNDO_HOLDING = true;
				} else if(anchor_selecting[1] == 1) {
					builder_bone = createBone(anchor_selecting[0], 0, 0);
					builder_type = 1;
					builder_sx = mx;
					builder_sy = my;
					UNDO_HOLDING = true;
				} else if(anchor_selecting[1] == 2) {
					var _pr = anchor_selecting[0];
					var _md = new __Bone(noone, 0, 0, _pr.angle, _pr.length / 2, self);
					_pr.length = _md.length;
					
					for( var i = 0; i < array_length(_pr.childs); i++ )
						_md.addChild(_pr.childs[i]);
					
					_pr.childs = [];
					_pr.addChild(_md);
					
					UNDO_HOLDING = true;
				}
			}
			
			if(anchor_selecting == noone)
				draw_sprite_ext(THEME.bone_tool_add, 1, _mx + 24, _my + 24, 1, 1, 0, c_white, 1);
			else if(anchor_selecting[1] == 1) {
				draw_sprite_ext(THEME.bone_tool_add, 0, _mx + 24, _my + 24, 1, 1, 0, c_white, 1);
				draw_sprite_ext(THEME.bone_tool_add, 1, _mx + 24, _my + 24, 1, 1, 0, c_white, 1);
			} else if(anchor_selecting[1] == 2)
				draw_sprite_ext(THEME.bone_tool_add, 0, _mx + 24, _my + 24, 1, 1, 0, c_white, 1);
		} else if(isUsingTool(1)) { //remover
			anchor_selecting = _b.draw(attributes, active * 0b100, _x, _y, _s, _mx, _my, anchor_selecting);
			
			if(anchor_selecting != noone && anchor_selecting[1] == 2 && anchor_selecting[0].parent != noone && mouse_press(mb_left, active)) {
				var _bone = anchor_selecting[0];
				var _par  = _bone.parent;
				
				array_remove(_par.childs, _bone);
				
				for( var i = 0; i < array_length(_bone.childs); i++ ) {
					var _ch = _bone.childs[i];
					_par.addChild(_ch);
						
					_ch.parent_anchor = _bone.parent_anchor;
				}
					
				triggerRender();
			}
			
			if(anchor_selecting != noone)
				draw_sprite_ext(THEME.bone_tool_remove, 1, _mx + 24, _my + 24, 1, 1, 0, c_white, 1);
		} else if(isUsingTool(2)) { //detach
			anchor_selecting = _b.draw(attributes, active * 0b100, _x, _y, _s, _mx, _my, anchor_selecting);
			
			if(anchor_selecting != noone && anchor_selecting[1] == 2 && mouse_press(mb_left, active)) {
				builder_bone = anchor_selecting[0];
				builder_type = anchor_selecting[1];
				
				var par = builder_bone.parent;
				if(builder_bone.parent_anchor) {
					builder_bone.distance  = par.length;
					builder_bone.direction = par.angle;
				}
				builder_bone.parent_anchor = false;
				
				builder_sx = lengthdir_x(builder_bone.distance, builder_bone.direction);
				builder_sy = lengthdir_y(builder_bone.distance, builder_bone.direction);
				builder_mx = mx;
				builder_my = my;
				UNDO_HOLDING = true;
			}
		} else if(isUsingTool(3)) { //IK
			anchor_selecting = _b.draw(attributes, active * 0b100, _x, _y, _s, _mx, _my, anchor_selecting);
			
			if(anchor_selecting != noone && anchor_selecting[1] == 2 && mouse_press(mb_left, active)) {
				ik_dragging = anchor_selecting[0];
			}
		} else { //mover
			anchor_selecting = _b.draw(attributes, active * 0b111, _x, _y, _s, _mx, _my, anchor_selecting);
			
			if(anchor_selecting != noone && mouse_press(mb_left, active)) {
				builder_bone = anchor_selecting[0];
				builder_type = anchor_selecting[1];
				
				if(builder_type == 0) {
					var orig = builder_bone.parent.getPoint(0);
					builder_sx = orig.x;
					builder_sy = orig.y;
				} else if(builder_type == 1) {
					var orig = builder_bone.getPoint(0);
					builder_sx = orig.x;
					builder_sy = orig.y;
				} else if(builder_type == 2) {
					if(builder_bone.parent_anchor) {
						builder_bone = noone;
					} else {
						var par = builder_bone.parent;
						builder_sx = lengthdir_x(builder_bone.distance, builder_bone.direction);
						builder_sy = lengthdir_y(builder_bone.distance, builder_bone.direction);
						builder_mx = mx;
						builder_my = my;
					}
				}
				
				UNDO_HOLDING = true;
			}
		}
	}
	
	static step = function() {
		
	}
	
	static update = function(frame = PROJECT.animator.current_frame) {
		outputs[| 0].setValue(attributes.bones);
	}
	
	static attributeSerialize = function() { return {}; }
	static attributeDeserialize = function(attr) {}
	
	static doSerialize = function(_map) {
		_map.bones = attributes.bones.serialize();
	}
	
	static postDeserialize = function() {
		if(!struct_has(load_map, "bones")) return;
		attributes.bones = new __Bone(,,,,, self);
		attributes.bones.deserialize(load_map.bones, self);
		attributes.bones.connect();
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_armature_create, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}
