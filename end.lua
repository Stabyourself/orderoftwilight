function end_load()
	love.graphics.setBackgroundColor(0.18, 0.75, 1)

	backflipi = 0
	xscroll = 0
	fadein = 1
	musicrev:stop()
	music:play()

	ponyjumptimes = {}
	ponyy = {}
	ponypositions = {{20, -18}, {-20, -18}, {30, 2}, {-25, 4}, {20, 10}}
	ponytimers = {}
	ponyspeedy = {}
	for i = 1, 5 do
		ponyy[i] = 0
		ponyjumptimes[i] = getrandomdelay()-1
		ponytimers[i] = 0
		ponyspeedy[i] = 0
	end
end

function getrandomdelay()
	return math.random()*2+0.5
end

function end_update(dt)
	for i = 1, 5 do
		ponytimers[i] = ponytimers[i] + dt
		if ponytimers[i] > ponyjumptimes[i] then
			ponytimers[i] = ponytimers[i] - ponyjumptimes[i]
			ponyjumptimes[i] = getrandomdelay()
			ponyspeedy[i] = 100
		end

		ponyy[i] = math.max(0, ponyy[i] + ponyspeedy[i]*dt)
		ponyspeedy[i] = ponyspeedy[i] - dt*300
	end

	backflipi = math.fmod(backflipi+dt, math.pi*1.5)
	xscroll = math.fmod(xscroll - dt*20, 240)

	fadein = math.max(0, fadein-dt)
end

function end_draw()
	for i = 4, 1, -1 do
		if i == 3 then
			love.graphics.draw(_G["background" .. i .. "img"], xscroll*scale, (4-i)*45, 0, scale, scale)
			love.graphics.draw(_G["background" .. i .. "img"], xscroll*scale+240*scale, (4-i)*45, 0, scale, scale)
		else
			love.graphics.draw(_G["background" .. i .. "img"], 0, (4-i)*45, 0, scale, scale)
		end
	end

	local sini = math.max(0, math.sin(backflipi))

	local r = sini
	if backflipi >= math.pi/2 then
		r = -r
	end

	love.graphics.draw(playeranimation.idle, 120*scale, (100-sini*70)*scale, r*math.pi, -scale*2, scale*2, 12.5, 12.5)

	for i = 1, 5 do
		if i == 3 then
			love.graphics.draw(playeranimation.idle, 120*scale, (100-sini*70)*scale, r*math.pi, -scale*2, scale*2, 12.5, 12.5)
		end

		local xscale = scale
		if ponypositions[i][1] < 0 then
			xscale = -xscale
		end
		love.graphics.draw(ponies[i], (120+ponypositions[i][1])*scale, (100+ponypositions[i][2]-ponyy[i])*scale, 0, -xscale*2, scale*2, 12.5, 12.5)
	end


	properprint("your mind is clear", 38, 2)
	properprint("the chaos is gone", 42, 10)

	love.graphics.setColor(1, 1, 1, fadein)
	love.graphics.rectangle("fill", 0, 0, 240*scale, 120*scale)
	love.graphics.setColor(1, 1, 1)
end

function end_keypressed(key, unicode)
	changegamestate("menu")
end