function menu_load()
	if not xscroll then
		screendarkness = 1
	end
	love.graphics.setBackgroundColor(0.18, 0.75, 1)
	xscroll = 0
	menuitems = {"start game", "all runes game", "challenges", "quit"}
	twilightframe = 1
	twilighttimer = 0
	noise = 0

	if gamefinished then
		for i = 1, #spellnames do
			spelldiscovered[i] = true
		end
	end
	music:stop()
	musicrev:play()
end

function menu_update(dt)
	if screendarkness > 0 then
		screendarkness = math.max(0, screendarkness - dt/2)
	end

	xscroll = xscroll + 10*dt

	twilighttimer = twilighttimer + dt
	while twilighttimer > 0.2 do
		twilighttimer = twilighttimer - 0.2
		twilightframe = twilightframe + 1
		if twilightframe > 4 then
			twilightframe = 1
		end
	end

	if twilighty > menuselection then
		twilighty = twilighty - (twilighty-menuselection)/2*dt*30 - dt
		if twilighty < menuselection then
			twilighty = menuselection
		end
	elseif twilighty < menuselection then
		twilighty = twilighty - (twilighty-menuselection)/2*dt*30 + dt
		if twilighty > menuselection then
			twilighty = menuselection
		end
	end

	if offset > targetoffset then
		offset = offset - (offset-targetoffset)/2*dt*20 - dt
		if offset < targetoffset then
			offset = targetoffset
		end
	elseif offset < targetoffset then
		offset = offset - (offset-targetoffset)/2*dt*20 + dt
		if offset > targetoffset then
			offset = targetoffset
		end
	end
end

function menu_draw()
	love.graphics.draw(_G["background4noiseimg"], 0, 0, 0, scale, scale)
	for i = backgrounds-1, 1, -1  do
		local xscroll = xscroll / i * 4
		for x = 1, 2 do
			love.graphics.draw(_G["background" .. i .. "noiseimg"], math.floor(((x-1)*240)*scale) - math.floor(math.fmod(xscroll, 240)*scale), (backgrounds-i)*10*scale, 0, scale, scale)
		end
	end

	love.graphics.translate(-offset*scale, 0)
		--MAIN MENU
		love.graphics.draw(titleimg, 0, 0, 0, scale, scale)

		for i = 1, #menuitems do
			love.graphics.setColor(1, 1, 1)
			if (i == 2 or i == 3) and not gamefinished then
				love.graphics.setColor(0.8, 0.8, 0.8)
			end
			properprint(menuitems[i], 70, 40+15*i, i == menuselection and (i ~= 2 and i ~= 3 or gamefinished))
		end

		love.graphics.draw(playeranimation.walk[twilightframe], (70 - 25)*scale, (30+15*twilighty)*scale, 0, scale, scale)

		--CHALLENGES
		properprint("use as few spells as possible", 244, 2)
		for y = 1, 3 do
			for x = 1, 4 do
				local i = x+(y-1)*4
				if i == currentchallenge then
					love.graphics.setColor(1, 1, 1)
				else
					love.graphics.setColor(0.5, 0.5, 0.5)
				end
				local cox, coy = (253+(x-1)*55)*scale, (12+(y-1)*33)*scale
				love.graphics.rectangle("fill", cox-1*scale, coy-1*scale, (240*(scale/5))+2*scale, (120*(scale/5))+8*scale)
				love.graphics.draw(thumb[i], cox, coy, 0, scale/5, scale/5)
				love.graphics.setColor(0.08, 0.08, 0.08)
				properprintsmall("goal", cox/scale+1, coy/scale+25)
				local num = tostring(goalspells[i])
				properprintsmall(num, cox/scale+48-6*#tostring(num), coy/scale+25)
				if i == currentchallenge then
					love.graphics.setColor(1, 1, 1)
				else
					love.graphics.setColor(0.5, 0.5, 0.5)
				end
				properprintsmall("best", cox/scale+1, coy/scale+18)
				local num = ""
				if bestspells[i] then
					num = tostring(bestspells[i])
				end
				properprintsmall(num, cox/scale+48-6*#tostring(num), coy/scale+18)
			end
		end

		if currentchallenge > 12 then
			love.graphics.setColor(1, 1, 1)
		else
			love.graphics.setColor(0.5, 0.5, 0.5)
		end
		love.graphics.rectangle("fill", 343*scale, 110*scale, 33*scale, 9*scale)
		love.graphics.setColor(0, 0, 0)
		properprint("back", 344, 111)

		love.graphics.setColor(1, 1, 1)
	love.graphics.translate(offset*scale, 0)

	love.graphics.setColor(0, 0, 0, screendarkness)
	love.graphics.rectangle("fill", 0, 0, 480*scale, 120*scale)
	love.graphics.setColor(1, 1, 1)
end

function menu_keypressed(key)
	if challengemenu then
		if key == "up" then
			currentchallenge = currentchallenge - 4
			playsound(menumovesound)
		elseif key == "down" then
			currentchallenge = currentchallenge + 4
			playsound(menumovesound)
		elseif key == "right" then
			currentchallenge = currentchallenge + 1
			playsound(menumovesound)
		elseif key == "left" then
			currentchallenge = currentchallenge - 1
			playsound(menumovesound)
		end

		if currentchallenge <= 0 then
			currentchallenge = currentchallenge + 16
		elseif currentchallenge > 16 then
			currentchallenge = currentchallenge - 16
		end

		if key == "return" then
			if currentchallenge > 12 then
				challengemenu = false
				targetoffset = 0
				playsound(menubacksound)
			else
				changegamestate("game")
				playsound(menuselectsound)
			end
		end

		if key == "escape" then
			challengemenu = false
			targetoffset = 0
			playsound(menubacksound)
		end

		return
	else
		if (key == "up" or key == "w") and menuselection > 1 then
			menuselection = menuselection - 1
			playsound(menumovesound)
		elseif (key == "down" or key == "s") and menuselection < #menuitems then
			menuselection = menuselection + 1
			playsound(menumovesound)
		end
	end

	if key == "return" then
		if menuselection == 1 then
			changegamestate("story")
			allrunes = false
			playsound(menuselectsound)
		elseif menuselection == 2 and gamefinished then
			changegamestate("story")
			allrunes = true
			playsound(menuselectsound)
		elseif menuselection == 3 and gamefinished then
			allrunes = false
			challengemenu = true
			targetoffset = 240
			playsound(menuselectsound)
		elseif menuselection == 4 then
			love.event.quit()
			playsound(menubacksound)
		end
	end
end