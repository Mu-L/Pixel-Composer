function __Bone_Constrain_Copy_Position(_bone, _bid = "", _tid = "") : __Bone_Constrain(_bone) constructor {
    name      = "Copy Position";
    sindex    = 0;
    bone_id   = _bid;
    target_id = _tid;
    strength  = 1;
    
    bone_object   = noone;
    target_object = noone;
    
    tb_strength       = new textBox(TEXTBOX_INPUT.number, function(v) /*=>*/ { strength = clamp(v, 0, 1); node.triggerRender(); });
    tb_strength.font  = f_p2;
    tb_strength.label = "Strength";
    tb_strength.boxColor = COLORS._main_icon_light;
    
    static init = function() {
        if(!is(bone, __Bone)) return;
        
        bone_object   = bone_id == ""?   noone : bone.findBone(bone_id);
        target_object = target_id == ""? noone : bone.findBone(target_id);
    }
    
    static constrain = function(_b) {
        var _bone   = bone_id == ""?   noone : _b.findBone(bone_id);
        var _target = target_id == ""? noone : _b.findBone(target_id);
        if(_bone == noone || _target == noone) return;
        
        var _fr = _bone.getHead();
        var _to = _target.getHead();
        
        var _dr = point_direction(_fr.x, _fr.y, _to.x, _to.y);
        var _ds = point_distance(_fr.x, _fr.y, _to.x, _to.y);
        
        var _x = lerp(_fr.x, _to.x, strength);
        var _y = lerp(_fr.y, _to.y, strength);
        
        _bone.pose_direction = point_direction(0, 0, _x, _y);
        _bone.pose_distance  = point_distance(0, 0, _x, _y);
    }
    
    static draw_inspector = function(_x, _y, _w, _m, _hover, _focus, _drawParam) { 
        var wh = 0;
        
        // draw bones
        var _wdx =  _x + ui(8);
        var _wdw = (_w - ui(16 + 4)) / 2;
        var _wdh = ui(24);
        draw_sprite_stretched_ext(THEME.textbox, 3, _wdx,                _y, _wdw, _wdh, COLORS._main_icon_light, 1);
        draw_sprite_stretched_ext(THEME.textbox, 3, _wdx + _wdw + ui(4), _y, _wdw, _wdh, COLORS._main_icon_light, 1);
        
        if(bone_object != noone) {
            var _bname = bone_object.name;
            
            draw_sprite_ui(THEME.bone, 1, _wdx + ui(16), _y + _wdh / 2, 1, 1, 0, COLORS._main_icon, 1);
            draw_set_text(f_p2, fa_left, fa_center, COLORS._main_text);
            draw_text_add(_wdx + ui(32), _y + _wdh / 2, _bname);
            
        } else
            draw_sprite_ui(THEME.bone, 1, _wdx + ui(16), _y + _wdh / 2, 1, 1, 0, COLORS._main_icon, .5);
        
        if(target_object != noone) {
            var _bname = target_object.name;
            
            draw_sprite_ui(THEME.bone, 1, _wdx + _wdw + ui(4) + ui(16), _y + _wdh / 2, 1, 1, 0, COLORS._main_icon, 1);
            draw_set_text(f_p2, fa_left, fa_center, COLORS._main_text);
            draw_text_add(_wdx + _wdw + ui(4) + ui(32), _y + _wdh / 2, _bname);
            
        } else
            draw_sprite_ui(THEME.bone, 1, _wdx + _wdw + ui(4) + ui(16), _y + _wdh / 2, 1, 1, 0, COLORS._main_icon, .5);
        
        if(_hover && point_in_rectangle(_m[0], _m[1], _wdx, _y, _wdx + _wdw, _y + _wdh)) {
            draw_sprite_stretched_ext(THEME.textbox, 1, _wdx, _y, _wdw, _wdh, c_white, 1);
            if(mouse_click(mb_left, _focus))
                node.boneSelector(function(p) /*=>*/ { bone_id = p.bone.ID; init(); node.triggerRender(); });
        }
        
        if(_hover && point_in_rectangle(_m[0], _m[1], _wdx + _wdw + ui(4), _y, _wdx + _wdw + ui(4) + _wdw, _y + _wdh)) {
            draw_sprite_stretched_ext(THEME.textbox, 1, _wdx + _wdw + ui(4), _y, _wdw, _wdh, c_white, 1);
            if(mouse_click(mb_left, _focus)) 
                node.boneSelector(function(p) /*=>*/ { target_id = p.bone.ID; init(); node.triggerRender(); });
        }
        
        _y += _wdh + ui(4);
        wh += _wdh + ui(4);
        
        // draw widget
        var _wdx = _x + ui(8);
        var _wdw = _w - ui(16);
        var _wdh = ui(24);
        
        tb_strength.rx = _drawParam.rx;
        tb_strength.ry = _drawParam.ry;
        tb_strength.setFocusHover(_focus, _hover);
        tb_strength.draw(_wdx, _y, _wdw, _wdh, strength, _m);
        
        _y += _wdh + ui(8);
        wh += _wdh + ui(8);
        
        return wh;
    }
    
    static serialize   = function() { 
        var _map = {};
        _map.type      = "Copy Position";
        _map.bone_id   = bone_id;
        _map.target_id = target_id;
        _map.strength  = strength;
        
        return _map; 
    }
    
    static deserialize = function(_map) {
        bone_id   = _map.bone_id;
        target_id = _map.target_id;
        strength  = _map.strength;
        
        return self;
    }
}