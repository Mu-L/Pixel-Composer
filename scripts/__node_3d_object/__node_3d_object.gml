#region
	FN_NODE_TOOL_INVOKE {
		hotkeyTool("Node_3D_Object", "Transform", "G");
		hotkeyTool("Node_3D_Object", "Rotate",    "R");
		hotkeyTool("Node_3D_Object", "Scale",     "S");
	});
	
	function d3d_transform_tool_position(_node) : ToolObject() constructor {
		activeKeyboard = false;
		setNode(_node);
		
		drag_axis  = noone;
		drag_sv    = 0;
		drag_delta = 0;
		drag_prev  = 0;
		drag_dist  = 0;
		drag_val   = 0;
		
		drag_mx = 0; drag_my = 0;
		drag_px = 0; drag_py = 0;
		drag_cx = 0; drag_cy = 0;
		drag_rot_axis = new BBMOD_Quaternion();
		drag_original = 0;
		axis_hover    = noone;
		
		static init = function() {
			activeKeyboard = false;
			
			KEYBOARD_STRING = "";
			KEYBOARD_NUMBER = undefined;
		}
		
		static initKeyboard = function() /*=>*/ {
			activeKeyboard = true;
		}
		
		function drawOverlay3D(index, object, _vpos, active, params, _mx, _my, _snx, _sny, _panel) {
			#region ---- main ----
				var _pos  = node.inputs[index].getValue(,,, true);
				var _qrot = object == noone? new BBMOD_Quaternion() : object.transform.rotation;
				var _qinv = new BBMOD_Quaternion().FromAxisAngle(new BBMOD_Vec3(1, 0, 0), 90);
			
				var _camera = params.camera;
				var _qview  = new BBMOD_Quaternion().FromEuler(_camera.focus_angle_y, -_camera.focus_angle_x, 0);
				
				var _axis = node.tool_attribute.context;
				
				var _hover     = noone;
				var _hoverDist = 10;
				var th;
				
				var _posView = _camera.worldPointToViewPoint(_vpos);
			
				var cx = _posView.x;
				var cy = _posView.y;
			
				var ga   = [];
				var size = 64;
				var hs = size / 2;
				var sq = 8;
			#endregion
				
			#region display
				ga[0] = new BBMOD_Vec3(-size, 0, 0);
				ga[1] = new BBMOD_Vec3(0, 0,  size);
				ga[2] = new BBMOD_Vec3(0, -size, 0);
				
				ga[3] = [	new BBMOD_Vec3(-hs + sq,        0,  hs - sq),
							new BBMOD_Vec3(-hs - sq,        0,  hs - sq), 
							new BBMOD_Vec3(-hs - sq,        0,  hs + sq), 
							new BBMOD_Vec3(-hs + sq,        0,  hs + sq), ];
				ga[4] = [	new BBMOD_Vec3(       0, -hs + sq,  hs - sq),
							new BBMOD_Vec3(       0, -hs - sq,  hs - sq), 
							new BBMOD_Vec3(       0, -hs - sq,  hs + sq), 
							new BBMOD_Vec3(       0, -hs + sq,  hs + sq), ];
				ga[5] = [	new BBMOD_Vec3(-hs + sq, -hs - sq,        0),
							new BBMOD_Vec3(-hs - sq, -hs - sq,        0), 
							new BBMOD_Vec3(-hs - sq, -hs + sq,        0), 
							new BBMOD_Vec3(-hs + sq, -hs + sq,        0), ];
				
				ga[0] = new BBMOD_Vec3(-size, 0, 0);
				ga[1] = new BBMOD_Vec3(0, -size, 0);
				ga[2] = new BBMOD_Vec3(0, 0, -size);
				
				ga[3] = [	new BBMOD_Vec3(-hs + sq, -hs - sq,        0),
							new BBMOD_Vec3(-hs - sq, -hs - sq,        0), 
							new BBMOD_Vec3(-hs - sq, -hs + sq,        0), 
							new BBMOD_Vec3(-hs + sq, -hs + sq,        0), ];
				ga[4] = [	new BBMOD_Vec3(       0, -hs + sq, -hs - sq),
							new BBMOD_Vec3(       0, -hs - sq, -hs - sq), 
							new BBMOD_Vec3(       0, -hs - sq, -hs + sq), 
							new BBMOD_Vec3(       0, -hs + sq, -hs + sq), ];
				ga[5] = [	new BBMOD_Vec3(-hs + sq,        0, -hs - sq),
							new BBMOD_Vec3(-hs - sq,        0, -hs - sq), 
							new BBMOD_Vec3(-hs - sq,        0, -hs + sq), 
							new BBMOD_Vec3(-hs + sq,        0, -hs + sq), ];
					
				for( var i = 0; i < 3; i++ ) {
					if(_axis == 0) 
						ga[i] = _qview.Rotate(_qinv.Rotate(_qrot.Rotate(ga[i])));
					else if(_axis == 1)
						ga[i] = _qview.Rotate(_qinv.Rotate(ga[i]));
					
					th = 2 + (axis_hover == i || drag_axis == i);
					if(drag_axis != noone && drag_axis != i)
						continue;
					
					draw_set_color(COLORS.axis[i]);
					if(point_distance(cx, cy, cx + ga[i].X, cy + ga[i].Y) < 5)
						draw_line_round(cx, cy, cx + ga[i].X, cy + ga[i].Y, th);
					else 
						draw_line_round_arrow(cx, cy, cx + ga[i].X, cy + ga[i].Y, th, 3);
					
					var _d = distance_to_line(_mx, _my, cx, cy, cx + ga[i].X, cy + ga[i].Y);
					if(_d < _hoverDist) {
						_hover = i;
						_hoverDist = _d;
					}
				}
				
				for( var i = 3; i < 6; i++ ) {
					for( var j = 0; j < 4; j++ ) {
						if(_axis == 0) 
							ga[i][j] = _qview.Rotate(_qinv.Rotate(_qrot.Rotate(ga[i][j])));
						else if(_axis == 1)
							ga[i][j] = _qview.Rotate(_qinv.Rotate(ga[i][j]));
					}
					
					th = 1;
					
					var p0x = cx + ga[i][0].X, p0y = cy + ga[i][0].Y;
					var p1x = cx + ga[i][1].X, p1y = cy + ga[i][1].Y;
					var p2x = cx + ga[i][2].X, p2y = cy + ga[i][2].Y;
					var p3x = cx + ga[i][3].X, p3y = cy + ga[i][3].Y;
					
					var _pax = (p0x + p1x + p2x + p3x) / 4;
					var _pay = (p0y + p1y + p2y + p3y) / 4;
					
					if((abs(p0x - _pax) + abs(p1x - _pax) + abs(p2x - _pax) + abs(p3x - _pax)) / 4 < 1)
						continue;
						
					if((abs(p0y - _pay) + abs(p1y - _pay) + abs(p2y - _pay) + abs(p3y - _pay)) / 4 < 1)
						continue;
					
					draw_set_color(COLORS.axis[(i - 3 - 1 + 3) % 3]);
					if(axis_hover == i || drag_axis == i) {
						draw_primitive_begin(pr_trianglestrip);
							draw_vertex(p0x, p0y);
							draw_vertex(p1x, p1y);
							draw_vertex(p3x, p3y);
							draw_vertex(p2x, p2y);
						draw_primitive_end();
					} else if (drag_axis == noone) {
						draw_line(p0x, p0y, p1x, p1y);
						draw_line(p1x, p1y, p2x, p2y);
						draw_line(p2x, p2y, p3x, p3y);
						draw_line(p3x, p3y, p0x, p0y);
					} else 
						continue;
					
					if(point_in_rectangle_points(_mx, _my, p0x, p0y, p1x, p1y, p3x, p3y, p2x, p2y))
						_hover = i;
				}
				
				axis_hover = _hover;
			#endregion display
			
			if(drag_axis != noone) { // editing
				var mAdj, nor, prj, pln;
				
				if(!MOUSE_WRAPPING) {
					if(KEYBOARD_NUMBER == undefined) {
						drag_mx += _mx - drag_px;
						drag_my += _my - drag_py;
							
						var ray = _camera.viewPointToWorldRay(drag_mx, drag_my);
						var val = [ drag_val[0], drag_val[1], drag_val[2] ];
						
						if(drag_axis < 3) {
							switch(drag_axis) {
								case 0 : nor = new __vec3(0, 1, 0); prj = new __vec3(1, 0, 0); break;
								case 1 : nor = new __vec3(0, 0, 1); prj = new __vec3(0, 1, 0); break;
								case 2 : nor = new __vec3(1, 0, 0); prj = new __vec3(0, 0, 1); break;
							}
								
							if(_axis == 0) {
								nor = _qrot.Rotate(nor);
								prj = _qrot.Rotate(prj);
							}
								
							pln  = new __plane(drag_original, nor);
							mAdj = d3d_intersect_ray_plane(ray, pln);
							
							if(drag_prev != undefined) {
								var _diff = mAdj.subtract(drag_prev);
								var _dist = _diff.dot(prj);
								
								for( var i = 0; i < 3; i++ ) 
									val[i] += prj.getIndex(i) * _dist;
								
								if(node.inputs[index].setValue(value_snap(val, _snx)))
									UNDO_HOLDING = true;
							}
						} else {
							switch(drag_axis) {
								case 3 : nor = new __vec3(0, 0, 1); break;
								case 4 : nor = new __vec3(1, 0, 0); break;
								case 5 : nor = new __vec3(0, 1, 0); break;
							}
								
							if(_axis == 0) nor = _qrot.Rotate(nor);
								
							pln  = new __plane(drag_original, nor);
							mAdj = d3d_intersect_ray_plane(ray, pln);
								
							if(drag_prev != undefined) {
								var _diff = mAdj.subtract(drag_prev);
								
								for( var i = 0; i < 3; i++ ) 
									val[i] += _diff.getIndex(i);
								
								if(node.inputs[index].setValue(value_snap(val, _snx))) 
									UNDO_HOLDING = true;
							}
						}
							
						drag_val  = [ val[0], val[1], val[2] ];
						drag_prev = mAdj;
						
					} else {
						var val = [ drag_original.x, drag_original.y, drag_original.z ];
						if(drag_axis < 3) val[drag_axis] += KEYBOARD_NUMBER;
						
						if(node.inputs[index].setValue(val)) 
							UNDO_HOLDING = true;
					}
				}
					
				setMouseWrap();
				drag_px = _mx;
				drag_py = _my;
				
				if((!activeKeyboard && mouse_release(mb_left)) || (activeKeyboard && (mouse_press(mb_left) || key_press(vk_enter))) ) {
					if(activeKeyboard) PANEL_PREVIEW.resetTool();
					
					drag_axis      = noone;
					UNDO_HOLDING   = false;
					activeKeyboard = false;
				}
				
				if(drag_axis != 0 && key_press(ord("X"))) {
					drag_axis = 0;
					drag_val  = drag_original.toArray();
					drag_prev = undefined;
					KEYBOARD_STRING = "";
				}
				
				if(drag_axis != 1 && key_press(ord("Y"))) {
					drag_axis = 1;
					drag_val  = drag_original.toArray();
					drag_prev = undefined;
					KEYBOARD_STRING = "";
				}
				
				if(drag_axis != 2 && key_press(ord("Z"))) {
					drag_axis = 2;
					drag_val  = drag_original.toArray();
					drag_prev = undefined;
					KEYBOARD_STRING = "";
				}
				
				var _tooltipText = "Dragging";
				switch(drag_axis) {
					case 0 : _tooltipText += " X"; break;
					case 1 : _tooltipText += " Y"; break;
					case 2 : _tooltipText += " Z"; break;
					
					case 3 : _tooltipText += " XY"; break;
					case 4 : _tooltipText += " YZ"; break;
					case 5 : _tooltipText += " XZ"; break;
				}
				
				if(KEYBOARD_NUMBER != undefined)
					_tooltipText += $" [{KEYBOARD_NUMBER}]";
				
				PANEL_PREVIEW.setActionTooltip(_tooltipText);
				
			} else {
				if((_hover != noone && mouse_press(mb_left, active)) || activeKeyboard) {
					drag_axis = activeKeyboard? 0 : _hover;
					drag_mx	= _mx; drag_my = _my;
					drag_px = _mx; drag_py = _my;
					drag_cx =  cx; drag_cy = cy;
					
					drag_val  = _pos;
					drag_prev = undefined;
					drag_original = new __vec3(_pos);
				}
			}
		}
	}
	
	function d3d_transform_tool_rotation(_node) : ToolObject() constructor {
		activeKeyboard = false;
		setNode(_node);
		
		drag_axis  = noone;
		drag_sv    = 0;
		drag_delta = 0;
		drag_prev  = 0;
		drag_dist  = 0;
		drag_val   = 0;
		
		drag_mx = 0; drag_my = 0;
		drag_px = 0; drag_py = 0;
		drag_cx = 0; drag_cy = 0;
		drag_rot_axis = new BBMOD_Quaternion();
		drag_original = 0;
		axis_hover    = noone;
		
		static init = function() {
			activeKeyboard = false;
			
			KEYBOARD_STRING = "";
			KEYBOARD_NUMBER = undefined;
		}
		
		static initKeyboard = function() /*=>*/ {
			activeKeyboard = true;
		}
		
		function drawOverlay3D(index, object, _vpos, active, params, _mx, _my, _snx, _sny, _panel) {
			#region ---- main ----
				var _rot  = node.inputs[index].getValue();
				var _qrot = object == noone? new BBMOD_Quaternion() : object.transform.rotation;
				var _qinv = new BBMOD_Quaternion().FromAxisAngle(new BBMOD_Vec3(1, 0, 0), 90);
				
				var _camera = params.camera;
				var _qview  = new BBMOD_Quaternion().FromEuler(_camera.focus_angle_y, -_camera.focus_angle_x, 0);
			
				var _ang    = node.inputs[index].attributes.angle_display;
				var _quat   = _ang == QUARTERNION_DISPLAY.quarterion;
				var _global = _quat? node.tool_attribute.context : 1;
				
				var _hover     = noone;
				var _hoverDist = 10;
				var th;
			
				var _posView = _camera.worldPointToViewPoint(_vpos);
				
				var cx = _posView.x;
				var cy = _posView.y;
			
				var ga   = [];
				var size = 64;
				var hs   = size / 2;
				var sq   = 8;
			#endregion
			
			#region display
				var size  = 64;
				for( var i = 0; i < 3; i++ ) {
					var op, np;
					
					th = 2 + (axis_hover == i || drag_axis == i);
					if(drag_axis != noone && drag_axis != i)
						continue;
						
					draw_set_color(COLORS.axis[i]);
					for( var j = 0; j <= 32; j++ ) {
						var ang = j / 32 * 360;
						
						switch(i) {
							case 0 : np = new BBMOD_Vec3(0, lengthdir_x(size, ang), lengthdir_y(size, ang)); break;
							case 1 : np = new BBMOD_Vec3(lengthdir_x(size, ang), 0, lengthdir_y(size, ang)); break;
							case 2 : np = new BBMOD_Vec3(lengthdir_x(size, ang), lengthdir_y(size, ang), 0); break;
						}
						
						if(_global) np = _qview.Rotate(_qinv.Rotate(np));
						else        np = _qview.Rotate(_qinv.Rotate(_qrot.Rotate(np)));
						
						if(j && (op.Z > 0 && np.Z > 0 || drag_axis == i)) {
							draw_line_round(cx + op.X, cy + op.Y, cx + np.X, cy + np.Y, th);
							var _d = distance_to_line(_mx, _my, cx + op.X, cy + op.Y, cx + np.X, cy + np.Y);
							if(_d < _hoverDist) {
								_hover = i;
								_hoverDist = _d;
							}
						}
						
						op = np;
					}
				}
				axis_hover = _hover;
			#endregion
				
			if(_quat) {
				if(drag_axis != noone) {
					var mAng = point_direction(cx, cy, _mx, _my);
					
					if(drag_rot_axis == undefined) {
						drag_rot_axis = BBMOD_VEC3_FORWARD;
						
						switch(drag_axis) {
							case 0 : drag_rot_axis = new BBMOD_Vec3(-1,  0,  0); break;
							case 1 : drag_rot_axis = new BBMOD_Vec3( 0, -1,  0); break;
							case 2 : drag_rot_axis = new BBMOD_Vec3( 0,  0, -1); break;
						}
					
						if(!_global) drag_rot_axis = _qrot.Rotate(drag_rot_axis).Normalize();
					}
					
					var _nv = _qview.Rotate(_qinv.Rotate(drag_rot_axis));
					draw_line_round(cx, cy, cx + _nv.X * 100, cy + _nv.Y * 100, 2);
						
					if(drag_prev != undefined) {
						var _rd    = (mAng - drag_prev) * (_nv.Z > 0? 1 : -1);
						drag_dist += _rd;
						var _dist  = value_snap(drag_dist, _sny);
						
						var _currR = new BBMOD_Quaternion().FromAxisAngle(drag_rot_axis, _dist);
						var _val   = _currR.Mul(drag_val);
						var _Nrot  = _val.ToArray();
						
						if(node.inputs[index].setValue(_Nrot))
							UNDO_HOLDING = true;
					} 
						
					draw_set_color(COLORS._main_accent);
					draw_line_dashed(cx, cy, _mx, _my, 1, 4);
						
					drag_prev = mAng;
				}
					
				if(_hover != noone && mouse_press(mb_left, active)) {
					drag_axis = _hover;
					drag_prev = undefined;
					drag_val  = _qrot.Clone();
					drag_dist = 0;
					
					drag_rot_axis = undefined;
				}
				
			} else {
				if(drag_axis != noone) {
					if(KEYBOARD_NUMBER == undefined) {
						var mAng = point_direction(cx, cy, _mx, _my);
						
						if(drag_prev != undefined) {
							drag_dist += drag_prev - mAng;
							
							var _Nrot = array_clone(drag_val);
							_Nrot[drag_axis] += drag_dist;
							
							if(node.inputs[index].setValue(_Nrot))
								UNDO_HOLDING = true;
						}
						
						drag_prev = mAng;
						
					} else {
						var val = [ drag_original[0], drag_original[1], drag_original[2] ];
						if(drag_axis < 3) val[drag_axis] += KEYBOARD_NUMBER;
						
						if(node.inputs[index].setValue(val)) 
							UNDO_HOLDING = true;
					}
					
					if((!activeKeyboard && mouse_release(mb_left)) || (activeKeyboard && (mouse_press(mb_left) || key_press(vk_enter))) ) {
						if(activeKeyboard) PANEL_PREVIEW.resetTool();
						
						drag_axis      = noone;
						UNDO_HOLDING   = false;
						activeKeyboard = false;
					}
					
				} else {
					if((_hover != noone && mouse_press(mb_left, active)) || activeKeyboard) {
						drag_axis = activeKeyboard? 0 : _hover;
						drag_prev = undefined;
						
						drag_original = node.inputs[index].getValue(CURRENT_FRAME, false);
						drag_val  = array_clone(drag_original);
						drag_dist = 0;
					}
					
				}
			}
			
			if(drag_axis != noone) {
				if(drag_axis != 0 && key_press(ord("X"))) {
					drag_axis = 0;
					drag_val  = array_clone(drag_original);
					drag_prev = undefined;
					KEYBOARD_STRING = "";
				}
				
				if(drag_axis != 1 && key_press(ord("Y"))) {
					drag_axis = 1;
					drag_val  = array_clone(drag_original);
					drag_prev = undefined;
					KEYBOARD_STRING = "";
				}
				
				if(drag_axis != 2 && key_press(ord("Z"))) {
					drag_axis = 2;
					drag_val  = array_clone(drag_original);
					drag_prev = undefined;
					KEYBOARD_STRING = "";
				}
				
				var _tooltipText = "Rotating";
				switch(drag_axis) {
					case 0 : _tooltipText += " X"; break;
					case 1 : _tooltipText += " Y"; break;
					case 2 : _tooltipText += " Z"; break;
					
					case 3 : _tooltipText += " XY"; break;
					case 4 : _tooltipText += " YZ"; break;
					case 5 : _tooltipText += " XZ"; break;
				}
				
				if(KEYBOARD_NUMBER != undefined)
					_tooltipText += $" [{KEYBOARD_NUMBER}]";
				
				PANEL_PREVIEW.setActionTooltip(_tooltipText);
				
			}
		}
	}
	
	function d3d_transform_tool_scale(_node) : ToolObject() constructor {
		activeKeyboard = false;
		setNode(_node);
		
		drag_axis  = noone;
		drag_sv    = 0;
		drag_delta = 0;
		drag_prev  = 0;
		drag_dist  = 0;
		drag_val   = 0;
		
		drag_mx = 0; drag_my = 0;
		drag_sx = 0; drag_sy = 0;
		drag_px = 0; drag_py = 0;
		drag_cx = 0; drag_cy = 0;
		drag_rot_axis = new BBMOD_Quaternion();
		drag_original = 0;
		axis_hover    = noone;
		
		static init = function() {
			activeKeyboard = false;
			
			KEYBOARD_STRING = "";
			KEYBOARD_NUMBER = undefined;
		}
		
		static initKeyboard = function() /*=>*/ {
			activeKeyboard = true;
		}
		
		function drawOverlay3D(index, object, _vpos, active, params, _mx, _my, _snx, _sny, _panel) {
			
			#region ---- main ----
				var _sca  = node.inputs[index].getValue(,,, true);
				var _qrot = object == noone? new BBMOD_Quaternion() : object.transform.rotation;
				var _qinv = new BBMOD_Quaternion().FromAxisAngle(new BBMOD_Vec3(1, 0, 0), 90);
			
				var _camera = params.camera;
				var _qview  = new BBMOD_Quaternion().FromEuler(_camera.focus_angle_y, -_camera.focus_angle_x, 0);
			
				var _hover     = noone;
				var _hoverDist = 10;
				var th;
			
				var _posView = _camera.worldPointToViewPoint(_vpos);
			
				var cx = _posView.x;
				var cy = _posView.y;
			
				var ga   = [];
				var size = 64;
				var hs = size / 2;
				var sq = 8;
			#endregion
			
			#region display
				var ga    = [];
				var size  = 64;
				var hs    = size / 2;
				var sq    = 8;
				
				ga[0] = new BBMOD_Vec3(-size, 0, 0);
				ga[1] = new BBMOD_Vec3(0, -size, 0);
				ga[2] = new BBMOD_Vec3(0, 0, -size);
				
				ga[3] = [	new BBMOD_Vec3(-hs + sq, -hs - sq,        0),
							new BBMOD_Vec3(-hs - sq, -hs - sq,        0), 
							new BBMOD_Vec3(-hs - sq, -hs + sq,        0), 
							new BBMOD_Vec3(-hs + sq, -hs + sq,        0), ];
				ga[4] = [	new BBMOD_Vec3(       0, -hs + sq, -hs - sq),
							new BBMOD_Vec3(       0, -hs - sq, -hs - sq), 
							new BBMOD_Vec3(       0, -hs - sq, -hs + sq), 
							new BBMOD_Vec3(       0, -hs + sq, -hs + sq), ];
				ga[5] = [	new BBMOD_Vec3(-hs + sq,        0, -hs - sq),
							new BBMOD_Vec3(-hs - sq,        0, -hs - sq), 
							new BBMOD_Vec3(-hs - sq,        0, -hs + sq), 
							new BBMOD_Vec3(-hs + sq,        0, -hs + sq), ];
				
				for( var i = 0; i < 3; i++ ) {
					ga[i] = _qview.Rotate(_qinv.Rotate(_qrot.Rotate(ga[i])));
				
					th = 2 + (axis_hover == i || drag_axis == i);
					if(drag_axis != noone && drag_axis != i)
						continue;
					
					draw_set_color(COLORS.axis[i]);
					if(point_distance(cx, cy, cx + ga[i].X, cy + ga[i].Y) < 5)
						draw_line_round(cx, cy, cx + ga[i].X, cy + ga[i].Y, th);
					else 
						draw_line_round_arrow_block(cx, cy, cx + ga[i].X, cy + ga[i].Y, th, 3);
					
					var _d = distance_to_line(_mx, _my, cx, cy, cx + ga[i].X, cy + ga[i].Y);
					if(_d < _hoverDist) {
						_hover = i;
						_hoverDist = _d;
					}
				}
				
				for( var i = 3; i < 6; i++ ) {
					for( var j = 0; j < 4; j++ )
						ga[i][j] = _qview.Rotate(_qinv.Rotate(_qrot.Rotate(ga[i][j])));
					
					th = 1;
					
					var p0x = cx + ga[i][0].X, p0y = cy + ga[i][0].Y;
					var p1x = cx + ga[i][1].X, p1y = cy + ga[i][1].Y;
					var p2x = cx + ga[i][2].X, p2y = cy + ga[i][2].Y;
					var p3x = cx + ga[i][3].X, p3y = cy + ga[i][3].Y;
					
					var _pax = (p0x + p1x + p2x + p3x) / 4;
					var _pay = (p0y + p1y + p2y + p3y) / 4;
					
					if((abs(p0x - _pax) + abs(p1x - _pax) + abs(p2x - _pax) + abs(p3x - _pax)) / 4 < 1)
						continue;
						
					if((abs(p0y - _pay) + abs(p1y - _pay) + abs(p2y - _pay) + abs(p3y - _pay)) / 4 < 1)
						continue;
					
					draw_set_color(COLORS.axis[(i - 3 - 1 + 3) % 3]);
					if(axis_hover == i || drag_axis == i) {
						draw_primitive_begin(pr_trianglestrip);
							draw_vertex(p0x, p0y);
							draw_vertex(p1x, p1y);
							draw_vertex(p3x, p3y);
							draw_vertex(p2x, p2y);
						draw_primitive_end();
						
					} else if (drag_axis == noone) {
						draw_line(p0x, p0y, p1x, p1y);
						draw_line(p1x, p1y, p2x, p2y);
						draw_line(p2x, p2y, p3x, p3y);
						draw_line(p3x, p3y, p0x, p0y);
					} else 
						continue;
					
					if(point_in_rectangle_points(_mx, _my, p0x, p0y, p1x, p1y, p3x, p3y, p2x, p2y))
						_hover = i;
				}
				
				if(drag_axis == 6) {
					draw_set_color(COLORS._main_icon);
					draw_line_dashed(cx, cy, _mx, _my);
				}
				
				axis_hover = _hover;
			#endregion
				
			if(drag_axis != noone) { // editing
				
				if(!MOUSE_WRAPPING) {
					if(KEYBOARD_NUMBER == undefined) {
						drag_mx += _mx - drag_px;
						drag_my += _my - drag_py;
							
						var mAdj, nor, prj, pln;
						var ray = _camera.viewPointToWorldRay(drag_mx, drag_my);
							
						if(drag_axis < 3) {
							switch(drag_axis) {
								case 0 : nor = new __vec3(0, 1, 0); prj = new __vec3(1,  0,  0); break;
								case 1 : nor = new __vec3(0, 0, 1); prj = new __vec3(0,  1,  0); break;
								case 2 : nor = new __vec3(0, 1, 0); prj = new __vec3(0,  0,  1); break;
							}
								
							nor = _qrot.Rotate(nor);
							prj = _qrot.Rotate(prj);
							
							pln  = new __plane(drag_original, nor);
							mAdj = d3d_intersect_ray_plane(ray, pln);
								
							if(drag_prev != undefined) {
								var _diff = mAdj.subtract(drag_prev);
								var _dist = _diff.dot(prj);
									
								drag_val[drag_axis] += _dist;
									
								if(node.inputs[index].setValue(value_snap(drag_val, _snx))) 
									UNDO_HOLDING = true;
							}
							
							drag_prev = mAdj;
							
						} else if(drag_axis < 6) {
							switch(drag_axis) {
								case 3 : nor = new __vec3(0, 0, 1); break;
								case 4 : nor = new __vec3(1, 0, 0); break;
								case 5 : nor = new __vec3(0, 1, 0); break;
							}
								
							nor = _qrot.Rotate(nor);
								
							pln  = new __plane(drag_original, nor);
							mAdj = d3d_intersect_ray_plane(ray, pln);
								
							if(drag_prev != undefined) {
								var _diff = mAdj.subtract(drag_prev);
									
								for( var i = 0; i < 3; i++ ) 
									drag_val[i] += _diff.getIndex(i);
									
								if(node.inputs[index].setValue(value_snap(drag_val, _snx))) 
									UNDO_HOLDING = true;
							}
							
							drag_prev = mAdj;
							
						} else if(drag_axis == 6) {
							var _origDist = point_distance(drag_cx, drag_cy, drag_sx, drag_sy);
							var _currDist = point_distance(drag_cx, drag_cy, drag_mx, drag_my);
							var _sca = _currDist / _origDist;
							var  val = [ drag_original.x * _sca, drag_original.y * _sca, drag_original.z * _sca ];
							
							if(node.inputs[index].setValue(val)) 
								UNDO_HOLDING = true;
						}
						
					} else {
						var val = [ drag_original.x, drag_original.y, drag_original.z ];
						if(drag_axis < 3) val[drag_axis] += KEYBOARD_NUMBER;
						else if(drag_axis == 6) {
							val[0] += KEYBOARD_NUMBER;
							val[1] += KEYBOARD_NUMBER;
							val[2] += KEYBOARD_NUMBER;
						}
						
						if(node.inputs[index].setValue(val)) 
							UNDO_HOLDING = true;
					}
				}
					
				setMouseWrap();
				drag_px = _mx;
				drag_py = _my;
				
				if((!activeKeyboard && mouse_release(mb_left)) || (activeKeyboard && (mouse_press(mb_left) || key_press(vk_enter))) ) {
					if(activeKeyboard) PANEL_PREVIEW.resetTool();
					
					drag_axis      = noone;
					UNDO_HOLDING   = false;
					activeKeyboard = false;
				}
				
				if(key_press(ord("X"))) {
					drag_axis = drag_axis == 0? 6 : 0;
					drag_val  = drag_original.toArray();
					drag_prev = undefined;
					KEYBOARD_STRING = "";
				}
				
				if(key_press(ord("Y"))) {
					drag_axis = drag_axis == 1? 6 : 1;
					drag_val  = drag_original.toArray();
					drag_prev = undefined;
					KEYBOARD_STRING = "";
				}
				
				if(key_press(ord("Z"))) {
					drag_axis = drag_axis == 2? 6 : 2;
					drag_val  = drag_original.toArray();
					drag_prev = undefined;
					KEYBOARD_STRING = "";
				}
				
				var _tooltipText = "Scaling";
				switch(drag_axis) {
					case 0 : _tooltipText += " X"; break;
					case 1 : _tooltipText += " Y"; break;
					case 2 : _tooltipText += " Z"; break;
					
					case 3 : _tooltipText += " XY"; break;
					case 4 : _tooltipText += " YZ"; break;
					case 5 : _tooltipText += " XZ"; break;
				}
				
				if(KEYBOARD_NUMBER != undefined)
					_tooltipText += $" [{KEYBOARD_NUMBER}]";
				
				PANEL_PREVIEW.setActionTooltip(_tooltipText);
				
			} else {
				if((_hover != noone && mouse_press(mb_left, active)) || activeKeyboard) {
					drag_axis = activeKeyboard? 6 : _hover;
					drag_prev = undefined;
					drag_mx	= _mx; drag_my = _my;
					drag_sx	= _mx; drag_sy = _my;
					drag_px = _mx; drag_py = _my;
					drag_cx =  cx; drag_cy =  cy;
						
					drag_val = [ _sca[0], _sca[1], _sca[2] ];
					drag_original = new __vec3(_sca);
				}
			}
		}
	}
	
#endregion

function Node_3D_Object(_x, _y, _group = noone) : Node_3D(_x, _y, _group) constructor {
	name  = "3D Object";
	gizmo = new __3dGizmoAxis(.2, COLORS._main_accent);
	
	cached_object = [];
	object_class  = noone;
	
	preview_channel = 0;
	apply_anchor    = false;
	
	newInput(0, nodeValue_Vec3(       "Position", [0,0,0], { linkable: false }));
	newInput(3, nodeValue_Vec3(       "Anchor",   [0,0,0], { linkable: false, 
			side_button: button(function() /*=>*/ { apply_anchor = !apply_anchor; triggerRender(); })
				.setIcon(THEME.icon_3d_anchor, [ function() /*=>*/ {return apply_anchor} ], c_white).setTooltip("Apply Position") 
		}));
	newInput(1, nodeValue_Quaternion( "Rotation", [0,0,0,1] ));
	newInput(2, nodeValue_Vec3(       "Scale",    [1,1,1]   ));
	
	in_d3d = array_length(inputs);
	
	#macro __d3d_input_list_transform ["Transform", false], 0, 3, 1, 2
	
	#region ---- overlay ----
		drag_axis  = noone;
		drag_sv    = 0;
		drag_delta = 0;
		drag_prev  = 0;
		drag_dist  = 0;
		drag_val   = 0;
		
		drag_mx = 0;
		drag_my = 0;
		drag_px = 0;
		drag_py = 0;
		drag_cx = 0;
		drag_cy = 0;
		drag_rot_axis = new BBMOD_Quaternion();
		
		drag_original = 0;
		
		axis_hover = noone;
	#endregion
	
	#region ---- tools ----
		tool_object_pos = new d3d_transform_tool_position(self);
		tool_object_rot = new d3d_transform_tool_rotation(self);
		tool_object_sca = new d3d_transform_tool_scale(self);
		
		tool_pos = new NodeTool( "Transform", THEME.tools_3d_transform, "Node_3D_Object" ).setToolObject(tool_object_pos);
		tool_rot = new NodeTool( "Rotate",    THEME.tools_3d_rotate,    "Node_3D_Object" ).setToolObject(tool_object_rot);
		tool_sca = new NodeTool( "Scale",     THEME.tools_3d_scale,     "Node_3D_Object" ).setToolObject(tool_object_sca);
		tools    = [ tool_pos, tool_rot, tool_sca ];
		
		tool_axis_edit = new scrollBox([ "local", "global" ], function(val) /*=>*/ { tool_attribute.context = val; });
		tool_attribute.context = 0;
		tool_settings = [ 
			[ "Axis", tool_axis_edit, "context", tool_attribute ],
		];
		
		static getToolSettings = function() /*=>*/ {return (isUsingTool("Transform") || isUsingTool("Rotate"))? tool_settings : []};
	#endregion
	
	static drawOverlay3D = function(active, params, _mx, _my, _snx, _sny, _panel) { 
		var object = getPreviewObjects();
		if(array_empty(object)) return;
		object = object[0];
		
		var _pos  = inputs[0].getValue(,,, true);
		var _vpos = new __vec3( _pos[0], _pos[1], _pos[2] );
		
		if(isUsingTool("Transform")) tool_object_pos.drawOverlay3D(0, object, _vpos, active, params, _mx, _my, _snx, _sny, _panel);
		if(isUsingTool("Rotate"))    tool_object_rot.drawOverlay3D(1, object, _vpos, active, params, _mx, _my, _snx, _sny, _panel);
		if(isUsingTool("Scale"))     tool_object_sca.drawOverlay3D(2, object, _vpos, active, params, _mx, _my, _snx, _sny, _panel);
		
		if(drag_axis != noone && mouse_release(mb_left)) {
			drag_axis = noone;
			UNDO_HOLDING = false;
		}
		
		onDrawOverlay3D(active, params, _mx, _my, _snx, _sny, _panel);
	} 
	
	static onDrawOverlay3D = function(active, params, _mx, _my, _snx, _sny, _panel) {}
	
	static setTransform = function(object, _data) {
		if(object == noone) return;
		var _pos = _data[0];
		var _rot = _data[1];
		var _sca = _data[2];
		var _anc = _data[3];
		
		if(apply_anchor)
			_pos = [
				_pos[0] + _anc[0],
				_pos[1] + _anc[1],
				_pos[2] + _anc[2],
			];
		
		gizmo.transform.position.set(	_pos[0], _pos[1], _pos[2]);
		
		object.transform.position.set(	_pos[0], _pos[1], _pos[2]);
		object.transform.anchor.set(	_anc[0], _anc[1], _anc[2]);
		object.transform.rotation.set(	_rot[0], _rot[1], _rot[2], _rot[3]);
		object.transform.scale.set(		_sca[0], _sca[1], _sca[2]);
		
		return object;
	}
		
	static getObject = function(index, class = object_class) {
		var _obj = array_safe_get_fast(cached_object, index, noone);
		
		if(_obj == noone) {
			_obj = new class();
		} else if(!is_instanceof(_obj, class)) {
			_obj.destroy();
			_obj = new class();
		}
		
		cached_object[index] = _obj;
		return _obj;
	}
	
	static getPreviewObjects		= function() { return [ getPreviewObject(), gizmo ]; }
	static getPreviewObjectOutline  = function() { return [ getPreviewObject(), gizmo ]; }
}