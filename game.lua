function game_load()
	love.graphics.setBackgroundColor(0.18, 0.75, 1)

	xscroll = 0
	yscroll = 0

	if challengemenu then
		startlevel(currentchallenge)
	else
		startlevel(1)
	end

	gamewintimer = -1
	gamewon = false
end

function game_update(dt)
	spellbook_update(dt)


	local xstart = math.max(math.floor(xscroll), 1)

	if spellbookopen then
		return
	end

	for i, v in pairs(objects) do
		if i ~= "tile" and (not timefrozen or i == "player") then
			local delete = {}

			for j, k in pairs(v) do
				if k.update then
					if k:update(dt) then
						table.insert(delete, j)
					end
				end
			end

			table.sort(delete, function(a,b) return a>b end)

			for j, k in pairs(delete) do
				table.remove(v, k)
			end
		end
	end

	if timefreezetimer > 0 then
		timefreezetimer = timefreezetimer - dt
		if timefreezetimer <= 0 then
			timefrozen = false
		end
	end

	--DAMAGENUMBERS
	local delete = {}

	for i, v in pairs(damagenumbers) do
		if v:update(dt) then
			table.insert(delete,i)
		end
	end

	table.sort(delete, function(a,b) return a>b end)

	for j, k in pairs(delete) do
		table.remove(damagenumbers, k)
	end

	---------------------

	physicsupdate(dt)

	for i = 1, runecount do
		if runeanimationtimer[i] > 0 then
			runeanimationtimer[i] = math.max(0, runeanimationtimer[i] - dt*10)
		end
	end

	if #currentspell > 0 then
		spelltimeouttimer = spelltimeouttimer + dt
		if spelltimeouttimer > spelltimeout then
			spelltimeouttimer = 0
			currentspell = {}
		end
	end

	if objects.player[1].x > xscroll - scrollborderright+width then
		xscroll = objects.player[1].x+scrollborderright-width
	elseif objects.player[1].x < xscroll + scrollborderleft then
		xscroll = objects.player[1].x-scrollborderleft
	end

	xscroll = math.max(0, math.min(mapwidth-width, xscroll))

	if math.floor(xscroll)+1 ~= spritebatchx then
		generatespritebatch()
	end

	if texts[currentlevel] and #texts[currentlevel] > textprogress then
		if objects.player[1].x > texts[currentlevel][textprogress+1].x then
			textprogress = textprogress + 1
			texttimer = 0
		end
	end

	if texttimer < 1 then
		texttimer = math.min(1, texttimer+dt)
	end

	if deathtimer < deathtime then
		if deathtimer == 0 then
			--playsound(noisesound)
		end
		deathtimer = deathtimer + dt
		noise = math.floor(deathtimer/deathtime*noisecount)
		if deathtimer >= deathtime then
			if dead then
				startlevel(currentlevel)
			else
				if not allrunes then
					checkhighscore()
				end
				if challengemenu then
					changegamestate("menu")
				else
					startlevel(currentlevel+1)
				end
			end
			return
		end
	else
		noise = math.max(0, noise - dt*200)
	end

	if lastspelltimer < lastspelltime then
		lastspelltimer = math.min(lastspelltime, lastspelltimer+dt)
	end

	if newrunetimer > 0 then
		newrunetimer = math.max(0, newrunetimer-dt)
	end

	if gamewintimer > -1 then
		gamewintimer = gamewintimer - dt
		if gamewintimer <= -1 then
			changegamestate("end")
		end
		gamefinished = true
		savehighscores()
	end
end

function game_draw()
	for i = backgrounds, 1, -1  do
		local xscroll = xscroll / i * 4
		for x = 1, math.ceil(width*tilewidth/240)+1 do
			love.graphics.draw(_G["background" .. i .. "noiseimg"], math.floor(((x-1)*240)*scale) - math.floor(math.fmod(xscroll, 240)*scale), 0, 0, scale, scale)
		end
	end

	drawworld()

	love.graphics.stencil(drawworld, "replace", 1)
	love.graphics.setStencilTest("greater", 0)

	for i = 1, levelnoise do
		love.graphics.draw(noiseimg, math.floor(-xscroll*tilewidth*scale), 0, 0, scale, scale)
	end

	love.graphics.setStencilTest()

	if not challengemenu then
		for i = 1, textprogress do
			if i == textprogress then
				love.graphics.setColor(1, 1, 1, texttimer)
			end
			properprint(texts[currentlevel][i].text, ((texts[currentlevel][i].cox-xscroll)*tilewidth), (texts[currentlevel][i].coy*tilewidth), true)
			love.graphics.setColor(1, 1, 1)
		end
	end

	for i = 1, #customimages do
		love.graphics.draw(_G["image" .. customimages[i].i .. "img"], math.floor((customimages[i].x-xscroll)*tilewidth*scale), math.floor((customimages[i].y-yscroll)*tilewidth*scale), 0, scale, scale)
	end

	for i, v in pairs(objects) do
		if i ~= "tile" then
			for j, k in pairs(v) do
				if k.draw then
					k:draw()
				end
			end
		end
	end
	for i, v in pairs(damagenumbers) do
		v:draw()
	end

	for i = 1, runecount do
		local graphic = arrow.back

		love.graphics.draw(graphic, ((width*tilewidth)/2 - (runecount-1)/2*(runesize+runespacing) + (i-1)*(runesize+runespacing))*scale, 110*scale, 0, scale+scale*runeanimationtimer[i], scale+scale*runeanimationtimer[i], runesize/2, runesize/2)

		if currentspell[i] then
			graphic = arrow[currentspell[i] ]

			if runeanimationtimer[i] > 0 then
				love.graphics.setColor(0.8, 0.52, 0.82, (1-runeanimationtimer[i]))
				love.graphics.draw(arrow.glow, ((width*tilewidth)/2 - (runecount-1)/2*(runesize+runespacing) + (i-1)*(runesize+runespacing))*scale, 110*scale, 0, scale+scale*runeanimationtimer[i], scale+scale*runeanimationtimer[i], 15, 15)
				love.graphics.setColor(1, 1, 1)
			end

			if spelltimeouttimer > spelltimeout - .5 then
				local a = (spelltimeout - spelltimeouttimer)/.5
				love.graphics.setColor(1, 1, 1, a)
			end

			love.graphics.draw(graphic, ((width*tilewidth)/2 - (runecount-1)/2*(runesize+runespacing) + (i-1)*(runesize+runespacing))*scale, 110*scale, 0, scale+scale*runeanimationtimer[i], scale+scale*runeanimationtimer[i], runesize/2, runesize/2)

			love.graphics.setColor(1, 1, 1)
		end

		if i == runecount and newrunetimer > 0 then
			love.graphics.setColor(1, 1, 1, newrunetimer/newrunetime)
			love.graphics.draw(arrow.glow, ((width*tilewidth)/2 - (runecount-1)/2*(runesize+runespacing) + (i-1)*(runesize+runespacing))*scale, 110*scale, 0, scale*(newrunetimer/newrunetime)+.5, scale*(newrunetimer/newrunetime)+.5, 15, 15)
			love.graphics.setColor(1, 1, 1)
		end
	end

	if lastspelltimer < lastspelltime then
		for i = 1, #lastspell do
			graphic = arrow[lastspell[i] ]
			love.graphics.setColor(1, 1, 1, 1-lastspelltimer/lastspelltime)
			love.graphics.draw(graphic, ((width*tilewidth)/2 - (runecount-1)/2*(runesize+runespacing) + (i-1)*(runesize+runespacing))*scale, 110*scale, 0, scale+scale*(lastspelltimer/lastspelltime)*1, scale+scale*(lastspelltimer/lastspelltime)*1, runesize/2, runesize/2)
			love.graphics.setColor(1, 1, 1)
		end
	end

	if timefreezetimer > 0 then
		love.graphics.setColor(0.6, 0.85, 0.92, timefreezetimer/timefreezetime)
		love.graphics.draw(screengradientimg, 0, 0, 0, scale, scale)
		love.graphics.setColor(1, 1, 1)
	end

	spellbook_draw()

	if physicsdebug then
		love.graphics.setColor(1, 0, 0)
		for i, v in pairs(objects) do
			for j, k in pairs(v) do
				love.graphics.rectangle("line", math.floor((k.x-xscroll)*tilewidth*scale)-.5, math.floor((k.y-yscroll)*tilewidth*scale)-.5, k.width*tilewidth*scale, k.height*tilewidth*scale)
			end
		end
		love.graphics.setColor(1, 1, 1)
	end


	love.graphics.setColor(0, 1, 0)
	for i = 1, #debugshapes do
		love.graphics.rectangle("line", math.floor((debugshapes[i][1]-xscroll)*tilewidth*scale)-.5, math.floor((debugshapes[i][2]-yscroll)*tilewidth*scale)-.5, debugshapes[i][3]*tilewidth*scale, debugshapes[i][4]*tilewidth*scale)
	end
	love.graphics.setColor(1, 1, 1)

	if gamewintimer > -1 then
		love.graphics.setColor(1, 1, 1, math.min(1, 1-gamewintimer/gamewintime))
		love.graphics.rectangle("fill", 0, 0, width*tilewidth*scale, height*tilewidth*scale)
		love.graphics.setColor(1, 1, 1)
	end

	if objects.player[1].ascendtimer > 0.1 then
		local a = math.min(1, (1-(objects.player[1].ascendtimer-0.1)/ascendtime))
		love.graphics.setColor(1, 1, 1, a)
		love.graphics.rectangle("fill", 0, 0, 240*scale, 120*scale)
		love.graphics.setColor(1, 1, 1)
	end
end

function generatespritebatch()
	worldspritebatch:clear()

	local xstart = math.floor(xscroll)+1
	spritebatchx = xstart

	for x = 1, math.min(mapwidth+1-xstart, width+1) do
		for y = 1, mapheight do
			local tile = map[xstart+x-1][y][1]
			if tile ~= 1 then
				worldspritebatch:add(tilequads[tile].quad, (x-1)*tilewidth, (y-1)*tilewidth)
			end
		end
	end
end

function drawworld()
	love.graphics.draw(worldspritebatch, math.floor(-math.fmod(xscroll, 1)*tilewidth*scale), 0, 0, scale, scale)
end

function startlevel(s)
	spritebatchx = -1
	spellcount = 0
	ingamenoise = 0
	levelnoise = 1
	backgroundnoise = 0
	backgrounddarken = 0

	worldspritebatch = love.graphics.newSpriteBatch( tilequads[1].img, 1100 )

	lastspelltimer = lastspelltime
	spellbooktimer = 0
	timefreezetimer = 0
	timefrozen = false
	texttimer = 1
	currentlevel = tonumber(s)
	objects = {}
	objects.tile = {}
	objects.laser = {}
	objects.cube = {}
	objects.diamonddog = {}
	objects.woodblock = {}
	objects.stomper = {}
	objects.failbox = {}
	objects.shockwave = {}
	objects.page = {}

	levelrunecount = {3, 3, 4, 4, 4, 5, 6, 6, 6, 6, 6, 6, 6}
	runecount = levelrunecount[currentlevel]

	if allrunes then
		runecount = 8
	end

	customimages = {}

	damagenumbers = {}

	newrunetimer = 0
	deathtimer = deathtime
	startx = 4
	starty = 4
	noise = 100

	mapload(s)

	objects.player = {player:new(startx, starty)}

	skipupdate = true
	currentspell = {}
	runeanimationtimer = {}
	for i = 1, maxrunecount do
		runeanimationtimer[i] = 0
	end

	spelltimeouttimer = 0
	textprogress = 0
	generatespritebatch()
end

function mapload(s)
	mapimgdata = love.image.newImageData("maps/" .. s .. ".png")
	mapwidth = mapimgdata:getWidth()
	mapheight = mapimgdata:getHeight()

	roughmap = {}
	for x = 1, mapwidth do
		roughmap[x] = {}
		for y = 1, mapheight do
			local r, g, b = mapimgdata:getPixel(x-1, y-1)

			r = math.floor(r * 255+0.5)
			g = math.floor(g * 255+0.5)
			b = math.floor(b * 255+0.5)

			if r == 0 and g == 0 and b == 0 then
				roughmap[x][y] = 0 --black
			elseif r == 255 and g == 255 and b == 255 then
				roughmap[x][y] = 1 --white
			elseif r == 34 and g == 177 and b == 76 then
				roughmap[x][y] = 2 --spike
			elseif r<100 and r == g and g == b then
				local count = 0

				if (mapimgdata:getPixel(x-2, y-1) == 0) then
					count = count + 1
				end
				if (mapimgdata:getPixel(x-1, y-2) == 0) then
					count = count + 1
				end
				if (mapimgdata:getPixel(x, y-1) == 0) then
					count = count + 1
				end
				if (mapimgdata:getPixel(x-1, y) == 0) then
					count = count + 1
				end

				if count >= 3 then
					roughmap[x][y] = 0
				else
					roughmap[x][y] = 1
				end
				table.insert(customimages, {x=x-1, y=y-1, i=r})
			else
				local tileno = gettile(r, g, b, a)

				tileno = (tonumber(string.sub(tileno, 2)) or tileno)

				if tileno == "start" then
					startx = x
					starty = y
				elseif tileno == "diamonddog" then
					table.insert(objects.diamonddog, diamonddog:new(x, y))
				elseif tileno == "woodblock" then
					table.insert(objects.woodblock, woodblock:new(x-1, y-1))
				elseif tileno == "stomper" then
					table.insert(objects.stomper, stomper:new(x-1, y-1))
				elseif tileno == "page" then
					if runecount < 8 then
						table.insert(objects.page, page:new(x-1, y-1))
					end
				elseif tileno == "letter" then
					if runecount < 8 then
						table.insert(objects.page, page:new(x-1, y-1, true))
					end
				end

				roughmap[x][y] = 1 --white
			end
		end
	end

	map = {}
	for x = 1, mapwidth do
		map[x] = {}
		for y = 1, mapheight do
			if roughmap[x][y] == 0 then
				--true -> schwarzer pixel/wand
				local directions = {}
				for i = 1, 8 do --set all directions to false
					directions[i] = false
				end

				if x == 1 or y == 1 or roughmap[x-1][y-1] == 0 then
					directions[1] = true
				end

				if y == 1 or roughmap[x][y-1] == 0 then
					directions[2] = true
				end

				if x == mapwidth or y == 1 or roughmap[x+1][y-1] == 0 then
					directions[3] = true
				end

				if x == mapwidth or roughmap[x+1][y] == 0 then
					directions[4] = true
				end

				if x == mapwidth or y == mapheight or roughmap[x+1][y+1] == 0 then
					directions[5] = true
				end

				if y == mapheight or roughmap[x][y+1] == 0 then
					directions[6] = true
				end

				if x == 1 or y == mapheight or roughmap[x-1][y+1] == 0 then
					directions[7] = true
				end

				if x == 1 or roughmap[x-1][y] == 0 then
					directions[8] = true
				end

				for i = 2, 48 do
					notfitting = false
					for j = 1, 8 do
						if tiledb[i][j] ~= 2 then
							if (tiledb[i][j] == 1 and directions[j] == false) or (tiledb[i][j] == 0 and directions[j] == true) then
								notfitting = true
								break
							end
						end
					end
					if notfitting == false then
						map[x][y] = {i}
					end
				end

				if map[x][y][1] == nil then
					print("error lol (Don't know what tile to pick): "..x.." "..y)
				end

				if tilequads[map[x][y][1]].collision then
					table.insert(objects.tile, tile:new(x, y))
				end
			elseif roughmap[x][y] == 2 then
				if (inmap(x-1, y) and roughmap[x-1][y] == 2) or (inmap(x+1, y) and roughmap[x+1][y] == 2) then --horizontal
					if not inmap(x, y-1) or roughmap[x][y-1] == 0 then
						map[x][y] = {51}
					else
						map[x][y] = {49}
					end
				elseif (inmap(x, y-1) and roughmap[x][y-1] == 2) or (inmap(x, y+1) and roughmap[x][y+1] == 2) then
					if not inmap(x-1, y) or roughmap[x-1][y] == 0 then
						map[x][y] = {50}
					else
						map[x][y] = {52}
					end
				else
					map[x][y] = {49}
				end

				table.insert(objects.tile, tile:new(x, y))

			else
				map[x][y] = {roughmap[x][y]}
			end
		end
	end


end

function levelwin()
	dead = false
	deathtimer = 0
end

function leveldie()
	dead = true
	deathtimer = 0
end

function damageinworld(x, y, i)
	table.insert(damagenumbers, damagenumber:new((x-xscroll)*tilewidth, (y-yscroll)*tilewidth, i))
end

function inmap(x, y)
	return x >= 1 and y >= 1 and x <= mapwidth and y <= mapheight
end

function gettile(r, g, b, a)
	for i, v in pairs(tilelist) do
		if r == tilelist[i][1] and g == tilelist[i][2] and b == tilelist[i][3] then
			return i
		end
	end

	return 1
end

function leftkey()
	if objects.player[1].gravitydirection > math.pi/4*1 and objects.player[1].gravitydirection <= math.pi/4*3 then
		return love.keyboard.isDown("a")
	elseif objects.player[1].gravitydirection > math.pi/4*3 and objects.player[1].gravitydirection <= math.pi/4*5 then
		return love.keyboard.isDown("w")
	elseif objects.player[1].gravitydirection > math.pi/4*5 and objects.player[1].gravitydirection <= math.pi/4*7 then
		return love.keyboard.isDown("d")
	else
		return love.keyboard.isDown("s")
	end
end

function rightkey()
	if objects.player[1].gravitydirection > math.pi/4*1 and objects.player[1].gravitydirection <= math.pi/4*3 then
		return love.keyboard.isDown("d")
	elseif objects.player[1].gravitydirection > math.pi/4*3 and objects.player[1].gravitydirection <= math.pi/4*5 then
		return love.keyboard.isDown("s")
	elseif objects.player[1].gravitydirection > math.pi/4*5 and objects.player[1].gravitydirection <= math.pi/4*7 then
		return love.keyboard.isDown("a")
	else
		return love.keyboard.isDown("w")
	end
end

function castspell()
	for i, v in pairs(spells) do
		if #currentspell == #v then
			local pass = true
			for j = 1, #currentspell do
				if v[j] ~= currentspell[j] then
					pass = false
				end
			end

			if pass then
				loadstring("objects.player[1]:" .. i .. "()")()
				lastspell = {unpack(currentspell)}
				lastspelltimer = 0
				currentspell = {}
				spellcount = spellcount + 1
				objects.player[1].magictimer = 0
				objects.player[1].magicframe = 1
				for j = 1, #spellnames do
					if not spelldiscovered[j] and i == spellnames[j].id then
						spelldiscovered[j] = true
					end
				end
				playsound(magicsound)
				return
			end
		end
	end

	if #currentspell == runecount then
		cancelspell()
	end
end

function cancelspell()
	if #currentspell > 0 then
		currentspell = {}
		playsound(cancelmagicsound)
	end
end

function checkhighscore()
	if not bestspells[currentlevel] or spellcount < bestspells[currentlevel] then
		bestspells[currentlevel] = spellcount
		savehighscores()
	end
end

function killeverything()
	for i, v in pairs(objects.diamonddog) do
		v:hurt(9999)
		damageinworld(v.x+v.width/2, v.y, 9999)
	end

	for i, v in pairs(objects.woodblock) do
		v:hurt(9999)
		damageinworld(v.x+v.width/2, v.y, 9999)
	end


	for i, v in pairs(objects.stomper) do
		v.kill = true
	end
end

function game_keypressed(key, unicode)
	if spellbookopen then
		spellbook_keypressed(key, unicode)
		return
	end

	if key == "q" then
		openspellbook()
	end

	if key == "e" or key == "r" then
		cancelspell()
	end

	if key == "space" then
		objects.player[1]:jump()
	end

	if key == "escape" and challengemenu then
		changegamestate("menu")
	end

	if not objects.player[1].dead and objects.player[1].ascendtimer == 0 and (key == "up" or key == "right" or key == "down" or key == "left") then
		if #currentspell < runecount then
			playsound(arrowsound)
			table.insert(currentspell, key)
			runeanimationtimer[#currentspell] = 1
			castspell()
			spelltimeouttimer = 0
		end
	end
end

function game_keyreleased(key, unicode)
	if key == "space" then
		objects.player[1]:stopjump()
	end
end