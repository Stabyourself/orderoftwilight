function openspellbook()
	spellbookopen = true
	spellbooktimer = 1
	spellbookpage = 1

	spellsperpage = 4
end

function closespellbook()
	spellbooktimer = 1-spellbooktimer
	spellbookopen = false
end

function spellbook_update(dt)
	if spellbooktimer > 0 then
		spellbooktimer = spellbooktimer-spellbooktimer/2*dt*10-0.1*dt
		if spellbooktimer <= 0 then
			spellbooktimer = 0
		end
	end
end

function spellbook_draw()
	love.graphics.draw(spellbookimg, 2*scale,95*scale, 0, scale, scale)
	properprint("q", 17, 110, true)

	if spellbookopen or spellbooktimer > 0 then
		if not spellbookopen then
			love.graphics.translate(0, (1-spellbooktimer/1)*(-120*scale))
		else
			love.graphics.translate(0, spellbooktimer/1*(-120*scale))
		end

		love.graphics.draw(spellbookbookimg, 0, 0, 0, scale, scale)

		local y = 0
		for i = spellbookpage*spellsperpage-3, math.min(#spellnames, spellbookpage*spellsperpage) do
			local yadd = 0
			if spellnames[i].name then
				love.graphics.setColor(0.6, 0.6, 0.6)
				properprintsmall(spellnames[i].name, 130, y*22+20)
			else
				yadd = -10
			end
			love.graphics.setColor(0.2, 0.2, 0.2)

			for x = 1, #spells[spellnames[i].id] do
				local dir = spells[spellnames[i].id][x]
				local char
				if spelldiscovered[i] then
					love.graphics.setColor(0.2, 0.2, 0.2)
					if dir == "up" then
						char = "^"
					elseif dir == "right" then
						char = ">"
					elseif dir == "down" then
						char = "V"
					elseif dir == "left" then
						char = "<"
					end
				else
					love.graphics.setColor(0.82, 0.82, 0.82)
					char = "?"
				end

				properprintsmall(char, 130+(x-1)*9, y*22+28+yadd)
			end

			if spellnames[i].name then
				y = y + 1
			else
				y = y + 0.5
			end
		end
		love.graphics.setColor(1, 1, 1)


		if spellbookpage*4 < #spellnames then
			love.graphics.draw(bookarrowrightimg, 0, 0, 0, scale)
		end

		if spellbookpage > 1 then
			love.graphics.draw(bookarrowleftimg, 0, 0, 0, scale)
		end

		if not spellbookopen then
			love.graphics.translate(0, (1-spellbooktimer/1)*(120*scale))
		else
			love.graphics.translate(0, spellbooktimer/1*(120))
		end
	end
end

function spellbook_keypressed(key, unicode)
	if key == "q" or key == "escape" then
		closespellbook()
	end

	if key == "right" then
		if spellbookpage*4 < #spellnames then
			spellbookpage = spellbookpage + 1
		end
	end

	if key == "left" then
		if spellbookpage > 1 then
			spellbookpage = spellbookpage - 1
		end
	end
end