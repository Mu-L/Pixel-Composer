globalvar MATRIX_IDENTITY;

MATRIX_IDENTITY = matrix_build_identity();

#region format
	vertex_format_begin();
	vertex_format_add_position();
	vertex_format_add_color();
	global.format_pc = vertex_format_end();
#endregion

function vertex_add_pt(buffer, position, texture) {
	vertex_position_3d(buffer, position[0], position[1], position[2]);
	vertex_texcoord(buffer, texture[0], texture[1]);
}

function vertex_add_pnt(buffer, position, normal, texture) {
	vertex_position_3d(buffer, position[0], position[1], position[2]);
	vertex_normal(buffer, normal[0], normal[1], normal[2]);
	vertex_texcoord(buffer, texture[0], texture[1]);
}

function vertex_add_pntc(buffer, position, normal, texture, color = c_white, alpha = 1) {
	vertex_position_3d(buffer, position[0], position[1], position[2]);
	vertex_normal(buffer, normal[0], normal[1], normal[2]);
	vertex_texcoord(buffer, texture[0], texture[1]);
	vertex_color(buffer, color, alpha);
}

function vertex_add_2pc(buffer, _x, _y, color, alpha = 1) {
	vertex_position(buffer, _x, _y);
	vertex_color(buffer, color, alpha);
}

function vertex_add_v(buffer, vertex) {
	vertex_position_3d(buffer, vertex.x, vertex.y, vertex.z);
}

function vertex_add_vc(buffer, vertex) {
	vertex_position_3d(buffer, vertex.x, vertex.y, vertex.z);
	vertex_color(buffer, vertex.color, vertex.alpha);
}

function vertex_add_vnt(buffer, vertex) {
	var _normal = vertex.normal;
	var _uv = vertex.uv;
	
	vertex_position_3d(buffer, vertex.x, vertex.y, vertex.z);
	vertex_normal(buffer, _normal.x, _normal.y, _normal.z);
	vertex_texcoord(buffer, _uv.x, _uv.y);
}

function vertex_add_vntc(buffer, vertex) {
	var _normal = vertex.normal;
	var _uv = vertex.uv;
	
	vertex_position_3d(buffer, vertex.x, vertex.y, vertex.z);
	vertex_normal(buffer, _normal.x, _normal.y, _normal.z);
	vertex_texcoord(buffer, _uv.x, _uv.y);
	vertex_color(buffer, vertex.color, vertex.alpha);
}