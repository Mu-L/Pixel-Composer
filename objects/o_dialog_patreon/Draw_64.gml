/// @description init
if !ready exit;

#region base UI
	DIALOG_DRAW_BG
	
	draw_sprite_stretched_ext(THEME.ui_panel_bg, 3, dialog_x + 3, dialog_y + 3, dialog_w - 6, title_height + 2, COLORS._main_icon_light, 1);
	draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text_sub);
	draw_text_cut(dialog_x + ui(10), dialog_y + ui(8), "Patreon connect", dialog_w - ui(32 + 32));
	
	var _bx = dialog_x + dialog_w - ui(28);
	var _by = dialog_y + ui(8);
	var _bs = ui(20);
	
	if(buttonInstant(THEME.button_hide, _bx, _by, _bs, _bs, [ mouse_mx, mouse_my ], sFOCUS, sHOVER, "", THEME.window_exit) == 2) {
		DIALOG_POSTDRAW
		onDestroy();
		instance_destroy();
	}
	
	if(sFOCUS) DIALOG_DRAW_FOCUS
#endregion

#region patreon login
	var cx = dialog_x + dialog_w / 2;
	var yy = dialog_y + title_height + ui(16);
	
	draw_sprite(s_patreon_banner, 0, cx, yy);
	
	var _bw = ui(172);
	var _bh = ui(32);
	var _bx = cx - _bw / 2;
	var _by = yy + ui(104);
	
	if(buttonInstant(THEME.button_def, _bx, _by, _bw, _bh, mouse_ui, sFOCUS, sHOVER) == 2) {
		var _url = @"www.patreon.com/oauth2/authorize?response_type=code
&client_id=oZ1PNvUY61uH0FiA7ZPMBy77Xau3Ok9tfvsT_Y8DQwyKeMNjaVC35r1qsK09QJhY
&redirect_uri=https://pixel-composer.com/verify";
		_url += $"&state={port}";

		url_open(_url);
	}
	
	draw_set_text(f_p1, fa_center, fa_center, COLORS._main_text);
	draw_text(cx, _by + _bh / 2, "Sign-in with Patreon");
#endregion