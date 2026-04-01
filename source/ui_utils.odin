package game

import rl "vendor:raylib"

draw_text_centered :: proc(
	font: rl.Font,
	msg: cstring,
	pos: [2]f32,
	fontSize: f32 = 10,
	fontSpacing: f32 = 1.0,
	color: rl.Color = rl.WHITE,
) {
	text_size := rl.MeasureTextEx(font, msg, fontSize, fontSpacing)
	rl.DrawTextEx(
		font,
		msg,
		{(pos.x) - (text_size.x / 2), (pos.y) - (text_size.y / 2)},
		fontSize,
		fontSpacing,
		color,
	)

}

ui_button_center :: proc(
	pos: [2]f32,
	msg: cstring,
	fontSize: f32 = 10,
	fontSpacing: f32 = 1.0,
) -> bool {
	text_size := rl.MeasureTextEx(rl.GuiGetFont(), msg, fontSize, fontSpacing)
	return rl.GuiButton(
		{(pos.x) - (text_size.x / 2), (pos.y) - (text_size.y / 2), text_size.x, text_size.y},
		msg,
	)

}

