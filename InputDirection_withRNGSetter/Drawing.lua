Drawing = {
	WIDTH_OFFSET = 222,
	Screen = {
		Height = 0,
		Width = 0
	}
}

function Drawing.resizeScreen()
	screen = wgui.info()
	Drawing.Screen.Height = screen.height
	width10 = screen.width % 10
	if width10 == 0 or width10 == 4 or width10 == 8 then
		Drawing.Screen.Width = screen.width
		wgui.resize(screen.width + Drawing.WIDTH_OFFSET, screen.height)
	else
		Drawing.Screen.Width = screen.width - Drawing.WIDTH_OFFSET
	end
end

function Drawing.UnResizeScreen()
	wgui.resize(Drawing.Screen.Width, Drawing.Screen.Height)
end

function Drawing.paint()
	wgui.setbrush(Settings.Theme.Background)
	wgui.setpen(Settings.Theme.Background)
	wgui.rect(Drawing.Screen.Width, 0, Drawing.Screen.Width + Drawing.WIDTH_OFFSET, Drawing.Screen.Height - 20)
	for i = 1, table.getn(Buttons), 1 do
		if Buttons[i].type == ButtonType.button then
			Drawing.drawButton(Buttons[i].box[1], Buttons[i].box[2], Buttons[i].box[3], Buttons[i].box[4], Buttons[i].text, Buttons[i].pressed())
		elseif Buttons[i].type == ButtonType.textArea then
			local value = Buttons[i].value()
			Drawing.drawTextArea(Buttons[i].box[1], Buttons[i].box[2], Buttons[i].box[3], Buttons[i].box[4], value and string.format("%0".. tostring(Buttons[i].inputSize) .."d", value) or string.rep('-', Buttons[i].inputSize), Buttons[i].enabled(), Buttons[i].editing())
		end
	end
	Drawing.drawAnalogStick(Drawing.Screen.Width + Drawing.WIDTH_OFFSET / 3, 210)
	wgui.setcolor(Settings.Theme.Text)
	wgui.setfont(10,"Arial","")
	wgui.text(Drawing.Screen.Width + 149, 146, "Magnitude")
	Memory.Refresh()
	Drawing.drawAngles(Drawing.Screen.Width + 16, 280)
	Drawing.drawMiscData(Drawing.Screen.Width + 16, 310)
end

function Drawing.drawAngles(x, y)
	if Settings.ShowEffectiveAngles then
		wgui.text(x, y, "Yaw (Facing): " .. Engine.getEffectiveAngle(Memory.Mario.FacingYaw))
		wgui.text(x, y + 15, "Yaw (Intended): " .. Engine.getEffectiveAngle(Memory.Mario.IntendedYaw))
		wgui.text(x + 132, y, "O: " ..  (Engine.getEffectiveAngle(Memory.Mario.FacingYaw) + 32768) % 65536)--wgui.text(x, y + 30, "Opposite (Facing): " ..  (Engine.getEffectiveAngle(Memory.Mario.FacingYaw) + 32768) % 65536)
		wgui.text(x + 132, y + 15, "O: " ..  (Engine.getEffectiveAngle(Memory.Mario.IntendedYaw) + 32768) % 65536)--wgui.text(x, y + 45, "Opposite (Intended): " ..  (Engine.getEffectiveAngle(Memory.Mario.IntendedYaw) + 32768) % 65536)
	else
		wgui.text(x, y, "Yaw (Facing): " .. Memory.Mario.FacingYaw)
		wgui.text(x, y + 15, "Yaw (Intended): " .. Memory.Mario.IntendedYaw)
		wgui.text(x + 132, y, "O: " ..  (Memory.Mario.FacingYaw + 32768) % 65536) --wgui.text(x + 45, y, "Opposite (Facing): " ..  (Memory.Mario.FacingYaw + 32768) % 65536)
		wgui.text(x + 132, y + 15, "O: " ..  (Memory.Mario.IntendedYaw + 32768) % 65536)--wgui.text(x, y + 45, "Opposite (Intended): " ..  (Memory.Mario.IntendedYaw + 32768) % 65536)
	end
end

function Drawing.drawButton(x, y, width, length, text, pressed)
	if (pressed) then
		wgui.setcolor(Settings.Theme.Button.InvertedText)
	elseif (Settings.Theme.Button.Text) then
		wgui.setcolor(Settings.Theme.Button.Text)
	else
		wgui.setcolor(Settings.Theme.Text)
	end
	wgui.setfont(10,"Arial","")
	wgui.setbrush(Settings.Theme.Button.Outline)
	wgui.setpen(Settings.Theme.Button.Outline)
	wgui.rect(x + 1, y + 1, x + width + 1, y + length + 1)
	if (pressed) then wgui.setbrush(Settings.Theme.Button.Pressed.Top) else wgui.setbrush(Settings.Theme.Button.Top) end
	--if (pressed) then wgui.setpen("#FF8888") else wgui.setpen("#888888") end
	wgui.rect(x, y, x + width, y + length)
	if (pressed) then wgui.setbrush(Settings.Theme.Button.Pressed.Bottom) else wgui.setbrush(Settings.Theme.Button.Bottom) end
	if (pressed) then wgui.setpen(Settings.Theme.Button.Pressed.Bottom) else wgui.setpen(Settings.Theme.Button.Bottom) end
	wgui.rect(x+1, y+1 + length/2, x-1 + width, y-1 + length)
	wgui.text(x + width/1.5 - 4.5 * string.len(text), y + length/2 - 7.5, text)
end

function Drawing.drawTextArea(x, y, width, length, text, enabled, editing)
	wgui.setcolor(Settings.Theme.Text)
	wgui.setfont(16,"Courier","b")
	if (editing) then
		wgui.setbrush(Settings.Theme.InputField.Editing)
		if (Settings.Theme.InputField.EditingText) then wgui.setcolor(Settings.Theme.InputField.EditingText) end
	elseif (enabled) then
		wgui.setbrush(Settings.Theme.InputField.Enabled)
	else
		wgui.setbrush(Settings.Theme.InputField.Disabled)
	end
	wgui.setpen(Settings.Theme.InputField.OutsideOutline)
	wgui.rect(x + 1, y + 1, x + width + 1, y + length + 1)
	wgui.setpen(Settings.Theme.InputField.Outline)
	wgui.line(x+2,y+2,x+2,y+length)
	wgui.line(x+2,y+2,x+width,y+2)
	if (editing) then
		selectedChar = Settings.Layout.TextArea.selectedChar
		Settings.Layout.TextArea.blinkTimer = (Settings.Layout.TextArea.blinkTimer + 1) % Settings.Layout.TextArea.blinkRate
		if (Settings.Layout.TextArea.blinkTimer == 0) then
			Settings.Layout.TextArea.showUnderscore = not Settings.Layout.TextArea.showUnderscore
		end
		if (Settings.Layout.TextArea.showUnderscore) then
			text = string.sub(text,1, selectedChar - 1) .. "_" .. string.sub(text, selectedChar + 1, string.len(text))
		end
	end
	wgui.text(x + width/2 - 6.5 * string.len(text), y + length/2 - 8, text)
end

function Drawing.drawAnalogStick(x, y)
	wgui.setpen(Settings.Theme.Joystick.Crosshair)
	wgui.setbrush(Settings.Theme.Joystick.Background)
	wgui.rect(x-64,y-64,x+64,y+64)
	wgui.setbrush(Settings.Theme.Joystick.Circle)
	wgui.ellipse(x-64,y-64,x+64,y+64)
	if Settings.goalMag and Settings.goalMag < 127 then
		wgui.setbrush(Settings.Theme.Joystick.MagBoundary)
		local r = Settings.goalMag + 6
		wgui.ellipse(x-r/2,y-r/2,x+r/2,y+r/2)
	end
	wgui.line(x-64, y, x+64, y)
	wgui.line(x, y-64, x, y+64)
	wgui.setpen(Settings.Theme.Joystick.Stick)
	wgui.line(x, y, x + Joypad.input.X/2,y - Joypad.input.Y/2)
	wgui.setpen(Settings.Theme.Joystick.Dot)
	wgui.setbrush(Settings.Theme.Joystick.Dot)
	wgui.ellipse(x-4 + Joypad.input.X/2,y-4 - Joypad.input.Y/2,x+4 + Joypad.input.X/2,y+4 - Joypad.input.Y/2)
	wgui.setcolor(Settings.Theme.Text)
	wgui.setfont(10,"Courier","")
	local stick_y = Joypad.input.Y == 0 and "0" or -Joypad.input.Y
	wgui.text(x + 90 - 2.5 * (string.len(stick_y)), y + 4, "y:" .. stick_y)
	wgui.text(x + 90 - 2.5 * (string.len(Joypad.input.X)), y - 14, "x:" .. Joypad.input.X)
end

function Drawing.drawMiscData(x, y)
	speed = 0
	if Memory.Mario.HSpeed ~= 0 then
		speed = MoreMaths.DecodeDecToFloat(Memory.Mario.HSpeed)
	end
	wgui.text(x, y, "H Spd: " .. MoreMaths.Round(speed, 5))

	wgui.text(x, y + 45, "Spd Efficiency: " .. Engine.GetSpeedEfficiency() .. "%")

	speed = 0
	if Memory.Mario.VSpeed > 0 then
		speed = MoreMaths.Round(MoreMaths.DecodeDecToFloat(Memory.Mario.VSpeed), 6)
	end
	wgui.text(x, y + 60, "Y Spd: " .. speed)

	wgui.text(x, y + 15, "H Sliding Spd: " .. MoreMaths.Round(Engine.GetHSlidingSpeed(), 6))

	wgui.text(x, y + 75, "Mario X: " .. MoreMaths.Round(MoreMaths.DecodeDecToFloat(Memory.Mario.X), 2), 6)
	wgui.text(x, y + 90, "Mario Y: " .. MoreMaths.Round(MoreMaths.DecodeDecToFloat(Memory.Mario.Y), 2), 6)
	wgui.text(x, y + 105, "Mario Z: " .. MoreMaths.Round(MoreMaths.DecodeDecToFloat(Memory.Mario.Z), 2), 6)

	wgui.text(x, y + 30, "XZ Movement: " .. MoreMaths.Round(Engine.GetDistMoved(), 6))

	wgui.text(x, y + 120, "Action: " .. Engine.GetCurrentAction())

	distmoved = Engine.GetTotalDistMoved()
	if (Settings.Layout.Button.dist_button.enabled == false) then
		distmoved = Settings.Layout.Button.dist_button.dist_moved_save
	end
	wgui.text(x, y + 135, "Moved Dist: " .. distmoved)
	wgui.text(x + 172, y, "E: " .. Settings.Layout.Button.strain_button.arctanexp)
	wgui.text(x + 132, y + 60, "R: " .. MoreMaths.Round(Settings.Layout.Button.strain_button.arctanr, 5))
	wgui.text(x + 132, y + 75, "D: " .. MoreMaths.Round(Settings.Layout.Button.strain_button.arctand, 5))
	wgui.text(x + 132, y + 90, "N: " .. MoreMaths.Round(Settings.Layout.Button.strain_button.arctann, 2))
	wgui.text(x + 132, y + 105, "S: " .. MoreMaths.Round(Settings.Layout.Button.strain_button.arctanstart + 1, 2))

	wgui.text(x, y + 150, "Read-write: ")
	if emu.isreadonly() then 
		readwritestatus = "disabled" 
		wgui.setcolor(Settings.Theme.Text)
	else 
		readwritestatus = "enabled"
		wgui.setcolor(Settings.Theme.ReadWriteText)
	end
	wgui.text(x + 68, y + 150, readwritestatus)

	wgui.setcolor(Settings.Theme.Text)
	wgui.text(x, y + 230, "RNG Value: " .. Memory.RNGValue)
	wgui.text(x, y + 245, "RNG Index: " .. get_index(Memory.RNGValue))
end
