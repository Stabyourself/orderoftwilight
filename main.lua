function love.load()
	require "class"
	require "variables"
	require "essentials"
	require "tilelist"
	require "physics"
	require "game"
	require "spells"
	require "spellbook"
	require "end"
	require "menu"
	require "quoteunquotestory"

	require "player"
	require "quad"
	require "tile"
	require "laser"
	require "cube"
	require "diamonddog"
	require "damagenumber"
	require "texts"
	require "woodblock"
	require "screenboundary"
	require "stomper"
	require "failbox"
	require "shockwave"
	require "page"
	require "intro"

	gamefinished = true

	love.filesystem.setIdentity( "order_of_twilight" )

	physicsdebug = false
	debugshapes = {}

	love.graphics.setLineWidth(1)

	soundextension = "ogg"
	soundlist = {"jump", "laser", "hurt", "dead", "arrow", "magic", "teleport", "cancelmagic", "playerdead", "superjump",
				"shockwave", "gamewin", "ascend", "runeget", "menumove", "menuselect", "menuback", "letter"}

	for i = 1, #soundlist do
		_G[soundlist[i] .. "sound"] = love.audio.newSource("sounds/" .. soundlist[i] .. "." .. soundextension, "static")
	end

	noiserepeatsound = love.audio.newSource("sounds/noiserepeat.ogg", "static");noiserepeatsound:setLooping(true);noiserepeatsound:setVolume(0.3)
	musicrev = love.audio.newSource("sounds/musicrev.ogg", "static");musicrev:setVolume(0.1);musicrev:setLooping(true)
	music = love.audio.newSource("sounds/music.ogg", "static");music:setVolume(0.1);music:setLooping(true)

	imagelist = {"hornglow", "hornglowbig", "cube", "diamonddog1", "diamonddog2", "numberfont", "font", "fontback", "smallfont", "noise", "lotsanoise", "woodblock", "image1", "image2", "image3",
					"image4", "image5", "image6", "image7", "image8", "image9", "image10", "image11", "image12", "image13", "background1", "background2", "background3", "background4", "magic", "screengradient", "stomper",
					"spellbook", "spellbookbook", "bookarrowright", "bookarrowleft", "shockwave", "page", "letter", "title", "background1noise", "background2noise", "background3noise", "background4noise",
					"rainbowdash", "applejack", "pinkiepie", "fluttershy", "rarity"}

	thumb = {}
	for i = 1, 12 do
		thumb[i] = love.graphics.newImage("maps/thumb" .. i .. ".png")
	end
	love.graphics.setDefaultFilter("nearest", "nearest")

	for i = 1, #imagelist do
		_G[imagelist[i] .. "img"] = love.graphics.newImage("graphics/" .. imagelist[i] .. ".png")
	end


	playeranimation = {}
	playeranimation.idle = love.graphics.newImage("graphics/twilightidle.png")
	playeranimation.jump = love.graphics.newImage("graphics/twilightjump.png")
	playeranimation.dead = love.graphics.newImage("graphics/twilightdead.png")
	playeranimation.ascend = love.graphics.newImage("graphics/twilightascend.png")
	playeranimation.walk = {}
	for i = 1, 4 do
		playeranimation.walk[i] = love.graphics.newImage("graphics/twilightwalk" .. i .. ".png")
	end

	playeranimationinvis = {}
	playeranimationinvis.idle = love.graphics.newImage("graphics/twilightidleinvis.png")
	playeranimationinvis.jump = love.graphics.newImage("graphics/twilightjumpinvis.png")
	playeranimationinvis.walk = {}
	for i = 1, 4 do
		playeranimationinvis.walk[i] = love.graphics.newImage("graphics/twilightwalk" .. i .. "invis.png")
	end

	ponies = {rainbowdashimg, applejackimg, pinkiepieimg, fluttershyimg, rarityimg}

	hornoffsets = {}
	hornoffsets.walk = {{0, 0}, {0, -1}, {0, 0}, {0, -1}}

	arrow = {}
	arrow.back = love.graphics.newImage("graphics/arrowback.png")
	arrow.up = love.graphics.newImage("graphics/arrowup.png")
	arrow.right = love.graphics.newImage("graphics/arrowright.png")
	arrow.down = love.graphics.newImage("graphics/arrowdown.png")
	arrow.left = love.graphics.newImage("graphics/arrowleft.png")
	arrow.glow = love.graphics.newImage("graphics/arrowglow.png")

	numberfontquads = {}
	for i = 0, 9 do
		numberfontquads[i] = love.graphics.newQuad(i*4, 0, 4, 6, 40, 6)
	end

	fontglyphs = "abcdefghijklmnopqrstuvwxyz ^>V<?"
	fontquads = {}
	for i = 1, #fontglyphs do
		fontquads[string.sub(fontglyphs, i, i)] = love.graphics.newQuad((i-1)*8, 0, 8, 7, 256, 7)
	end
	fontbackquads = {}
	for i = 1, #fontglyphs do
		fontbackquads[string.sub(fontglyphs, i, i)] = love.graphics.newQuad((i-1)*10, 0, 10, 9, 320, 9)
	end

	smallfontglyphs = "abcdefghijklmnopqrstuvwxyz ^>V<?0123456789"
	smallfontquads = {}
	for i = 1, #smallfontglyphs do
		smallfontquads[string.sub(smallfontglyphs, i, i)] = love.graphics.newQuad((i-1)*6, 0, 6, 5, 252, 5)
	end

	magicquad = {}
	for i = 1, 5 do
		magicquad[i] = love.graphics.newQuad((i-1)*10, 0, 10, 10, 50, 10)
	end

	logo = love.graphics.newImage("graphics/logo.png")
	logoblood = love.graphics.newImage("graphics/logoblood.png")
	stabsound = love.audio.newSource("sounds/stab.ogg", "static")

	backgrounds = 4

	width = 40
	height = 20

	noise = 0

	maxrunecount = 8

	levelcount = 10

	menuselection = 1
	twilighty = 1
	currentchallenge = 1
	targetoffset = 0
	offset = 0

	tilewidth = 6
	scale = 4
	if love.window.getMode() ~= width*tilewidth*scale then
		love.window.setMode(width*tilewidth*scale, height*tilewidth*scale, false, false, 0)
	end
	love.window.setIcon(love.image.newImageData("graphics/icon.png"))

	runesize = 14
	runespacing = 2
	storynoise = 0

	loadtiles()

	goalspells = {1, 2, 6, 1,
				  1, 3, 3, 2,
				  2, 4, 4, 4}


	bestspells = {}
	loadhighscores()

	tiledb = {}
	--0 -> Free, 1-> Wall, 2-> Doesn't matter
	--Direction is clockwise starting top left.
	tiledb[2] =  {1,1,1,1,1,1,1,1}
	tiledb[3] =  {2,0,2,0,2,0,2,0}
	tiledb[4] =  {0,1,0,1,0,1,0,1}

	tiledb[5] =  {2,0,2,1,1,1,1,1}
	tiledb[6] =  {2,1,1,1,1,1,2,0}
	tiledb[7] =  {1,1,1,1,2,0,2,1}
	tiledb[8] =  {1,1,2,0,2,1,1,1}

	tiledb[9] =  {2,0,2,0,2,0,2,1}
	tiledb[10] = {2,1,2,0,2,0,2,0}
	tiledb[11] = {2,0,2,1,2,0,2,0}
	tiledb[12] = {2,0,2,0,2,1,2,0}

	tiledb[13] = {2,0,2,1,1,1,2,0}
	tiledb[14] = {2,0,2,0,2,1,1,1}
	tiledb[15] = {2,1,1,1,2,0,2,0}
	tiledb[16] = {1,1,2,0,2,0,2,1}

	tiledb[17] = {2,0,2,1,2,0,2,1}
	tiledb[18] = {2,1,2,0,2,1,2,0}
	tiledb[19] = {0,1,1,1,1,1,1,1}
	tiledb[20] = {1,1,0,1,1,1,1,1}

	tiledb[21] = {1,1,1,1,0,1,1,1}
	tiledb[22] = {1,1,1,1,1,1,0,1}
	tiledb[23] = {0,1,1,1,1,1,0,1}
	tiledb[24] = {0,1,0,1,1,1,1,1}

	tiledb[25] = {1,1,0,1,0,1,1,1}
	tiledb[26] = {1,1,1,1,0,1,0,1}
	tiledb[27] = {0,1,1,1,0,1,0,1}
	tiledb[28] = {0,1,0,1,1,1,0,1}

	tiledb[29] = {0,1,0,1,0,1,1,1}
	tiledb[30] = {1,1,0,1,0,1,0,1}
	tiledb[31] = {2,1,0,1,1,1,2,0}
	tiledb[32] = {2,1,0,1,0,1,2,0}

	tiledb[33] = {2,1,1,1,0,1,2,0}
	tiledb[34] = {2,0,2,1,1,1,0,1}
	tiledb[35] = {2,0,2,1,0,1,0,1}
	tiledb[36] = {2,0,2,1,0,1,1,1}

	tiledb[37] = {1,1,2,0,2,1,0,1}
	tiledb[38] = {0,1,2,0,2,1,1,1}
	tiledb[39] = {0,1,2,0,2,1,0,1}
	tiledb[40] = {0,1,1,1,2,0,2,1}

	tiledb[41] = {0,1,0,1,2,0,2,1}
	tiledb[42] = {1,1,0,1,2,0,2,1}
	tiledb[43] = {2,1,0,1,2,0,2,0}
	tiledb[44] = {0,1,2,0,2,0,2,1}

	tiledb[45] = {2,0,2,1,0,1,2,0}
	tiledb[46] = {2,0,2,0,2,1,0,1}
	tiledb[47] = {0,1,1,1,0,1,1,1}
	tiledb[48] = {1,1,0,1,1,1,0,1}

	spelldiscovered = {}
	changegamestate("intro")
end

function love.update(dt)
	--love.graphics.setCaption("FPS: " .. love.timer.getFPS())

	dt = math.min(dt, 1/30)
	if skipupdate then
		skipupdate = false
		return
	end

	if _G[gamestate .. "_update"] then
		_G[gamestate .. "_update"](dt)
	end
	noiserepeatsound:setVolume(math.max(storynoise/2, noise)/100*0.6)
end

function love.draw()
	if _G[gamestate .. "_draw"] then
		_G[gamestate .. "_draw"]()
	end

	love.graphics.setColor(1, 1, 1, 0.01*noise)
	love.graphics.draw(lotsanoiseimg, -math.random()*240, -math.random()*120, 0, scale, scale)
	love.graphics.setColor(1, 1, 1)
end

function loadtiles()
	local tileimg = love.graphics.newImage("graphics/tiles.png")
	local tileimgdata = love.image.newImageData("graphics/tiles.png")

	local width = tileimgdata:getWidth()
	local height = tileimgdata:getHeight()

	tilequads = {}

	for y = 1, math.floor(height/(tilewidth+1)) do
		for x = 1, math.floor(width/(tilewidth+1)) do
			table.insert(tilequads, quad:new(tileimg, tileimgdata, x, y, width, height))
		end
	end
end

function loadhighscores()
	if love.filesystem.getInfo("high") then
		local s = love.filesystem.read("high")
		local s1 = s:split(";")
		for i = 1, 12 do
			if tonumber(s1[i]) then
				bestspells[i] = tonumber(s1[i])
			end
		end
		if #s1 == 13 then
			gamefinished = true
		end
	end
end

function savehighscores()
	local s = ""
	for i = 1, 12 do
		if bestspells[i] then
			s = s .. bestspells[i]
		end
		if i ~= 12 or gamefinished then
			s = s .. ";"
		end
	end

	love.filesystem.write("high", s)
end

function numberprint(s, x, y)
	local s = tostring(s)
	for j = 1, #s do
		local i = tonumber(string.sub(s, j, j))
		if i then
			love.graphics.draw(numberfontimg, numberfontquads[i], math.floor((x+(j-1)*5)*scale), math.floor(y*scale), 0, scale, scale)
		end
	end
end

function properprint(s, x, y, background)
	for j = 1, #s do
		local i = string.sub(s, j, j)
		if background then
			local pos = x+(j-1)*8-1
			if pos > -xscroll-4 and pos < xscroll+width*tilewidth+8 then
				love.graphics.draw(fontbackimg, fontbackquads[i], math.floor((pos)*scale), math.floor((y-1)*scale), 0, scale, scale)
			end
		else
			love.graphics.draw(fontimg, fontquads[i], math.floor((x+(j-1)*8)*scale), math.floor(y*scale), 0, scale, scale)
		end
	end
end

function properprintsmall(s, x, y)
	for j = 1, #s do
		local i = string.sub(s, j, j)
		love.graphics.draw(smallfontimg, smallfontquads[i], math.floor((x+(j-1)*6)*scale), math.floor(y*scale), 0, scale, scale)
	end
end

function changegamestate(s)
	gamestate = s
	if _G[gamestate .. "_load"] then
		_G[gamestate .. "_load"]()
	end
end

function playsound(s)
	love.audio.stop(s)
	love.audio.play(s)
end

function love.keypressed(key, unicode)
	if _G[gamestate .. "_keypressed"] then
		_G[gamestate .. "_keypressed"](key, unicode)
	end
end

function love.keyreleased(key, unicode)
	if _G[gamestate .. "_keyreleased"] then
		_G[gamestate .. "_keyreleased"](key, unicode)
	end
end